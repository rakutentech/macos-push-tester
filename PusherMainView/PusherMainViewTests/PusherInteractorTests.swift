import XCTest
import APNS
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
    
    func pushPayload(_ payload: Dictionary<String, Any>, to token: String, withTopic topic: String?, priority: Int, collapseID: String?, inSandbox sandbox: Bool, completion: @escaping (Result<String, Error>) -> Void) {
        completion(result)
    }
}

struct RouterMock: Routing {
    func presentDevicesList(from fromViewController: NSViewController, pusherInteractor: PusherInteracting) {
    }
    
    func presentAuthTokenAlert(from fromViewController: NSViewController, pusherInteractor: PusherInteracting) {
    }
    
    func show(message: String, window: NSWindow?) {
    }
    
    func browseFiles(from fromViewController: NSViewController, completion: @escaping (URL) -> Void) {
    }
    
    func dismiss(from fromViewController: NSViewController) {
    }
}

class PusherInteractorTests: XCTestCase {
    func testPush() {
        // Push Success
        
        PusherInteractor(apnsPusher: APNSPusherMock(result: .success("OK"),
                                                    type: .token(keyID: "keyID",
                                                                 teamID: "teamID",
                                                                 p8: "p8")),
                         router: RouterMock()).dispatch(actionType: .push(#"{"":""}"#,
                                                                          deviceToken: "1234",
                                                                          appBundleID: "com.myapp",
                                                                          priority: 0,
                                                                          collapseID: nil,
                                                                          sandbox: true,
                                                                          completion: { success in
                                                                            XCTAssertTrue(success)
                         }))
        
        // Push Error
        
        PusherInteractor(apnsPusher: APNSPusherMock(result:.failure(NSError(domain: "com.pusher.error",
        code: 400,
        userInfo: nil)),
                                                    type: .token(keyID: "keyID",
                                                                 teamID: "teamID",
                                                                 p8: "p8")),
                         router: RouterMock()).dispatch(actionType: .push(#"{"":""}"#,
                                                                          deviceToken: "1234",
                                                                          appBundleID: "com.myapp",
                                                                          priority: 0,
                                                                          collapseID: nil,
                                                                          sandbox: true,
                                                                          completion: { success in
                                                                            XCTAssertFalse(success)
                         }))
    }
}
