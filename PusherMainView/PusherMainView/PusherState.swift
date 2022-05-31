import Foundation

struct PusherState: Equatable {
    var deviceTokenString: String
    var appID: String
    var certificateRadioState: NSControl.StateValue
    var authTokenRadioState: NSControl.StateValue
    var deviceRadioState: NSControl.StateValue
    var simulatorRadioState: NSControl.StateValue
    var appTitle: String
    var fileURL: URL?
}
