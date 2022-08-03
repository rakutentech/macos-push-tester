import Foundation

extension String {
    /// - Returns: a slice of text between two subtrings.
    /// In case one of provided strings is a not substring, the function returns the whole string.
    func slice(between leftBound: String, and rightBound: String) -> String {
        guard let leftBoundRange = range(of: leftBound),
              let rightBoundRange = range(of: rightBound, options: .backwards) else {
            return self
        }
        return String(self[leftBoundRange.upperBound..<rightBoundRange.lowerBound])
    }
}
