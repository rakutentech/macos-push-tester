import XCTest
@testable import APNS

class APNSTests: XCTestCase {
    func testAPNSServiceDevice() {
        var apnsServiceDevice1 = APNSServiceDevice(displayName: "John iPhone 001", token: "0123456789")
        var apnsServiceDevice2 = APNSServiceDevice(displayName: "John iPhone 001", token: "0123456789")
        XCTAssertEqual(apnsServiceDevice1, apnsServiceDevice2)
        
        apnsServiceDevice1 = APNSServiceDevice(displayName: "John iPhone 001", token: "0123456789")
        apnsServiceDevice2 = APNSServiceDevice(displayName: "John iPhone 001", token: "0123456781")
        XCTAssertNotEqual(apnsServiceDevice1, apnsServiceDevice2)
        
        apnsServiceDevice1 = APNSServiceDevice(displayName: "John iPhone 001", token: "0123456789")
        apnsServiceDevice2 = APNSServiceDevice(displayName: "John iPhone 002", token: "0123456781")
        XCTAssertNotEqual(apnsServiceDevice1, apnsServiceDevice2)
        
        apnsServiceDevice1 = APNSServiceDevice(displayName: "John iPhone 001", token: "0123456789")
        apnsServiceDevice2 = APNSServiceDevice(displayName: "John iPhone 001", token: "0123456781")
        XCTAssertNotEqual(apnsServiceDevice1, apnsServiceDevice2)
    }
}
