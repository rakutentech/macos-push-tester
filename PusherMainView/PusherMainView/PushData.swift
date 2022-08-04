import Foundation

enum PushData: Equatable {
    case apns(_ data: APNSPushData)
    case fcm(_ data: FCMPushData)

    var payload: String {
        switch self {
        case .apns(let data):
            return data.payload
        case .fcm(let data):
            return data.payload
        }
    }
}

struct APNSPushData: Equatable {
    let payload: String
    let destination: Destination
    let deviceToken: String?
    let appBundleID: String?
    let priority: Int
    let collapseID: String?
    let sandbox: Bool
}

struct FCMPushData: Equatable {
    let payload: String
    let destination: Destination
    let deviceToken: String?
    let serverKey: String?
    let projectID: String?
    let collapseID: String?
    let legacyFCM: Bool
}
