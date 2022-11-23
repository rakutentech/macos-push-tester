import Foundation
import Quick
import Nimble
@testable import PusherMainView

final class DictionarySpec: QuickSpec {
    override func spec() {
        describe("Dictionary") {
            describe("update(with:)") {
                it("should update the dictionary with the expected timestamp") {
                    var apnsPayload: [String: Any] = ["aps": ["timestamp": 1669202700]]
                    apnsPayload.update(with: 1669202821)

                    let aps = apnsPayload["aps"] as? [String: Int]

                    expect(aps?["timestamp"]).to(equal(1669202821))
                }
            }
        }
    }
}
