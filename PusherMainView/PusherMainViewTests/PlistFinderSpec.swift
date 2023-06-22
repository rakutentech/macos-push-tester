import Foundation
import Quick
import Nimble
@testable import PusherMainView

final class PlistFinderSpec: QuickSpec {
    override func spec() {
        describe("PlistFinder") {
            describe("model(for:and:)") {
                context("When plist is pushtypes and type is PushTypesViewController") {
                    it("should return the array of expected push types") {
                        let pushTypes = PlistFinder<[String]>.model(for: "pushtypes", and: PushTypesViewController.self)
                        expect(pushTypes).to(equal(["alert", "background", "liveactivity"]))
                    }
                }
            }
        }
    }
}
