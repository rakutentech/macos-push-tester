import Foundation

extension String {
    /// - Returns: true if the JSON is valid, `false` otherwise.
    func validateJSON() throws {
        let jsonData = data(using: .utf8) ?? Data()
        do {
            try JSONSerialization.jsonObject(with: jsonData, options: [])
        } catch {
            let nsError = error as NSError
            var userInfo = nsError.userInfo
            userInfo[NSLocalizedDescriptionKey] = userInfo[NSDebugDescriptionErrorKey]
            throw NSError(domain: nsError.domain, code: nsError.code, userInfo: userInfo)
        }
    }

    var isDefaultPayload: Bool {
        [DefaultPayloads.apns, DefaultPayloads.fcmLegacy, DefaultPayloads.fcmV1].contains(self)
    }
}
