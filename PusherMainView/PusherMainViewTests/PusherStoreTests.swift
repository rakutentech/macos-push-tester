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

    func pushToDevice(_ token: String, payload: Dictionary<String, Any>, withTopic topic: String?, priority: Int, collapseID: String?, inSandbox sandbox: Bool, completion: @escaping (Result<String, Error>) -> Void) {
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

class PusherStoreTests: XCTestCase {
    func testPush() {
        // Push Success
        
        PusherStore(apnsPusher: APNSPusherMock(result: .success("OK"),
                                               type: .token(keyID: "keyID",
                                                            teamID: "teamID",
                                                            p8: "p8")),
                    router: RouterMock()).dispatch(actionType: .push(#"{"":""}"#,
                                                                     destination: .device,
                                                                     deviceToken: "1234",
                                                                     appBundleID: "com.myapp",
                                                                     priority: 0,
                                                                     collapseID: nil,
                                                                     sandbox: true,
                                                                     completion: { success in
                                                                        XCTAssertTrue(success)
                    }))
        
        // Push Error
        
        PusherStore(apnsPusher: APNSPusherMock(result:.failure(NSError(domain: "com.pusher.error",
                                                                       code: 400,
                                                                       userInfo: nil)),
                                               type: .token(keyID: "keyID",
                                                            teamID: "teamID",
                                                            p8: "p8")),
                    router: RouterMock()).dispatch(actionType: .push(#"{"":""}"#,
                                                                     destination: .device,
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
