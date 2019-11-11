import XCTest
import APNS
@testable import PusherMainView

class APNSPusherMock: APNSPushable {
    var statusCode = 0
    var type: APNSPusherType
    var identity: SecIdentity?
    
    init(statusCode: Int, type: APNSPusherType) {
        self.statusCode = statusCode
        self.type = type
        identity = nil
    }
    
    func pushPayload(_ payload: Dictionary<String, Any>, toToken token: String, withTopic topic: String?, priority: Int, collapseID: String?, inSandbox sandbox: Bool, completion: @escaping (Result<(statusCode: Int, reason: String, ID: String?), Error>) -> Void) {
        if statusCode == 200 {
            completion(.success((statusCode, "", nil)))
            
        } else {
            completion(.failure(NSError(domain: "com.pusher.error",
                                        code: statusCode,
                                        userInfo: nil)))
        }
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
}

class PusherInteractorTests: XCTestCase {
    func testPush() {
        // Push Success
        
        PusherInteractor(apnsPusher: APNSPusherMock(statusCode: 200,
                                                    type: .token(keyID: "keyID",
                                                                 teamID: "teamID",
                                                                 p8: "p8")),
                         router: RouterMock()).push(#"{"":""}"#,
                                                    toToken: "1234",
                                                    withTopic: nil,
                                                    priority: 0,
                                                    collapseID: nil,
                                                    inSandbox: true,
                                                    completion: { success in
                                                        XCTAssertTrue(success)
                         })
        
        // Push Error
        
        PusherInteractor(apnsPusher: APNSPusherMock(statusCode: 400,
                                                    type: .token(keyID: "keyID",
                                                                 teamID: "teamID",
                                                                 p8: "p8")),
                         router: RouterMock()).push(#"{"":""}"#,
                                                    toToken: "1234",
                                                    withTopic: nil,
                                                    priority: 0,
                                                    collapseID: nil,
                                                    inSandbox: true,
                                                    completion: { success in
                                                        XCTAssertFalse(success)
                         })
    }
}
