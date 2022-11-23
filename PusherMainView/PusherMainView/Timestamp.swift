import Foundation

enum Timestamp {
    /// - Returns: the current timestamp integer value.
    static var current: Int {
        Int(Date().timeIntervalSince1970)
    }
}
