import Foundation

struct PusherReducer {
    func reduce(actionType: ActionType, state: PusherState) -> PusherState {
        var newState = state

        switch actionType {
        case .selectDevice(let device):
            newState.deviceTokenString = device.token
            newState.appOrProjectID = device.appID

        case .deviceToken(let deviceToken):
            newState.deviceTokenString = deviceToken

        case .chooseAuthToken:
            newState.certificateRadioState = .off
            newState.authTokenRadioState = .on

        case .cancelAuthToken:
            newState.authTokenRadioState = .off

        case .saveAuthToken:
            newState.authTokenRadioState = .on

        case .chooseIdentity:
            newState.certificateRadioState = .on
            newState.authTokenRadioState = .off

        case .cancelIdentity:
            newState.certificateRadioState = .off

        case .updateIdentity:
            newState.certificateRadioState = .on

        case .chooseiOSDevice:
            newState.iOSSimulatorRadioState = .off
            newState.iOSDeviceRadioState = .on
            newState.androidDeviceRadioState = .off

        case .chooseiOSSimulator:
            newState.iOSSimulatorRadioState = .on
            newState.iOSDeviceRadioState = .off
            newState.androidDeviceRadioState = .off

        case .chooseAndroidDevice(let legacyFCM):
            newState.iOSSimulatorRadioState = .off
            newState.iOSDeviceRadioState = .off
            newState.androidDeviceRadioState = .on
            newState.legacyFCMCheckboxState = legacyFCM ? .on : .off

        case .configure, .enableSaveMenuItem:
            newState.appTitle = "app.title".localized

        case .saveFile(_, let fileURL):
            newState.appTitle = "app.title".localized
            newState.fileURL = fileURL

        case .payloadDidChange(let fileURL):
            guard fileURL != nil else {
                return newState
            }
            newState.appTitle = "app.title".localized + " *"

        default: ()
        }

        return newState
    }
}
