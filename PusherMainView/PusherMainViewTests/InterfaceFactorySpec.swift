import Foundation
import Quick
import Nimble
@testable import PusherMainView

final class InterfaceFactorySpec: QuickSpec {
    override func spec() {
        describe("InterfaceFactory") {
            describe("create(for:)") {
                context("When the given type is PushTypesViewController") {
                    it("should create PushTypesViewController instance") {
                        let viewController = InterfaceFactory<PushTypesViewController>.create(for: "Pusher")
                        expect(viewController).toNot(beNil())
                    }
                }
            }
        }
    }
}
