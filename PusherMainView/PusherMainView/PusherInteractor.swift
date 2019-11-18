import Foundation
import APNS

enum ActionType {
    case none
    case devicesList(fromViewController: NSViewController)
    case authToken(fromViewController: NSViewController)
    case alert(message: String, fromWindow: NSWindow?)
    case browsingFiles(fromViewController: NSViewController, completion: (_ p8FileURL: URL) -> Void)
}

struct AuthToken: Codable {
    public let keyID: String
    public let teamID: String
    public let p8FileURLString: String
}

protocol PusherInteractable: class {
    func didSelectDevicetoken(_ deviceToken: String)
    func didCancelSelectingAuthToken()
}

protocol PusherInteracting: class {
    var delegate: PusherInteractable? { get set }
    var authToken: AuthToken? { get }
    func present(actionType: ActionType)
    func updateIdentity(_ identity: SecIdentity)
    func updateAuthToken(teamID: String, keyID: String, p8FileURL: URL, p8: String)
    func push(_ payloadString: String,
              toToken deviceToken: String,
              withTopic topic: String?,
              priority: Int,
              collapseID: String?,
              inSandbox sandbox: Bool,
              completion:@escaping (Bool) -> Void)
    func cancelSelectingAuthToken()
    func selectDevice(_ device: APNSServiceDevice)
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
        
        guard let keyID = PreferenceManager.string(for: "keyID"), let teamID = PreferenceManager.string(for: "teamID"), let p8FileURLString = PreferenceManager.string(for: "p8FileURLString") else {
            return
        }
        authToken = AuthToken(keyID: keyID, teamID: teamID, p8FileURLString: p8FileURLString)
    }
}

extension PusherInteractor: PusherInteracting {
    func present(actionType: ActionType) {
        switch actionType {
        case .devicesList(let fromViewController):
            router.presentDevicesList(from: fromViewController, pusherInteractor: self)
        case .authToken(let fromViewController):
            router.presentAuthTokenAlert(from: fromViewController, pusherInteractor: self)
        case .alert(let message, let window):
            router.show(message: message, window: window)
        case .browsingFiles(let fromViewController, let completion):
            router.browseFiles(from: fromViewController, completion: completion)
        case .none: ()
        }
    }
    
    func updateIdentity(_ identity: SecIdentity) {
        apnsPusher.type = .certificate(identity: identity)
    }
    
    func updateAuthToken(teamID: String, keyID: String, p8FileURL: URL, p8: String) {
        apnsPusher.type = .token(keyID: keyID, teamID: teamID, p8: p8)
        
        PreferenceManager.set(value: keyID, forKey: "keyID")
        PreferenceManager.set(value: teamID, forKey: "teamID")
        PreferenceManager.set(value: p8FileURL.absoluteString, forKey: "p8FileURLString")
    }
    
    func push(_ payloadString: String,
              toToken deviceToken: String,
              withTopic topic: String?,
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
        
        guard let data = payloadString.data(using: .utf8),
            let payload = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? Dictionary<String, Any> else {
                completion(false)
                return
        }
        
        apnsPusher.pushPayload(payload,
                                toToken: deviceToken,
                                withTopic: topic,
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
                                        
                                    case .success(_, let reason, _):
                                        self.router.show(message: reason, window: NSApplication.shared.windows.first)
                                        completion(true)
                                    }
        })
    }
    
    func cancelSelectingAuthToken() {
        delegate?.didCancelSelectingAuthToken()
    }
    
    func selectDevice(_ device: APNSServiceDevice) {
        delegate?.didSelectDevicetoken(device.token)
    }
}
