import Foundation
import APNS
import Quick
import Nimble
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

    func pushToDevice(_ token: String, payload: [String: Any], withTopic topic: String?, priority: Int, collapseID: String?, inSandbox sandbox: Bool, completion: @escaping (Result<String, Error>) -> Void) {
        completion(result)
    }

    func pushToSimulator(payload: String, appBundleID bundleID: String, completion: @escaping (Result<String, Error>) -> Void) {
        completion(result)
    }
}

struct RouterMock: Routing {
    func presentDevicesList(from fromViewController: NSViewController, pusherStore: PusherInteracting) {
    }

    func presentAuthTokenAlert(from fromViewController: NSViewController, pusherStore: PusherInteracting) {
    }

    func show(message: String, window: NSWindow?) {
    }

    func browseFiles(from fromViewController: NSViewController, completion: @escaping (URL) -> Void) {
    }

    func dismiss(from fromViewController: NSViewController) {
    }
}

final class PusherStoreSpec: QuickSpec {
    override func spec() {
        describe("PusherStore") {
            context("When a push action is dispatched") {
                context("When APNS returns an error") {
                    it("should return error") {
                        var failure = false
                        let store = PusherStore(apnsPusher: APNSPusherMock(result: .failure(NSError(domain: "com.pusher.error",
                                                                                                    code: 400,
                                                                                                    userInfo: nil)),
                                                                           type: .token(keyID: "keyID",
                                                                                        teamID: "teamID",
                                                                                        p8: "p8")),
                                                router: RouterMock())

                        store.dispatch(actionType: .push(#"{"":""}"#,
                                                         destination: .device,
                                                         deviceToken: "1234",
                                                         appBundleID: "com.myapp",
                                                         priority: 0,
                                                         collapseID: nil,
                                                         sandbox: true,
                                                         completion: { success in
                                                            failure = !success
                                                         }))

                        expect(failure).toEventually(beTrue())
                    }
                }

                context("When APNS returns a success") {
                    it("should return success") {
                        var success = false
                        let store = PusherStore(apnsPusher: APNSPusherMock(result: .success("OK"),
                                                                           type: .token(keyID: "keyID",
                                                                                        teamID: "teamID",
                                                                                        p8: "p8")),
                                                router: RouterMock())

                        store.dispatch(actionType: .push(#"{"":""}"#,
                                                         destination: .device,
                                                         deviceToken: "1234",
                                                         appBundleID: "com.myapp",
                                                         priority: 0,
                                                         collapseID: nil,
                                                         sandbox: true,
                                                         completion: { aSuccess in
                                                            success = aSuccess
                                                         }))

                        expect(success).toEventually(beTrue())
                    }
                }
            }
        }
    }
}
