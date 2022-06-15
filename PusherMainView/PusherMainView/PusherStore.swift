import Foundation
import APNS
import SecurityInterface.SFChooseIdentityPanel

enum Destination {
    case device
    case simulator
}

struct AuthToken: Codable {
    public let keyID: String
    public let teamID: String
    public let p8FileURLString: String
}

protocol PusherInteractable where Self: NSObject {
    func newState(state: PusherState)
    func newErrorState(_ errorState: ErrorState)
}

protocol PusherInteracting {
    var authToken: AuthToken? { get }
    func subscribe(_ pusherInteractable: PusherInteractable)
    func unsubscribe(_ pusherInteractable: PusherInteractable)
    func dispatch(actionType: ActionType)
}

final class PusherStore {
    private var apnsPusher: APNSPushable
    private let router: Routing
    private let reducer = PusherReducer()
    public private(set) var authToken: AuthToken?
    private var subscribers: [PusherInteractable] = []
    private var state: PusherState = PusherState(deviceTokenString: "",
                                                 appID: "",
                                                 certificateRadioState: .off,
                                                 authTokenRadioState: .off,
                                                 deviceRadioState: .on,
                                                 simulatorRadioState: .off,
                                                 appTitle: "")

    init(apnsPusher: APNSPushable, router: Routing) {
        self.apnsPusher = apnsPusher
        self.router = router
        updateAuthToken()
        #if DEBUG
        print("\(PusherStore.self) init")
        #endif
    }

    deinit {
        #if DEBUG
        print("\(PusherStore.self) deinit")
        #endif
    }

    private func updateAuthToken() {
        guard let keyID = Keychain.string(for: "keyID"),
              let teamID = Keychain.string(for: "teamID"),
              let p8FileURLString = Keychain.string(for: "p8FileURLString") else {
            return
        }
        authToken = AuthToken(keyID: keyID, teamID: teamID, p8FileURLString: p8FileURLString)
    }

    private func push(_ payloadString: String,
                      to destination: Destination,
                      deviceToken: String?,
                      appBundleID: String?,
                      priority: Int,
                      collapseID: String?,
                      inSandbox sandbox: Bool,
                      completion:@escaping (Bool) -> Void) {

        guard let appBundleID = appBundleID, !appBundleID.isEmpty else {
            router.show(message: "please.enter.an app.bundle.id".localized, window: NSApplication.shared.windows.first)
            completion(false)
            return
        }

        switch destination {

        case .simulator:
            apnsPusher.pushToSimulator(payload: payloadString, appBundleID: appBundleID) { [weak self] result in
                self?.handlePushResult(result, calling: completion)
            }

        case .device:
            if case .none = apnsPusher.type {
                router.show(message: "please.select.an.apns.method".localized, window: NSApplication.shared.windows.first)
                completion(false)
                return
            }

            if case .certificate = apnsPusher.type, apnsPusher.identity == nil {
                router.show(message: "please.select.an.apns.certificate".localized, window: NSApplication.shared.windows.first)
                completion(false)
                return
            }

            guard let deviceToken = deviceToken, !deviceToken.isEmpty else {
                router.show(message: "please.enter.a.device.token".localized, window: NSApplication.shared.windows.first)
                completion(false)
                return
            }

            guard let data = payloadString.data(using: .utf8),
                  let payload = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
                completion(false)
                return
            }

            apnsPusher.pushToDevice(deviceToken,
                                    payload: payload,
                                    withTopic: appBundleID,
                                    priority: priority,
                                    collapseID: collapseID,
                                    inSandbox: sandbox,
                                    completion: { [weak self] result in
                                        self?.handlePushResult(result, calling: completion)
                                    })
        }
    }

    private func handlePushResult(_ result: Result<String, Error>, calling completion: (Bool) -> Void) {
        switch result {
        case .failure(let error):
            self.router.show(message: error.localizedDescription, window: NSApplication.shared.windows.first)
            completion(false)

        case .success(_):
            completion(true)
        }
    }
}

extension PusherStore: PusherInteracting {
    func subscribe(_ pusherInteractable: PusherInteractable) {
        subscribers.append(pusherInteractable)
        pusherInteractable.newState(state: state) // send current state
    }

    func unsubscribe(_ pusherInteractable: PusherInteractable) {
        guard let index = subscribers.firstIndex(where: { pusherInteractable == $0 }) else {
            return
        }
        subscribers.remove(at: index)
    }

