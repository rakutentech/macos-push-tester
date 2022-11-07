import Foundation
import APNS
import Quick
import Nimble
@testable import PusherMainView

// swiftlint:disable type_body_length
// swiftlint:disable function_body_length
final class PusherStoreSpec: QuickSpec {
    override func spec() {
        var router = RouterMock()
        let viewController = NSViewController()
        let fileName = "pusherfile.txt"
        let filePath = FileManager.default.currentDirectoryPath.appending("/\(fileName)")
        let fileURL: URL! = URL(string: "file://" + filePath)
        let invalidFileURL: URL! = URL(string: "invalid://" + filePath)
        let textToSave = "hello world"
        var observer = ObserverMock()
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
        let fcmPusherMock = FCMPusherMock(result: .success("OK"))
        let failedFCMPusherMock = FCMPusherMock(result: .failure(NSError(domain: "com.pusher.error",
                                                                         code: 400,
                                                                         userInfo: nil)))
        var store: PusherStore!
        let validJSONstring = #"{"":""}"#
        let invalidJSONstring = #"{]"#

        describe("PusherStore") {
            beforeEach {
                router = RouterMock()
                observer = ObserverMock()
                store = PusherStore(apnsPusher: apnsPusherMock, fcmPusher: fcmPusherMock, router: router)
            }
            afterEach {
                try? FileManager.default.removeItem(at: fileURL)
            }

            context("When a saveFileAs action is dispatched") {
                context("When the file URL is invalid") {
                    it("should return an error") {
                        router.fileURL = invalidFileURL

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
                        store.subscribe(observer)
                        store.dispatch(actionType: .saveFile(text: textToSave, fileURL: fileURL))

                        expect(observer.pusherState?.fileURL).toEventually(equal(fileURL))

                        expect(FileManager.default.fileExists(atPath: filePath)).to(beTrue())
                    }

                    it("should save the correct text") {
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
                        beforeEach {
                            store = PusherStore(apnsPusher: failedAPNSMock, fcmPusher: fcmPusherMock, router: router)
                        }

                        it("should return an error") {
                            store.subscribe(observer)
                            store.dispatch(actionType: .push(.apns(APNSPushData(payload: invalidJSONstring,
                                                                                destination: .iOSDevice,
                                                                                deviceToken: "1234",
                                                                                appBundleID: "com.myapp",
                                                                                priority: 0,
                                                                                collapseID: nil,
                                                                                sandbox: true,
                                                                                liveActivity: false)),
                                                              completion: { _ in
                                                              }))

                            expect(observer.errorState?.error as? PushTesterError).toEventually(equal(.invalidJson))
                        }
                    }

                    context("When APNS returns a success") {
                        it("should return an error") {
                            store.subscribe(observer)
                            store.dispatch(actionType: .push(.apns(APNSPushData(payload: invalidJSONstring,
                                                                                destination: .iOSDevice,
                                                                                deviceToken: "1234",
                                                                                appBundleID: "com.myapp",
                                                                                priority: 0,
                                                                                collapseID: nil,
                                                                                sandbox: true,
                                                                                liveActivity: false)),
                                                              completion: { _ in
                                                              }))

                            expect(observer.errorState?.error as? PushTesterError).toEventually(equal(.invalidJson))
                        }
                    }

                    context("When FCM returns an error") {
                        beforeEach {
                            store = PusherStore(apnsPusher: apnsPusherMock, fcmPusher: failedFCMPusherMock, router: router)
                        }

                        it("should return an error") {
                            store.subscribe(observer)
                            store.dispatch(actionType: .push(.fcm(FCMPushData(payload: invalidJSONstring,
                                                                              destination: .androidDevice,
                                                                              deviceToken: "1234",
                                                                              serverKey: "my.key",
                                                                              projectID: nil,
                                                                              collapseID: nil,
                                                                              legacyFCM: true)),
                                                              completion: { _ in
                                                              }))

                            expect(observer.errorState?.error as? PushTesterError).toEventually(equal(.invalidJson))
                        }
                    }

                    context("When FCM returns a success") {
                        it("should return an error") {
                            store.subscribe(observer)
                            store.dispatch(actionType: .push(.fcm(FCMPushData(payload: invalidJSONstring,
                                                                              destination: .androidDevice,
                                                                              deviceToken: "1234",
                                                                              serverKey: "my.key",
                                                                              projectID: nil,
                                                                              collapseID: nil,
                                                                              legacyFCM: true)),
                                                              completion: { _ in
                                                              }))

                            expect(observer.errorState?.error as? PushTesterError).toEventually(equal(.invalidJson))
                        }
                    }
                }

                context("When the JSON string is valid") {
                    context("When APNS returns an error") {
                        beforeEach {
                            store = PusherStore(apnsPusher: failedAPNSMock, fcmPusher: fcmPusherMock, router: router)
                        }

                        it("should return error") {
                            var failure = false

                            store.dispatch(actionType: .push(.apns(APNSPushData(payload: validJSONstring,
                                                                                destination: .iOSDevice,
                                                                                deviceToken: "1234",
                                                                                appBundleID: "com.myapp",
                                                                                priority: 0,
                                                                                collapseID: nil,
                                                                                sandbox: true,
                                                                                liveActivity: false)),
                                                              completion: { success in
                                                                  failure = !success
                                                              }))

                            expect(failure).toEventually(beTrue())
                        }
                    }

                    context("When APNS returns a success") {
                        it("should return success") {
                            var success = false

                            store.dispatch(actionType: .push(.apns(APNSPushData(payload: validJSONstring,
                                                                                destination: .iOSDevice,
                                                                                deviceToken: "1234",
                                                                                appBundleID: "com.myapp",
                                                                                priority: 0,
                                                                                collapseID: nil,
                                                                                sandbox: true,
                                                                                liveActivity: false)),
                                                             completion: { aSuccess in
                                                                 success = aSuccess
                                                             }))

                            expect(success).toEventually(beTrue())
                        }
                    }

                    context("When FCM returns an error") {
                        beforeEach {
                            store = PusherStore(apnsPusher: apnsPusherMock, fcmPusher: failedFCMPusherMock, router: router)
                        }

                        it("should return an error") {
                            var failure = false

                            store.dispatch(actionType: .push(.fcm(FCMPushData(payload: validJSONstring,
                                                                              destination: .androidDevice,
                                                                              deviceToken: "1234",
                                                                              serverKey: "my.key",
                                                                              projectID: nil,
                                                                              collapseID: nil,
                                                                              legacyFCM: true)),
                                                             completion: { success in
                                                                 failure = !success
                                                             }))

                            expect(failure).toEventually(beTrue())
                        }
                    }

                    context("When FCM returns a success") {
                        it("should return an error") {
                            var success = false

                            store.dispatch(actionType: .push(.fcm(FCMPushData(payload: validJSONstring,
                                                                              destination: .androidDevice,
                                                                              deviceToken: "1234",
                                                                              serverKey: "my.key",
                                                                              projectID: nil,
                                                                              collapseID: nil,
                                                                              legacyFCM: true)),
                                                             completion: { aSuccess in
                                                                 success = aSuccess
                                                             }))

                            expect(success).toEventually(beTrue())
                        }
                    }
                }

                context("and PushData is FCM type") {
                    context("and legacy mode is on") {
                        context("and device token is not provided") {

                            it("should return an error message when token is nil") {
                                var failure = false

                                store.dispatch(actionType: .push(.fcm(FCMPushData(payload: validJSONstring,
                                                                                  destination: .androidDevice,
                                                                                  deviceToken: nil,
                                                                                  serverKey: "my.key",
                                                                                  projectID: nil,
                                                                                  collapseID: nil,
                                                                                  legacyFCM: true)),
                                                                 completion: { success in
                                                                     failure = !success
                                                                 }))
                                expect(failure).toEventually(beTrue())
                                expect(router.lastMessage).to(equal("please.enter.a.device.token".localized))
                            }

                            it("should return an error message when token is empty") {
                                var failure = false

                                store.dispatch(actionType: .push(.fcm(FCMPushData(payload: validJSONstring,
                                                                                  destination: .androidDevice,
                                                                                  deviceToken: "",
                                                                                  serverKey: "my.key",
                                                                                  projectID: nil,
                                                                                  collapseID: nil,
                                                                                  legacyFCM: true)),
                                                                 completion: { success in
                                                                     failure = !success
                                                                 }))
                                expect(failure).toEventually(beTrue())
                                expect(router.lastMessage).to(equal("please.enter.a.device.token".localized))
                            }
                        }

                        context("and server key is not provided") {

                            it("should return an error message when server key is nil") {
                                var failure = false

                                store.dispatch(actionType: .push(.fcm(FCMPushData(payload: validJSONstring,
                                                                                  destination: .androidDevice,
                                                                                  deviceToken: "1234",
                                                                                  serverKey: nil,
                                                                                  projectID: nil,
                                                                                  collapseID: nil,
                                                                                  legacyFCM: true)),
                                                                 completion: { success in
                                                                     failure = !success
                                                                 }))
                                expect(failure).toEventually(beTrue())
                                expect(router.lastMessage).to(equal("please.enter.a.server.key".localized))
                            }

                            it("should return an error message when server key is empty") {
                                var failure = false

                                store.dispatch(actionType: .push(.fcm(FCMPushData(payload: validJSONstring,
                                                                                  destination: .androidDevice,
                                                                                  deviceToken: "1234",
                                                                                  serverKey: "",
                                                                                  projectID: nil,
                                                                                  collapseID: nil,
                                                                                  legacyFCM: true)),
                                                                 completion: { success in
                                                                     failure = !success
                                                                 }))
                                expect(failure).toEventually(beTrue())
                                expect(router.lastMessage).to(equal("please.enter.a.server.key".localized))
                            }
                        }

                        it("should succeed with other (not required) values set to nil") {
                            var success = false

                            store.dispatch(actionType: .push(.fcm(FCMPushData(payload: validJSONstring,
                                                                              destination: .androidDevice,
                                                                              deviceToken: "1234",
                                                                              serverKey: "my.key",
                                                                              projectID: nil,
                                                                              collapseID: nil,
                                                                              legacyFCM: true)),
                                                             completion: { aSuccess in
                                                                 success = aSuccess
                                                             }))
                            expect(success).toEventually(beTrue())
                        }
                    }

                    context("and legacy mode is off") {
                        context("and device token is not provided") {

                            it("should return an error message when token is nil") {
                                var failure = false

                                store.dispatch(actionType: .push(.fcm(FCMPushData(payload: validJSONstring,
                                                                                  destination: .androidDevice,
                                                                                  deviceToken: nil,
                                                                                  serverKey: "my.key",
                                                                                  projectID: "project.id",
                                                                                  collapseID: nil,
                                                                                  legacyFCM: false)),
                                                                 completion: { success in
                                                                     failure = !success
                                                                 }))
                                expect(failure).toEventually(beTrue())
                                expect(router.lastMessage).to(equal("please.enter.a.device.token".localized))
                            }

                            it("should return an error message when token is empty") {
                                var failure = false

                                store.dispatch(actionType: .push(.fcm(FCMPushData(payload: validJSONstring,
                                                                                  destination: .androidDevice,
                                                                                  deviceToken: "",
                                                                                  serverKey: "my.key",
                                                                                  projectID: "project.id",
                                                                                  collapseID: nil,
                                                                                  legacyFCM: false)),
                                                                 completion: { success in
                                                                     failure = !success
                                                                 }))
                                expect(failure).toEventually(beTrue())
                                expect(router.lastMessage).to(equal("please.enter.a.device.token".localized))
                            }
                        }

                        context("and server key is not provided") {

                            it("should return an error message when server key is nil") {
                                var failure = false

                                store.dispatch(actionType: .push(.fcm(FCMPushData(payload: validJSONstring,
                                                                                  destination: .androidDevice,
                                                                                  deviceToken: "1234",
                                                                                  serverKey: nil,
                                                                                  projectID: "project.id",
                                                                                  collapseID: nil,
                                                                                  legacyFCM: false)),
                                                                 completion: { success in
                                                                     failure = !success
                                                                 }))
                                expect(failure).toEventually(beTrue())
                                expect(router.lastMessage).to(equal("please.enter.a.server.key".localized))
                            }

                            it("should return an error message when server key is empty") {
                                var failure = false

                                store.dispatch(actionType: .push(.fcm(FCMPushData(payload: validJSONstring,
                                                                                  destination: .androidDevice,
                                                                                  deviceToken: "1234",
                                                                                  serverKey: "",
                                                                                  projectID: "project.id",
                                                                                  collapseID: nil,
                                                                                  legacyFCM: false)),
                                                                 completion: { success in
                                                                     failure = !success
                                                                 }))
                                expect(failure).toEventually(beTrue())
                                expect(router.lastMessage).to(equal("please.enter.a.server.key".localized))
                            }
                        }

                        context("and project id key is not provided") {

                            it("should return an error message when project id is nil") {
                                var failure = false

                                store.dispatch(actionType: .push(.fcm(FCMPushData(payload: validJSONstring,
                                                                                  destination: .androidDevice,
                                                                                  deviceToken: "1234",
                                                                                  serverKey: "my.key",
                                                                                  projectID: nil,
                                                                                  collapseID: nil,
                                                                                  legacyFCM: false)),
                                                                 completion: { success in
                                                                     failure = !success
                                                                 }))
                                expect(failure).toEventually(beTrue())
                                expect(router.lastMessage).to(equal("please.enter.firebase.project.id".localized))
                            }

                            it("should return an error message when project id is empty") {
                                var failure = false

                                store.dispatch(actionType: .push(.fcm(FCMPushData(payload: validJSONstring,
                                                                                  destination: .androidDevice,
                                                                                  deviceToken: "1234",
                                                                                  serverKey: "my.key",
                                                                                  projectID: "",
                                                                                  collapseID: nil,
                                                                                  legacyFCM: false)),
                                                                 completion: { success in
                                                                     failure = !success
                                                                 }))
                                expect(failure).toEventually(beTrue())
                                expect(router.lastMessage).to(equal("please.enter.firebase.project.id".localized))
                            }
                        }

                        it("should succeed with other (not required) values set to nil") {
                            var success = false

                            store.dispatch(actionType: .push(.fcm(FCMPushData(payload: validJSONstring,
                                                                              destination: .androidDevice,
                                                                              deviceToken: "1234",
                                                                              serverKey: "my.key",
                                                                              projectID: "project.id",
                                                                              collapseID: nil,
                                                                              legacyFCM: false)),
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
