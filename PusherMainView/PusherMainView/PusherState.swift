import Foundation

struct PusherState: Equatable {
    var deviceTokenString: String
    var serverKeyString: String
    var appOrProjectID: String
    var certificateRadioState: NSControl.StateValue
    var authTokenRadioState: NSControl.StateValue
    var iOSDeviceRadioState: NSControl.StateValue
    var iOSSimulatorRadioState: NSControl.StateValue
    var androidDeviceRadioState: NSControl.StateValue
    var legacyFCMCheckboxState: NSControl.StateValue
    var appTitle: String
    var fileURL: URL?
}
