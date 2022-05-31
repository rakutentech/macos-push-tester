import Foundation
import APNS

enum ActionType {
    case configure
    case devicesList(fromViewController: NSViewController)
    case deviceToken(String)
    case chooseAuthToken(fromViewController: NSViewController)
    case alert(message: String, fromWindow: NSWindow?)
    case browsingFiles(fromViewController: NSViewController, completion: (_ fileURL: URL) -> Void)
    case browsingJSONFiles(fromViewController: NSViewController, completion: (_ fileURL: URL, _ text: String) -> Void)
    case selectDevice(device: APNSServiceDevice)
    case chooseSimulator
    case chooseDevice
    case cancelAuthToken
    case saveAuthToken(teamID: String, keyID: String, p8FileURL: URL, p8: String)
    case chooseIdentity(fromViewController: NSViewController)
    case cancelIdentity
    case updateIdentity(identity: SecIdentity)
    case dismiss(fromViewController: NSViewController)
    case push(_ payloadString: String,
              destination: Destination,
              deviceToken: String?,
              appBundleID: String?,
              priority: Int,
              collapseID: String?,
              sandbox: Bool,
              completion: (Bool) -> Void)
    case chooseFile
    case saveFile(text: String, fileURL: URL)
    case payloadDidChange(fileURL: URL?)
}

extension ActionType: Equatable {
    static func == (lhs: ActionType, rhs: ActionType) -> Bool {
        switch (lhs, rhs) {
        case (.configure, .configure):
            return true

        case (let .devicesList(lhsViewController), let .devicesList(rhsViewController)):
            return lhsViewController == rhsViewController

        case (let .deviceToken(lhsString), let .deviceToken(rhsString)):
            return lhsString == rhsString

        case (let .chooseAuthToken(lhsViewController), let .chooseAuthToken(rhsViewController)):
            return lhsViewController == rhsViewController

        case (let .alert(lhsString, lhsWindow), let .alert(rhsString, rhsWindow)):
            return lhsString == rhsString && lhsWindow == rhsWindow

        case (let .browsingFiles(lhsViewController, _), let .browsingFiles(rhsViewController, _)):
            return lhsViewController == rhsViewController

        case (let .browsingJSONFiles(lhsViewController, _), let .browsingJSONFiles(rhsViewController, _)):
            return lhsViewController == rhsViewController

        case (let .selectDevice(lhsAPNSServiceDevice), let .selectDevice(rhsAPNSServiceDevice)):
            return lhsAPNSServiceDevice == rhsAPNSServiceDevice

        case (.chooseSimulator, .chooseSimulator):
            return true

        case (.chooseDevice, .chooseDevice):
            return true

        case (.cancelAuthToken, .cancelAuthToken):
            return true

        case (let .saveAuthToken(lhs1, lhs2, lhs3, lhs4), let .saveAuthToken(rhs1, rhs2, rhs3, rhs4)):
            return lhs1 == rhs1 && lhs2 == rhs2 && lhs3 == rhs3 && lhs4 == rhs4

        case (let .chooseIdentity(lhsViewController), let .chooseIdentity(rhsViewController)):
            return lhsViewController == rhsViewController

        case (.cancelIdentity, .cancelIdentity):
            return true

        case (let .updateIdentity(lhsSecIdentity), let .updateIdentity(rhsSecIdentity)):
            return lhsSecIdentity == rhsSecIdentity

        case (let .dismiss(lhsViewController), let .dismiss(rhsViewController)):
            return lhsViewController == rhsViewController

        case (let .push(lhs1, lhs2, lhs3, lhs4, lhs5, lhs6, lhs7, _),
              let .push(rhs1, rhs2, rhs3, rhs4, rhs5, rhs6, rhs7, _)):
            return lhs1 == rhs1
                && lhs2 == rhs2
                && lhs3 == rhs3
                && lhs4 == rhs4
                && lhs5 == rhs5
                && lhs6 == rhs6
                && lhs7 == rhs7

        case (.chooseFile, .chooseFile):
            return true

        case (let .saveFile(lhsString, lhsURL), let .saveFile(rhsString, rhsURL)):
            return lhsString == rhsString && lhsURL == rhsURL

        case (let .payloadDidChange(lhsURL), let .payloadDidChange(rhsURL)):
            return lhsURL == rhsURL

        default:
            return false
        }
    }
}
