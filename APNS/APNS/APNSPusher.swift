import Cocoa
import Foundation
import CupertinoJWT

public enum APNSPusherType {
    case none, certificate(identity: SecIdentity), token(keyID: String, teamID: String, p8: String)
}

public protocol APNSPushable {
    var type: APNSPusherType { get set }
    var identity: SecIdentity? { get }
    func pushToDevice(_ token: String, payload: [String: Any], withTopic topic: String?, priority: Int, collapseID: String?, inSandbox sandbox: Bool, isLiveActivity liveActivity: Bool, completion: @escaping (Result<String, Error>) -> Void)
    func pushToSimulator(payload: String,
                         appBundleID bundleID: String,
                         completion: @escaping (Result<String, Error>) -> Void)
}

public final class APNSPusher: NSObject, APNSPushable {
    public var type: APNSPusherType {
        didSet {
            switch type {
            case .certificate(let _identity):
                identity = _identity
                session = URLSession(configuration: .ephemeral,
                                     delegate: self,
                                     delegateQueue: .main)
            case .token:
                session = URLSession(configuration: .ephemeral,
                                     delegate: nil,
                                     delegateQueue: .main)
            case .none: ()
            }
        }
    }
    private var _identity: SecIdentity?
    private var session: URLSession?
    private var cachedProviders = Set<APNSProvider>()

    public private(set) var identity: SecIdentity? {
        get {
            return _identity
        }

        set(value) {
            if _identity != value {
                if _identity != nil {
                    _identity = nil
                }

                if value != nil {
                    _identity = value

                } else {
                    _identity = nil
                }
            }
        }
    }

    public override init() {
        self.type = .none
        super.init()
    }

    public func pushToDevice(_ token: String, payload: [String: Any], withTopic topic: String?, priority: Int, collapseID: String?, inSandbox sandbox: Bool, isLiveActivity liveActivity: Bool, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "https://api\(sandbox ? ".development" : "").push.apple.com/3/device/\(token)") else {
            completion(.failure(NSError(domain: "com.pusher.APNSPusher",
                                        code: 0,
                                        userInfo: [NSLocalizedDescriptionKey: "URL error"])))
            return
        }

				var payload = payload
				if liveActivity {
					payload["timestamp"] = Date().timeIntervalSince1970
				}

        guard let httpBody = try? JSONSerialization.data(withJSONObject: payload, options: .prettyPrinted) else {
            completion(.failure(NSError(domain: "com.pusher.APNSPusher",
                                        code: 0,
                                        userInfo: [NSLocalizedDescriptionKey: "Payload error"])))
            return
        }

        var request = URLRequest(url: url)

        request.httpMethod = "POST"

        request.httpBody = httpBody

				var correctTopic = topic
				if liveActivity {
					request.addValue("liveactivity", forHTTPHeaderField: "apns-push-type")
					let suffix = ".push-type.liveactivity"
					if !(correctTopic?.hasSuffix(suffix) ?? true) {
						correctTopic = correctTopic?.appending(suffix)
					}
				}

        if let topic = correctTopic {
            request.addValue(topic, forHTTPHeaderField: "apns-topic")
        }

        if let collapseID = collapseID, !collapseID.isEmpty {
            request.addValue(collapseID, forHTTPHeaderField: "apns-collapse-id")
        }

        request.addValue("\(priority)", forHTTPHeaderField: "apns-priority")

        // encode Apple Developer account as a APNs Provider Token in the authorization header
        if case .token(let keyID, let teamID, let p8) = type,
           let provider = APNSProvider(keyID: keyID, teamID: teamID, p8Digest: p8) {
            /// reuse same digest for up to `providerTokenTTL` as per APNs server spec
            if let lastProvider = cachedProviders.first(where: { $0 == provider }), lastProvider.isValid {
                request.addValue("bearer \(lastProvider)", forHTTPHeaderField: "authorization")
            } else {
                cachedProviders.update(with: provider)
                request.addValue("bearer \(provider)", forHTTPHeaderField: "authorization")
            }
        }

