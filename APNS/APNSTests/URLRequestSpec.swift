import Foundation
import Quick
import Nimble
@testable import APNS

final class URLRequestSpec: QuickSpec {
    override func spec() {
        describe("URLRequest") {
            let url: URL! = URL(string: "https://test.com")
            var urlRequest: URLRequest!

            beforeEach {
                urlRequest = URLRequest(url: url)
            }

            context("When APNs push type is empty string value") {
                it("should not set apns-push-type header field") {
                    urlRequest.add(pushType: "")

                    let value = urlRequest.value(forHTTPHeaderField: HeaderFieldConstants.apnsPushType)
                    expect(value).to(beNil())
                }
            }

            context("When APNs push type is alert") {
                it("should set apns-push-type header field to alert") {
                    urlRequest.add(pushType: "alert")

                    let value = urlRequest.value(forHTTPHeaderField: HeaderFieldConstants.apnsPushType)
                    expect(value).to(equal("alert"))
                }
            }

            context("When APNs push type is background") {
                it("should set apns-push-type header field to background") {
                    urlRequest.add(pushType: "background")

                    let value = urlRequest.value(forHTTPHeaderField: HeaderFieldConstants.apnsPushType)
                    expect(value).to(equal("background"))
                }
            }

            context("When APNs push type is liveactivity") {
                it("should set apns-push-type header field to liveactivity") {
                    urlRequest.add(pushType: "liveactivity")

                    let value = urlRequest.value(forHTTPHeaderField: HeaderFieldConstants.apnsPushType)
                    expect(value).to(equal("liveactivity"))
                }
            }
        }
    }
}
