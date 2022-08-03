import Foundation

protocol FCMPushable {
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

class FCMPusher: FCMPushable {
    let session = URLSession(configuration: .ephemeral,
                             delegate: nil,
                             delegateQueue: .main)

    func pushUsingLegacyEndpoint(_ token: String,
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
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("key=\(serverKey)", forHTTPHeaderField: "Authorization")

        updatedPayload["to"] = token
        if let collapseID = collapseID {
            updatedPayload["collapse_key"] = collapseID
        }

        guard let httpBody = try? JSONSerialization.data(withJSONObject: payload, options: .prettyPrinted) else {
            completion(.failure(NSError(domain: "com.pusher.FCMPusher",
                                        code: 0,
                                        userInfo: [NSLocalizedDescriptionKey: "Payload error"])))
            return
        }

        request.httpBody = httpBody

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

    func pushUsingV1Endpoint(_ token: String,
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
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(serverKey)", forHTTPHeaderField: "Authorization")

        updatedPayload["token"] = token
        if let collapseID = collapseID {
            updatedPayload["collapse_key"] = collapseID
        }

        guard let httpBody = try? JSONSerialization.data(withJSONObject: ["message": payload], options: .prettyPrinted) else {
            completion(.failure(NSError(domain: "com.pusher.FCMPusher",
                                        code: 0,
                                        userInfo: [NSLocalizedDescriptionKey: "Payload error"])))
            return
        }

        request.httpBody = httpBody

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
