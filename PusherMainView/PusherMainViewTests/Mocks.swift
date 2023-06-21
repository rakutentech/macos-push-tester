import Foundation
import APNS
import FCM
@testable import PusherMainView

class APNSPusherMock: APNSPushable {
    private var result: Result<String, Error>
    var type: APNSPusherType
    var identity: SecIdentity?

    init(result: Result<String, Error>, type: APNSPusherType) {
        self.result = result
        self.type = type
        identity = nil
    }

    func pushToDevice(_ token: String,
                      payload: [String: Any],
                      withTopic topic: String?,
                      priority: Int,
                      collapseID: String?,
                      inSandbox sandbox: Bool,
                      pushType: String,
                      completion: @escaping (Result<String, Error>) -> Void) {
        completion(result)
    }

    func pushToSimulator(payload: String, appBundleID bundleID: String, completion: @escaping (Result<String, Error>) -> Void) {
        completion(result)
    }
}

struct FCMPusherMock: FCMPushable {
    let result: Result<String, Error>

    func pushUsingLegacyEndpoint(_ token: String,
                                 payload: [String: Any],
                                 collapseID: String?,
                                 serverKey: String,
                                 completion: @escaping (Result<String, Error>) -> Void) {
        completion(result)
    }

    func pushUsingV1Endpoint(_ token: String,
                             payload: [String: Any],
                             collapseID: String?,
                             serverKey: String,
                             projectID: String,
                             completion: @escaping (Result<String, Error>) -> Void) {
        completion(result)
    }
}

class RouterMock: Routing {
    var fileURL: URL!
    private(set) var lastMessage: String?

    func presentDevicesList(from fromViewController: NSViewController, pusherStore: PusherInteracting) {
    }

    func presentAuthTokenAlert(from fromViewController: NSViewController, pusherStore: PusherInteracting) {
    }

    func show(message: String, window: NSWindow?) {
        lastMessage = message
    }

    func browseFiles(from fromViewController: NSViewController, completion: @escaping (URL) -> Void) {
    }

    func saveFileAs(from fromViewController: NSViewController, completion: @escaping (URL) -> Void) {
        completion(fileURL)
    }

    func dismiss(from fromViewController: NSViewController) {
    }
}

final class ObserverMock: NSObject {
    private(set) var pusherState: PusherState?
    private(set) var errorState: ErrorState?
}

extension ObserverMock: PusherInteractable {
    func newState(state: PusherState) {
        self.pusherState = state
    }

    func newErrorState(_ errorState: ErrorState) {
        self.errorState = errorState
    }
}
