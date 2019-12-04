import Foundation

struct PusherState: Equatable {
    var deviceTokenString: String
    var appID: String
    var certificateRadioState: NSControl.StateValue
    var authTokenRadioState: NSControl.StateValue
}
