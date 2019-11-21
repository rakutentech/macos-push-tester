import XCTest
@testable import APNS

class APNSTests: XCTestCase {
    func testAPNSServiceDevice() {
        var apnsServiceDevice1 = APNSServiceDevice(displayName: "John iPhone 001", token: "0123456789", appID: "com.myapp")
        var apnsServiceDevice2 = APNSServiceDevice(displayName: "John iPhone 001", token: "0123456789", appID: "com.myapp")
        XCTAssertEqual(apnsServiceDevice1, apnsServiceDevice2)
        
        apnsServiceDevice1 = APNSServiceDevice(displayName: "John iPhone 001", token: "0123456789", appID: "com.myapp")
        apnsServiceDevice2 = APNSServiceDevice(displayName: "John iPhone 001", token: "0123456781", appID: "com.myapp")
        XCTAssertNotEqual(apnsServiceDevice1, apnsServiceDevice2)
        
        apnsServiceDevice1 = APNSServiceDevice(displayName: "John iPhone 001", token: "0123456789", appID: "com.myapp")
        apnsServiceDevice2 = APNSServiceDevice(displayName: "John iPhone 002", token: "0123456789", appID: "com.myapp")
        XCTAssertNotEqual(apnsServiceDevice1, apnsServiceDevice2)
        
        apnsServiceDevice1 = APNSServiceDevice(displayName: "John iPhone 001", token: "0123456789", appID: "com.myapp")
        apnsServiceDevice2 = APNSServiceDevice(displayName: "John iPhone 002", token: "0123456781", appID: "com.myapp")
        XCTAssertNotEqual(apnsServiceDevice1, apnsServiceDevice2)
    }
}
