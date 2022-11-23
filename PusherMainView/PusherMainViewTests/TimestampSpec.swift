import Foundation
import Quick
import Nimble
@testable import PusherMainView

final class TimestampSpec: QuickSpec {
    override func spec() {
        describe("Timestamp") {
            describe("current") {
                it("should return the current time integer value") {
                    expect(Timestamp.current).to(equal(Int(Date().timeIntervalSince1970)))
                }
            }
        }
    }
}