        session?.dataTask(with: request, completionHandler: { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error as NSError))
                }
                return
            }

            guard let r = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "com.pusher.APNSPusher",
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
                   let dict = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments),
                   let json = dict as? [String: Any],
                   let reason = json["reason"] as? String {
                    DispatchQueue.main.async {
                        completion(.failure(NSError(domain: "com.pusher.APNSPusher",
                                                    code: r.statusCode,
                                                    userInfo: [NSLocalizedDescriptionKey: reason])))
                    }

                } else {
                    DispatchQueue.main.async {
                        let error = NSError(domain: "com.pusher.APNSPusher",
                                            code: r.statusCode,
                                            userInfo: [NSLocalizedDescriptionKey: HTTPURLResponse.localizedString(forStatusCode: r.statusCode)])
                        completion(.failure(error))
                    }
                }
            }
        }).resume()
    }

    public func pushToSimulator(payload: String, appBundleID bundleID: String, completion: @escaping (Result<String, Error>) -> Void) {

        guard let payloadData = payload.data(using: .utf8), (try? JSONSerialization.jsonObject(with: payloadData)) != nil else {
            completion(.failure(NSError(domain: "com.pusher.APNSPusher",
                                        code: 0,
                                        userInfo: [NSLocalizedDescriptionKey: "Invalid JSON format"])))
            return
        }

        let bundleCheckResult = ShellRunner.run(command: "xcrun simctl get_app_container booted \(bundleID)")
        if case .failure = bundleCheckResult {
            completion(.failure(NSError(domain: "com.pusher.APNSPusher",
                                        code: 0,
                                        userInfo: [NSLocalizedDescriptionKey: "Cannot find provided bundle ID in booted simulator"])))
            return
        }

        let result = ShellRunner.run(command: "printf '\(payload)' | xcrun simctl push booted \(bundleID) -")

        switch result {
        case .failure(let error):
            switch error {
            case .commandError(let message):
                completion(.failure(NSError(domain: "com.pusher.APNSPusher",
                                            code: 0,
                                            userInfo: [NSLocalizedDescriptionKey: message])))
            case .taskInitError(let initError):
                completion(.failure(NSError(domain: "com.pusher.APNSPusher",
                                            code: 0,
                                            userInfo: [NSLocalizedDescriptionKey: initError.localizedDescription])))
            case .unknown:
                completion(.failure(NSError(domain: "com.pusher.APNSPusher",
                                            code: 0,
                                            userInfo: [NSLocalizedDescriptionKey: "Unknown error"])))
            }
            return
        case .success(let message):
            completion(.success(message))
        }
    }
}

extension APNSPusher: URLSessionDelegate {
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard let identityNotNil = _identity else {
            return
        }
        var certificate: SecCertificate?

        SecIdentityCopyCertificate(identityNotNil, &certificate)

        guard let cert = certificate else {
            return
        }

        let cred = URLCredential(identity: identityNotNil, certificates: [cert], persistence: .forSession)

        certificate = nil

        completionHandler(.useCredential, cred)
    }
}

// MARK: - APNSProvider

private struct APNSProvider {
    private let keyID: String
    private let teamID: String
    private let p8Digest: String
    private let authToken: String
    private let timestamp = Date()
    /// 20 min to resolve
    /// [TooManyProviderTokenUpdates](https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server/handling_notification_responses_from_apns)
    private let providerTokenTTL: TimeInterval = 60 * 20

    init?(keyID: String, teamID: String, p8Digest: String) {
        guard let authToken = try? JWT(keyID: keyID,
                                       teamID: teamID,
                                       issueDate: timestamp,
                                       expireDuration: providerTokenTTL).sign(with: p8Digest) else {
            return nil
        }
        self.authToken = authToken
        self.keyID = keyID
        self.teamID = teamID
        self.p8Digest = p8Digest
    }

    var isValid: Bool {
        Date().timeIntervalSince(timestamp) < providerTokenTTL
    }
}
extension APNSProvider: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.keyID == rhs.keyID && lhs.teamID == rhs.teamID && lhs.p8Digest == rhs.p8Digest
    }
}
extension APNSProvider: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(keyID)
        hasher.combine(teamID)
        hasher.combine(p8Digest)
    }
}
extension APNSProvider: CustomStringConvertible {
    var description: String {
        authToken
    }
}
