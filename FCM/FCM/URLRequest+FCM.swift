import Foundation

extension URLRequest {

    static func fcmRequest(url: URL, httpBody: Data, authHeaderValue: String) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(authHeaderValue, forHTTPHeaderField: "Authorization")
        request.httpBody = httpBody
        return request
    }
}
