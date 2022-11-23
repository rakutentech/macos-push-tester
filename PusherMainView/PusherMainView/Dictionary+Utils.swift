import Foundation

extension [String: Any] {
    /// Update the APNS Payload with a timestamp.
    ///
    /// - Parameter timestamp: the timestamp to update.
    mutating func update(with timestamp: Int) {
        var aps = self["aps"] as? [String: Any]
        aps?["timestamp"] = timestamp
        self["aps"] = aps
    }
}
