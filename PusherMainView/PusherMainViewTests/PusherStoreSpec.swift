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
    var fileURL: URL!

    func presentDevicesList(from fromViewController: NSViewController, pusherStore: PusherInteracting) {
    }

    func presentAuthTokenAlert(from fromViewController: NSViewController, pusherStore: PusherInteracting) {
    }

    func show(message: String, window: NSWindow?) {
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
    internal private(set) var pusherState: PusherState?
    internal private(set) var errorState: ErrorState?

    func reset() {
        self.pusherState = nil
        self.errorState = nil
    }
}

extension ObserverMock: PusherInteractable {
    func newState(state: PusherState) {
        self.pusherState = state
    }

    func newErrorState(_ errorState: ErrorState) {
        self.errorState = errorState
    }
}

final class PusherStoreSpec: QuickSpec {
    override func spec() {
        var router = RouterMock()
        let viewController = NSViewController()
        let fileName = "pusherfile.txt"
        let filePath = FileManager.default.currentDirectoryPath.appending("/\(fileName)")
        let fileURL: URL! = URL(string: "file://" + filePath)
        let invalidFileURL: URL! = URL(string: "invalid://" + filePath)
        let textToSave = "hello world"
        let observer = ObserverMock()
        let apnsPusherMock = APNSPusherMock(result: .success("OK"),
                                            type: .token(keyID: "keyID",
                                                         teamID: "teamID",
                                                         p8: "p8"))
        let failedAPNSMock = APNSPusherMock(result: .failure(NSError(domain: "com.pusher.error",
                                                                     code: 400,
                                                                     userInfo: nil)),
                                            type: .token(keyID: "keyID",
                                                         teamID: "teamID",
                                                         p8: "p8"))
        let validJSONstring = #"{"":""}"#
        let invalidJSONstring = #"{]"#

        describe("PusherStore") {
            afterEach {
                try? FileManager.default.removeItem(at: fileURL)
                observer.reset()
                router.fileURL = nil
            }

            context("When a saveFileAs action is dispatched") {
                context("When the file URL is invalid") {
                    it("should return an error") {
                        router.fileURL = invalidFileURL

                        let store = PusherStore(apnsPusher: apnsPusherMock, router: router)
                        store.subscribe(observer)
                        store.dispatch(actionType: .saveFileAs(text: textToSave,
                                                               fromViewController: viewController,
                                                               completion: { _ in
                        }))

                        if case .saveFile(let text, let fileURL) = observer.errorState?.actionType {
                            expect(text).to(equal(textToSave))
                            expect(fileURL).to(equal(invalidFileURL))

                        } else {
                            fail("Expecting to get .saveFile action")
                        }

                        expect((observer.errorState?.error as NSError?)?.domain).toEventually(equal("NSCocoaErrorDomain"))
                        expect((observer.errorState?.error as NSError?)?.code).to(equal(518))
                    }
                }

                context("When the file URL is valid") {
                    it("should save the file") {
                        router.fileURL = fileURL

                        let store = PusherStore(apnsPusher: apnsPusherMock, router: router)
                        store.subscribe(observer)
                        store.dispatch(actionType: .saveFileAs(text: textToSave,
                                                               fromViewController: viewController,
                                                               completion: { _ in
                        }))

                        expect(observer.pusherState?.fileURL).toEventually(equal(fileURL))

                        expect(FileManager.default.fileExists(atPath: filePath)).to(beTrue())
                    }

                    it("should save the correct text") {
                        router.fileURL = fileURL

                        let store = PusherStore(apnsPusher: apnsPusherMock, router: router)
                        store.subscribe(observer)
                        store.dispatch(actionType: .saveFileAs(text: textToSave,
                                                               fromViewController: viewController,
                                                               completion: { _ in
                        }))

                        let text = try? String(contentsOfFile: filePath)
                        expect(text).toEventually(equal(textToSave))
                    }
                }
            }

            context("When a saveFile action is dispatched") {
                context("When the file URL is invalid") {
                    it("should return an error") {
                        let store = PusherStore(apnsPusher: apnsPusherMock, router: router)
                        store.subscribe(observer)
                        store.dispatch(actionType: .saveFile(text: textToSave, fileURL: invalidFileURL))

                        if case .saveFile(let text, let fileURL) = observer.errorState?.actionType {
                            expect(text).to(equal(textToSave))
                            expect(fileURL).to(equal(invalidFileURL))

                        } else {
                            fail("Expecting to get .saveFile action")
                        }

                        expect((observer.errorState?.error as NSError?)?.domain).toEventually(equal("NSCocoaErrorDomain"))
                        expect((observer.errorState?.error as NSError?)?.code).to(equal(518))
                    }
                }

                context("When the file URL is valid") {
                    it("should save the file") {
                        let store = PusherStore(apnsPusher: apnsPusherMock, router: router)
                        store.subscribe(observer)
                        store.dispatch(actionType: .saveFile(text: textToSave, fileURL: fileURL))

                        expect(observer.pusherState?.fileURL).toEventually(equal(fileURL))

                        expect(FileManager.default.fileExists(atPath: filePath)).to(beTrue())
                    }

                    it("should save the correct text") {
                        let store = PusherStore(apnsPusher: apnsPusherMock, router: router)
                        store.subscribe(observer)
                        store.dispatch(actionType: .saveFile(text: textToSave, fileURL: fileURL))

                        let text = try? String(contentsOfFile: filePath)
                        expect(text).toEventually(equal(textToSave))
                    }
                }
            }

            context("When a push action is dispatched") {
                context("When the JSON string is invalid") {
                    context("When APNS returns an error") {
                        it("should return an error") {
                            let store = PusherStore(apnsPusher: failedAPNSMock,
                                                    router: router)
                            store.subscribe(observer)
                            store.dispatch(actionType: .push(invalidJSONstring,
                                                             destination: .device,
                                                             deviceToken: "1234",
                                                             appBundleID: "com.myapp",
                                                             priority: 0,
                                                             collapseID: nil,
                                                             sandbox: true,
                                                             completion: { _ in
                                                             }))

                            expect(observer.errorState?.error as? PushTesterError).toEventually(equal(.invalidJson))
                        }
                    }

                    context("When APNS returns a success") {
                        it("should return an error") {
                            let store = PusherStore(apnsPusher: apnsPusherMock,
                                                    router: router)
                            store.subscribe(observer)
                            store.dispatch(actionType: .push(invalidJSONstring,
                                                             destination: .device,
                                                             deviceToken: "1234",
                                                             appBundleID: "com.myapp",
                                                             priority: 0,
                                                             collapseID: nil,
                                                             sandbox: true,
                                                             completion: { _ in
                                                             }))

                            expect(observer.errorState?.error as? PushTesterError).toEventually(equal(.invalidJson))
                        }
                    }
                }

                context("When the JSON string is valid") {
                    context("When APNS returns an error") {
                        it("should return error") {
                            var failure = false
                            let store = PusherStore(apnsPusher: failedAPNSMock,
                                                    router: router)

                            store.dispatch(actionType: .push(validJSONstring,
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
                            let store = PusherStore(apnsPusher: apnsPusherMock,
                                                    router: router)

                            store.dispatch(actionType: .push(validJSONstring,
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
}