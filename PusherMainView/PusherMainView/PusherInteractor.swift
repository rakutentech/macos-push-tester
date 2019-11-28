import Foundation
import APNS

enum ActionType {
    case devicesList(fromViewController: NSViewController)
    case authToken(fromViewController: NSViewController)
    case alert(message: String, fromWindow: NSWindow?)
    case browsingFiles(fromViewController: NSViewController, completion: (_ p8FileURL: URL) -> Void)
    case selectDevice(device: APNSServiceDevice)
    case selectAuthToken
    case saveAuthToken(teamID: String, keyID: String, p8FileURL: URL, p8: String)
    case updateIdentity(identity: SecIdentity)
    case push(_ payloadString: String,
        deviceToken: String,
        appBundleID: String?,
        priority: Int,
        collapseID: String?,
        sandbox: Bool,
        completion:(Bool) -> Void)
}

enum DispatchedAction {
    case didSelectDevicetoken(_ deviceToken: String, appBundleID: String)
    case didCancelSelectingAuthToken
}

struct AuthToken: Codable {
    public let keyID: String
    public let teamID: String
    public let p8FileURLString: String
}

protocol PusherInteractable: class {
    func didDispatch(dispatchedAction: DispatchedAction)
}

protocol PusherInteracting: class {
    var delegate: PusherInteractable? { get set }
    var authToken: AuthToken? { get }
    func dispatch(actionType: ActionType)
}

final class PusherInteractor: NSObject {
    private var apnsPusher: APNSPushable
    private let router: Routing
    public private(set) var authToken: AuthToken?
    weak var delegate: PusherInteractable?
    
    init(apnsPusher: APNSPushable, router: Routing) {
        self.apnsPusher = apnsPusher
        self.router = router
        super.init()
        updateAuthToken()
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
              to deviceToken: String,
              appBundleID: String?,
              priority: Int,
              collapseID: String?,
              inSandbox sandbox: Bool,
              completion:@escaping (Bool) -> Void) {
        if case .none = apnsPusher.type {
            router.show(message: "Please select an APNS method", window: NSApplication.shared.windows.first)
            completion(false)
            return
        }
        
        if case .certificate = apnsPusher.type, apnsPusher.identity == nil {
            router.show(message: "Please select an APNS Certificate", window: NSApplication.shared.windows.first)
            completion(false)
            return
        }
        
        guard deviceToken.count > 0 else {
            router.show(message: "Please enter a Device Token", window: NSApplication.shared.windows.first)
            completion(false)
            return
        }
        
        guard let appBundleID = appBundleID, appBundleID.count > 0 else {
            router.show(message: "Please enter an app bundle ID", window: NSApplication.shared.windows.first)
            completion(false)
            return
        }
        
        guard let data = payloadString.data(using: .utf8),
            let payload = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? Dictionary<String, Any> else {
                completion(false)
                return
        }
        
        apnsPusher.pushPayload(payload,
                               to: deviceToken,
                               withTopic: appBundleID,
                               priority: priority,
                               collapseID: collapseID,
                               inSandbox: sandbox,
                               completion: { [weak self] result in
                                guard let self = self else {
                                    return
                                }
                                
                                switch result {
                                case .failure(let error):
                                    self.router.show(message: error.localizedDescription, window: NSApplication.shared.windows.first)
                                    completion(false)
                                    
                                case .success(_):
                                    completion(true)
                                }
        })
    }
}

extension PusherInteractor: PusherInteracting {
    func dispatch(actionType: ActionType) {
        switch actionType {
        case .devicesList(let fromViewController):
            router.presentDevicesList(from: fromViewController, pusherInteractor: self)
        case .authToken(let fromViewController):
            updateAuthToken()
            router.presentAuthTokenAlert(from: fromViewController, pusherInteractor: self)
        case .alert(let message, let window):
            router.show(message: message, window: window)
        case .browsingFiles(let fromViewController, let completion):
            router.browseFiles(from: fromViewController, completion: completion)
        case .selectDevice(let device):
            delegate?.didDispatch(dispatchedAction: .didSelectDevicetoken(device.token, appBundleID: device.appID))
        case .selectAuthToken:
            delegate?.didDispatch(dispatchedAction: .didCancelSelectingAuthToken)
        case .saveAuthToken(let teamID, let keyID, let p8FileURL, let p8):
            apnsPusher.type = .token(keyID: keyID, teamID: teamID, p8: p8)
            Keychain.set(value: keyID, forKey: "keyID")
            Keychain.set(value: teamID, forKey: "teamID")
            Keychain.set(value: p8FileURL.absoluteString, forKey: "p8FileURLString")
        case .updateIdentity(let identity):
            apnsPusher.type = .certificate(identity: identity)
        case .push(let payloadString,
                   let deviceToken,
                   let appBundleID,
                   let priority,
                   let collapseID,
                   let sandbox,
                   let completion):
            push(payloadString,
                 to: deviceToken,
                 appBundleID: appBundleID,
                 priority: priority,
                 collapseID: collapseID,
                 inSandbox: sandbox,
                 completion: completion)
        }
    }
}
