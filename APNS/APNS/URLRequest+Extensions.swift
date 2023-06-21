import Foundation

enum HeaderFieldConstants {
    static let apnsPushType = "apns-push-type"
}

public enum APNsPushType {
    public static let liveActivity = "liveactivity"
}

extension URLRequest {
    /// Add push type for `apns-push-type` key in HTTP header only if it is not empty.
    mutating func add(pushType: String) {
        guard !pushType.isEmpty else {
            return
        }
        addValue(pushType, forHTTPHeaderField: HeaderFieldConstants.apnsPushType)
    }
}
