import Foundation

public protocol FCMPushable {
    func pushUsingLegacyEndpoint(_ token: String,
                                 payload: [String: Any],
                                 collapseID: String?,
                                 serverKey: String,
                                 completion: @escaping (Result<String, Error>) -> Void)
    func pushUsingV1Endpoint(_ token: String,
                             payload: [String: Any],
                             collapseID: String?,
                             serverKey: String,
                             projectID: String,
                             completion: @escaping (Result<String, Error>) -> Void)
}

public final class FCMPusher: FCMPushable {
    private let session: URLSession

    public init(session: URLSession = URLSession(configuration: .ephemeral,
                                                 delegate: nil,
                                                 delegateQueue: .main)) {
        self.session = session
    }

    public func pushUsingLegacyEndpoint(_ token: String,
                                        payload: [String: Any],
                                        collapseID: String?,
                                        serverKey: String,
                                        completion: @escaping (Result<String, Error>) -> Void) {

        guard let url = URL(string: "https://fcm.googleapis.com/fcm/send") else {
            completion(.failure(NSError(domain: "com.pusher.FCMPusher",
                                        code: 0,
                                        userInfo: [NSLocalizedDescriptionKey: "URL error"])))
            return
        }

        var updatedPayload = payload
        if let collapseID = collapseID, !collapseID.isEmpty {
            updatedPayload["collapse_key"] = collapseID
        }
        // put device token in the payload if it's not defined
        if updatedPayload["to"] == nil {
            updatedPayload["to"] = token
        }

        guard let httpBody = try? JSONSerialization.data(withJSONObject: updatedPayload, options: .prettyPrinted) else {
            completion(.failure(NSError(domain: "com.pusher.FCMPusher",
                                        code: 0,
                                        userInfo: [NSLocalizedDescriptionKey: "Payload error"])))
            return
        }

        let request = URLRequest.fcmRequest(url: url, httpBody: httpBody, authHeaderValue: "key=\(serverKey)")

        session.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error as NSError))
                }
                return
            }

            guard let r = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "com.pusher.FCMPusher",
                                                code: 0,
                                                userInfo: [NSLocalizedDescriptionKey: "Unknown error"])))
                }
                return
            }

            switch r.statusCode {
            case 200:
                guard let data = data,
                      let responseData = try? JSONDecoder().decode(FCMLegacyResponse.self, from: data) else {
                    DispatchQueue.main.async {
                        completion(.failure(NSError(domain: "com.pusher.FCMPusher",
                                                    code: r.statusCode,
                                                    userInfo: [NSLocalizedDescriptionKey: "Cannot parse response data (200)"])))
                    }
                    return
                }

                guard responseData.failure == 0 else {
                    let results = FCMLegacyResponse.parseResults(data: data) ?? []
                    DispatchQueue.main.async {
                        completion(.failure(NSError(
                            domain: "com.pusher.FCMPusher",
                            code: r.statusCode,
                            userInfo: [NSLocalizedDescriptionKey: "Failures: \(responseData.failure)\n\(results)"])))
                    }
                    return
                }

                DispatchQueue.main.async {
                    completion(.success(HTTPURLResponse.localizedString(forStatusCode: r.statusCode)))
                }

            default:
                if let data = data,
                   let html = String(data: data, encoding: .utf8) {
                    DispatchQueue.main.async {
                        completion(.failure(NSError(domain: "com.pusher.FCMPusher",
                                                    code: r.statusCode,
                                                    userInfo: [NSLocalizedDescriptionKey: html.slice(between: "<TITLE>", and: "</TITLE>")])))
                    }

                } else {
                    DispatchQueue.main.async {
                        let error = NSError(domain: "com.pusher.FCMPusher",
                                            code: r.statusCode,
                                            userInfo: [NSLocalizedDescriptionKey: HTTPURLResponse.localizedString(forStatusCode: r.statusCode)])
                        completion(.failure(error))
                    }
                }
            }
        }.resume()
    }

    public func pushUsingV1Endpoint(_ token: String,
                                    payload: [String: Any],
                                    collapseID: String?,
                                    serverKey: String,
                                    projectID: String,
                                    completion: @escaping (Result<String, Error>) -> Void) {

        guard let url = URL(string: "https://fcm.googleapis.com/v1/projects/\(projectID)/messages:send") else {
            completion(.failure(NSError(domain: "com.pusher.FCMPusher",
                                        code: 0,
                                        userInfo: [NSLocalizedDescriptionKey: "URL error"])))
            return
        }

        var updatedPayload = payload
        if let collapseID = collapseID, !collapseID.isEmpty {
            updatedPayload["collapse_key"] = collapseID
        }
        // put device token in the payload if it's not defined
        if var messageBody = updatedPayload["message"] as? [String: Any] {
            if messageBody["token"] == nil {
                messageBody["token"] = token
                updatedPayload["message"] = messageBody
            }
        }

        guard let httpBody = try? JSONSerialization.data(withJSONObject: updatedPayload, options: .prettyPrinted) else {
            completion(.failure(NSError(domain: "com.pusher.FCMPusher",
                                        code: 0,
                                        userInfo: [NSLocalizedDescriptionKey: "Payload error"])))
            return
        }

        let request = URLRequest.fcmRequest(url: url, httpBody: httpBody, authHeaderValue: "Bearer \(serverKey)")

        session.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error as NSError))
                }
                return
            }

            guard let r = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "com.pusher.FCMPusher",
                                                code: 0,
                                                userInfo: [NSLocalizedDescriptionKey: "Unknown error"])))
                }
                return
            }

            switch r.statusCode {
            case 200:
                DispatchQueue.main.async {
                    completion(.success(HTTPURLResponse.localizedString(forStatusCode: r.statusCode)))
                }

            default:
                if let data = data,
                   let json = try? JSONDecoder().decode([String: FCMRequestError?].self, from: data),
                   let error = json["error"] as? FCMRequestError {
                    DispatchQueue.main.async {
                        completion(.failure(NSError(domain: "com.pusher.FCMPusher",
                                                    code: r.statusCode,
                                                    userInfo: [NSLocalizedDescriptionKey: "\(error.status)\n\(error.message)"])))
                    }

                } else {
                    DispatchQueue.main.async {
                        let error = NSError(domain: "com.pusher.FCMPusher",
                                            code: r.statusCode,
                                            userInfo: [NSLocalizedDescriptionKey: HTTPURLResponse.localizedString(forStatusCode: r.statusCode)])
                        completion(.failure(error))
                    }
                }
            }
        }.resume()
    }
}

struct FCMRequestError: Decodable {
    let message: String
    let status: String
    let code: Int
}

struct FCMLegacyResponse: Decodable {
    let success: Int
    let failure: Int

    static func parseResults(data: Data) -> [[String: Any]]? {
        let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        return json?["results"] as? [[String: Any]]
    }
}