    func dispatch(actionType: ActionType) {
        switch actionType {
        case .devicesList(let fromViewController):
            router.presentDevicesList(from: fromViewController, pusherStore: self)
            reduce(result: .success(actionType))

        case .deviceToken(_):
            state = reducer.reduce(actionType: actionType, state: state)
            reduce(result: .success(actionType))

        case .alert(let message, let window):
            router.show(message: message, window: window)
            reduce(result: .success(actionType))

        case .browsingFiles(let fromViewController, let completion):
            router.browseFiles(from: fromViewController, completion: completion)
            reduce(result: .success(actionType))

        case .browsingJSONFiles(let fromViewController, let completion):
            router.browseFiles(from: fromViewController) { fileURL in
                guard let jsonString = try? String(contentsOf: fileURL, encoding: .utf8) else {
                    self.dispatch(actionType: .alert(message: "error.json.file.is.incorrect".localized, fromWindow: NSApplication.shared.mainWindow))
                    return
                }
                completion(fileURL, jsonString)
            }
            reduce(result: .success(actionType))

        case .chooseAuthToken(let fromViewController):
            updateAuthToken()
            router.presentAuthTokenAlert(from: fromViewController, pusherStore: self)
            reduce(result: .success(actionType))

        case .saveAuthToken(let teamID, let keyID, let p8FileURL, let p8):
            apnsPusher.type = .token(keyID: keyID, teamID: teamID, p8: p8)
            Keychain.set(value: keyID, forKey: "keyID")
            Keychain.set(value: teamID, forKey: "teamID")
            Keychain.set(value: p8FileURL.absoluteString, forKey: "p8FileURLString")
            reduce(result: .success(actionType))

        case .dismiss(let fromViewController):
            router.dismiss(from: fromViewController)
            reduce(result: .success(actionType))

        case .updateIdentity(let identity):
            apnsPusher.type = .certificate(identity: identity)
            reduce(result: .success(actionType))

        case .push(let payloadString,
                   let destination,
                   let deviceToken,
                   let appBundleID,
                   let priority,
                   let collapseID,
                   let sandbox,
                   let completion):
            push(payloadString,
                 to: destination,
                 deviceToken: deviceToken,
                 appBundleID: appBundleID,
                 priority: priority,
                 collapseID: collapseID,
                 inSandbox: sandbox,
                 completion: completion)
            reduce(result: .success(actionType))

        case .selectDevice, .cancelAuthToken:
            reduce(result: .success(actionType))

        case .chooseIdentity(let fromViewController):
            let identities = APNSIdentity.identities()
            guard !identities.isEmpty else {
                state = reducer.reduce(actionType: .cancelIdentity, state: state)
                subscribers.forEach { $0.newState(state: state) }
                router.show(message: "error.no.identity".localized, window: NSApplication.shared.windows.first)
                return
            }
            let panel = SFChooseIdentityPanel.shared()
            panel?.setAlternateButtonTitle("cancel".localized)
            panel?.beginSheet(for: fromViewController.view.window,
                              modalDelegate: self,
                              didEnd: #selector(chooseIdentityPanelDidEnd(_:returnCode:contextInfo:)),
                              contextInfo: nil,
                              identities: identities,
                              message: "choose.identity".localized)
            reduce(result: .success(actionType))

        case .enableSaveMenuItem:
            NSApplication.shared.saveMenuItem?.isEnabled = true
            reduce(result: .success(actionType))

        case .saveFile(let text, let fileURL):
            do {
                try text.write(to: fileURL, atomically: true, encoding: .utf8)
                reduce(result: .success(actionType))

            } catch {
                router.show(message: "error.save.file".localized, window: NSApplication.shared.windows.first)
                reduce(result: .failure(error, actionType))
            }

        case .saveFileAs(let text, let fromViewController, let completion):
            router.saveFileAs(from: fromViewController) { fileURL in
                self.dispatch(actionType: .enableSaveMenuItem)
                self.dispatch(actionType: .saveFile(text: text, fileURL: fileURL))
                completion(fileURL)
            }

        default:
            reduce(result: .success(actionType))
        }
    }

    enum StoreResult {
        case success(ActionType)
        case failure(Error, ActionType)
    }

    private func reduce(result: StoreResult) {
        switch result {
        case .success(let actionType):
            let oldState = state
            state = reducer.reduce(actionType: actionType, state: state)
            if state != oldState {
                subscribers.forEach { $0.newState(state: state) }
            }

        case .failure(let error, let actionType):
            subscribers.forEach { $0.newErrorState(ErrorState(error: error as NSError, actionType: actionType)) }
        }
    }

    @objc private func chooseIdentityPanelDidEnd(_ sheet: NSWindow, returnCode: Int, contextInfo: Any) {
        guard returnCode == NSApplication.ModalResponse.OK.rawValue, let identity = SFChooseIdentityPanel.shared()?.identity() else {
            dispatch(actionType: .cancelIdentity)
            return
        }

        dispatch(actionType: .updateIdentity(identity: identity.takeUnretainedValue() as SecIdentity))
    }
}
