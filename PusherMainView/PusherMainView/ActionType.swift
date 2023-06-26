import Foundation
import APNS

enum ActionType {
    case configure
    case devicesList(fromViewController: NSViewController)
    case pushTypesList(fromViewController: NSViewController)
    case deviceToken(String)
    case pushType(String)
    case chooseAuthToken(fromViewController: NSViewController)
    case alert(message: String, fromWindow: NSWindow?)
    case browsingFiles(fromViewController: NSViewController, completion: (_ fileURL: URL) -> Void)
    case browsingJSONFiles(fromViewController: NSViewController, completion: (_ fileURL: URL, _ text: String) -> Void)
    case selectDevice(device: APNSServiceDevice)
    case selectPushType(pushType: String)
    case chooseiOSSimulator
    case chooseiOSDevice
    case chooseAndroidDevice(useLegacyFCM: Bool)
    case cancelAuthToken
    case saveAuthToken(teamID: String, keyID: String, p8FileURL: URL, p8: String)
    case chooseIdentity(fromViewController: NSViewController)
    case cancelIdentity
    case updateIdentity(identity: SecIdentity)
    case dismiss(fromViewController: NSViewController)
    case push(_ data: PushData,
              completion: (Bool) -> Void)
    case enableSaveMenuItem
    case saveFile(text: String, fileURL: URL)
    case saveFileAs(text: String, fromViewController: NSViewController, completion: (_ fileURL: URL) -> Void)
    case payloadDidChange(fileURL: URL?)
}

extension ActionType: Equatable {
    static func == (lhs: ActionType, rhs: ActionType) -> Bool {
        switch (lhs, rhs) {
        case (.configure, .configure):
            return true

        case (let .devicesList(lhsViewController), let .devicesList(rhsViewController)):
            return lhsViewController == rhsViewController

        case (let .pushTypesList(lhsViewController), let .pushTypesList(rhsViewController)):
            return lhsViewController == rhsViewController

        case (let .deviceToken(lhsString), let .deviceToken(rhsString)), (let .pushType(lhsString), let .pushType(rhsString)):
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

        case (let .selectPushType(lhsPushType), let .selectPushType(rhsPushType)):
            return lhsPushType == rhsPushType

        case (.chooseiOSSimulator, .chooseiOSSimulator):
            return true

        case (.chooseiOSDevice, .chooseiOSDevice):
            return true

        case (let .chooseAndroidDevice(lhs), let .chooseAndroidDevice(rhs)):
            return lhs == rhs

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

        case (let .push(lhs, _),
              let .push(rhs, _)):
            return lhs == rhs

        case (.enableSaveMenuItem, .enableSaveMenuItem):
            return true

        case (let .saveFile(lhsString, lhsURL), let .saveFile(rhsString, rhsURL)):
            return lhsString == rhsString && lhsURL == rhsURL

        case (let .saveFileAs(lhsString, lhsViewController, _), let .saveFileAs(rhsString, rhsViewController, _)):
            return lhsString == rhsString && lhsViewController == rhsViewController

        case (let .payloadDidChange(lhsURL), let .payloadDidChange(rhsURL)):
            return lhsURL == rhsURL

        default:
            return false
        }
    }
}
