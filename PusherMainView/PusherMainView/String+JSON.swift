import Foundation

extension String {
    /// - Returns: true if the JSON is valid, `false` otherwise.
    var isValidJSON: Bool {
        guard let jsonData = data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: [])
        else {
            return false
        }

        return JSONSerialization.isValidJSONObject(jsonObject)
    }
}
