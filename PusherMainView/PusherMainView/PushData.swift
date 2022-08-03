import Foundation

struct PushData: Equatable {
    let payload: String
    let destination: Destination
    let deviceToken: String?
    let serverKey: String?
    let appBundleID: String?
    let projectID: String?
    let priority: Int
    let collapseID: String?
    let sandbox: Bool
    let legacyFCM: Bool

    static func apnsData(payload: String,
                         destination: Destination,
                         deviceToken: String?,
                         appBundleID: String?,
                         priority: Int,
                         collapseID: String?,
                         sandbox: Bool) -> PushData {
        PushData(payload: payload,
                 destination: destination,
                 deviceToken: deviceToken,
                 serverKey: nil,
                 appBundleID: appBundleID,
                 projectID: nil,
                 priority: priority,
                 collapseID: collapseID,
                 sandbox: sandbox,
                 legacyFCM: false)
    }

    static func fcmData(payload: String,
                        destination: Destination,
                        deviceToken: String?,
                        serverKey: String?,
                        projectID: String?,
                        collapseID: String?,
                        legacyFCM: Bool) -> PushData {
        PushData(payload: payload,
                 destination: destination,
                 deviceToken: deviceToken,
                 serverKey: serverKey,
                 appBundleID: nil,
                 projectID: projectID,
                 priority: 5,
                 collapseID: collapseID,
                 sandbox: false,
                 legacyFCM: legacyFCM)
    }
}
