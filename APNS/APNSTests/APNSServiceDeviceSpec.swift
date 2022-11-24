import Foundation
import Quick
import Nimble
@testable import APNS

final class APNSServiceDeviceSpec: QuickSpec {
    override func spec() {
        describe("APNSServiceDeviceSpec") {
            it("should equal when the two instances have the same values") {
                let apnsServiceDevice1 = APNSServiceDevice(displayName: "John iPhone 001", token: "0123456789", appID: "com.myapp", type: "APNS")
                let apnsServiceDevice2 = APNSServiceDevice(displayName: "John iPhone 001", token: "0123456789", appID: "com.myapp", type: "APNS")
                expect(apnsServiceDevice1).to(equal(apnsServiceDevice2))
            }

            it("should not equal when token is different") {
                let apnsServiceDevice1 = APNSServiceDevice(displayName: "John iPhone 001", token: "0123456789", appID: "com.myapp", type: "APNS")
                let apnsServiceDevice2 = APNSServiceDevice(displayName: "John iPhone 001", token: "0123456781", appID: "com.myapp", type: "APNS")
                expect(apnsServiceDevice1).toNot(equal(apnsServiceDevice2))
            }

            it("should not equal when displayName is different") {
                let apnsServiceDevice1 = APNSServiceDevice(displayName: "John iPhone 001", token: "0123456789", appID: "com.myapp", type: "APNS")
                let apnsServiceDevice2 = APNSServiceDevice(displayName: "John iPhone 002", token: "0123456789", appID: "com.myapp", type: "APNS")
                expect(apnsServiceDevice1).toNot(equal(apnsServiceDevice2))
            }

            it("should not equal when appID is different") {
                let apnsServiceDevice1 = APNSServiceDevice(displayName: "John iPhone 001", token: "0123456789", appID: "com.myapp", type: "APNS")
                let apnsServiceDevice2 = APNSServiceDevice(displayName: "John iPhone 001", token: "0123456789", appID: "com.myapp2", type: "APNS")
                expect(apnsServiceDevice1).toNot(equal(apnsServiceDevice2))
            }

            it("should not equal when displayName and token are different") {
                let apnsServiceDevice1 = APNSServiceDevice(displayName: "John iPhone 001", token: "0123456789", appID: "com.myapp", type: "APNS")
                let apnsServiceDevice2 = APNSServiceDevice(displayName: "John iPhone 002", token: "0123456781", appID: "com.myapp", type: "APNS")
                expect(apnsServiceDevice1).toNot(equal(apnsServiceDevice2))
            }

            it("should not equal when displayName and appID are different") {
                let apnsServiceDevice1 = APNSServiceDevice(displayName: "John iPhone 001", token: "0123456789", appID: "com.myapp", type: "APNS")
                let apnsServiceDevice2 = APNSServiceDevice(displayName: "John iPhone 002", token: "0123456789", appID: "com.myapp2", type: "APNS")
                expect(apnsServiceDevice1).toNot(equal(apnsServiceDevice2))
            }

            it("should not equal when token and appID are different") {
                let apnsServiceDevice1 = APNSServiceDevice(displayName: "John iPhone 001", token: "0123456789", appID: "com.myapp", type: "APNS")
                let apnsServiceDevice2 = APNSServiceDevice(displayName: "John iPhone 001", token: "0123456781", appID: "com.myapp2", type: "APNS")
                expect(apnsServiceDevice1).toNot(equal(apnsServiceDevice2))
            }
        }
    }
}
