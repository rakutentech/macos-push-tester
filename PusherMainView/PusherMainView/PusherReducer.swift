import Foundation

struct PusherReducer {
    func reduce(actionType: ActionType, state: PusherState) -> PusherState {
        var newState = state

        switch actionType {
        case .selectDevice(let device):
            newState.deviceTokenString = device.token
            newState.appID = device.appID

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

        case .chooseDevice:
            newState.simulatorRadioState = .off
            newState.deviceRadioState = .on

        case .chooseSimulator:
            newState.simulatorRadioState = .on
            newState.deviceRadioState = .off

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
