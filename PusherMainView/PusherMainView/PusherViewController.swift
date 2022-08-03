import Cocoa
import APNS

public final class PusherViewController: NSViewController {
    @IBOutlet private var deviceTokenTextField: NSTextField!
    @IBOutlet private var collapseIdTextField: NSTextField!
    @IBOutlet private var payloadTextView: NSTextView!
    @IBOutlet private var appOrProjectIDTextField: NSTextField!
    @IBOutlet private var priorityTextField: NSTextField!
    @IBOutlet private var sandBoxCheckBox: NSButton!
    @IBOutlet private var apnsCertificateRadioButton: NSButton!
    @IBOutlet private var apnsAuthTokenRadioButton: NSButton!
    @IBOutlet private var loadJSONFileButton: NSButton!
    @IBOutlet private var sendToiOSDeviceButton: NSButton!
    @IBOutlet private var sendToiOSSimulatorButton: NSButton!
    @IBOutlet private var sendToAndroidDeviceButton: NSButton!
    @IBOutlet private var serverKeyTextField: NSTextField!
    @IBOutlet private var legacyFCMCheckbox: NSButton!
    @IBOutlet private var deviceSettingsControls: DeviceSettingsControls!
    private let pusherStore: PusherInteracting
    private var selectedDestination = Destination.iOSDevice
    private var jsonFileURL: URL?

    // MARK: - Init

    required init?(coder: NSCoder) {
        pusherStore = PusherStore(apnsPusher: APNSPusher(), fcmPusher: FCMPusher(), router: Router())
        super.init(coder: coder)
        #if DEBUG
        print("\(self.className) init")
        #endif
    }

    deinit {
        pusherStore.unsubscribe(self)
        #if DEBUG
        print("\(self.className) deinit")
        #endif
    }

    public static func create() -> PusherViewController? {
        let bundle = Bundle(for: PusherViewController.self)
        let storyboard = NSStoryboard(name: "Pusher", bundle: bundle)
        guard let pusherMainViewController = storyboard.instantiateInitialController() as? PusherViewController else {
            return nil
        }
        return pusherMainViewController
    }

    // MARK: - Life Cycle

    public override func viewDidLoad() {
        super.viewDidLoad()

        deviceTokenTextField.placeholderString = "enter.device.token".localized
        deviceTokenTextField.delegate = self

        collapseIdTextField.placeholderString = "enter.apns.collapse.id".localized
        appOrProjectIDTextField.placeholderString = "enter.your.app.bundle.id".localized
        priorityTextField.placeholderString = "enter.apns.priority".localized
        serverKeyTextField.placeholderString = "enter.fcm.server.key".localized

        priorityTextField.stringValue = "10"

        payloadTextView.isRichText = false
        payloadTextView.isAutomaticTextCompletionEnabled = false
        payloadTextView.isAutomaticQuoteSubstitutionEnabled = false
        payloadTextView.string = "{\n\t\"aps\":{\n\t\t\"alert\":\"Test\",\n\t\t\"sound\":\"default\",\n\t\t\"badge\":1\n\t}\n}"
        payloadTextView.delegate = self

        pusherStore.subscribe(self)
    }

    public override func viewDidAppear() {
        super.viewDidAppear()
        pusherStore.dispatch(actionType: .configure)
    }

    // MARK: - Actions

    @IBAction func saveFile(_ sender: Any) {
        guard let jsonFileURL = jsonFileURL else {
            return
        }
        pusherStore.dispatch(actionType: .saveFile(text: payloadTextView.string, fileURL: jsonFileURL))
    }

    @IBAction func saveFileAs(_ sender: Any) {
        pusherStore.dispatch(actionType: .saveFileAs(text: payloadTextView.string, fromViewController: self, completion: { fileURL in
            self.jsonFileURL = fileURL
        }))
    }

    @IBAction func chooseIdentity(_ sender: Any) {
        pusherStore.dispatch(actionType: .chooseIdentity(fromViewController: self))
    }

    @IBAction func chooseAuthenticationToken(_ sender: Any) {
        pusherStore.dispatch(actionType: .chooseAuthToken(fromViewController: self))
    }

    @IBAction func chooseDestination(_ sender: Any) {
        guard let button = sender as? NSButton else {
            return
        }
        switch button {
        case sendToiOSDeviceButton:
            selectedDestination = .iOSDevice
            pusherStore.dispatch(actionType: .chooseiOSDevice)
        case sendToiOSSimulatorButton:
            selectedDestination = .iOSSimulator
            pusherStore.dispatch(actionType: .chooseiOSSimulator)
        case sendToAndroidDeviceButton:
            selectedDestination = .androidDevice
            pusherStore.dispatch(actionType: .chooseAndroidDevice(useLegacyFCM: legacyFCMCheckbox.state == .on))
        default: ()
        }
    }

    @IBAction func loadJSONFile(_ sender: Any) {
        pusherStore.dispatch(actionType: .browsingJSONFiles(fromViewController: self, completion: { jsonFileURL, text in
            self.jsonFileURL = jsonFileURL
            self.payloadTextView.string = text
            self.pusherStore.dispatch(actionType: .enableSaveMenuItem)
        }))
    }

    @IBAction func sendPush(_ sender: Any) {
        let isAndroidSelected = sendToAndroidDeviceButton.state == .on
        pusherStore.dispatch(actionType: .push(PushData(
            payload: payloadTextView.string,
            destination: selectedDestination,
            deviceToken: deviceTokenTextField.stringValue,
            serverKey: serverKeyTextField.stringValue,
            appBundleID: isAndroidSelected ? nil : appOrProjectIDTextField.stringValue,
            projectID: isAndroidSelected ? appOrProjectIDTextField.stringValue : nil,
            priority: priorityTextField?.integerValue ?? 10,
            collapseID: collapseIdTextField.stringValue,
            sandbox: sandBoxCheckBox.state.rawValue == 1,
            legacyFCM: legacyFCMCheckbox.state == .on)) { _ in })
    }

    @IBAction func selectDevice(_ sender: Any) {
        pusherStore.dispatch(actionType: .devicesList(fromViewController: self))
    }

    @IBAction func setLegacyFCM(_ sender: Any) {
        pusherStore.dispatch(actionType: .chooseAndroidDevice(useLegacyFCM: legacyFCMCheckbox.state == .on))
    }
}

extension PusherViewController: PusherInteractable {
    func newState(state: PusherState) {
        deviceTokenTextField.stringValue = state.deviceTokenString
        appOrProjectIDTextField.stringValue = state.appOrProjectID
        serverKeyTextField.stringValue = state.serverKeyString
        apnsCertificateRadioButton.state = state.certificateRadioState
        apnsAuthTokenRadioButton.state = state.authTokenRadioState
        sendToiOSDeviceButton.state = state.iOSDeviceRadioState
        sendToiOSSimulatorButton.state = state.iOSSimulatorRadioState
        sendToAndroidDeviceButton.state = state.androidDeviceRadioState
        legacyFCMCheckbox.state = state.legacyFCMCheckboxState
        appOrProjectIDTextField.isHidden = state.androidDeviceRadioState == .on && state.legacyFCMCheckboxState == .on
        deviceSettingsControls.setVisible(for: selectedDestination)
        view.window?.title = state.appTitle

        if state.androidDeviceRadioState == .on {
            appOrProjectIDTextField.placeholderString = "enter.fcm.project.id".localized
        } else {
            appOrProjectIDTextField.placeholderString = "enter.your.app.bundle.id".localized
        }
    }

    func newErrorState(_ errorState: ErrorState) {
        #if DEBUG
        NSLog("\(errorState.error) for \(errorState.actionType)")
        #endif
    }
}

// MARK: - NSTextFieldDelegate

extension PusherViewController: NSTextFieldDelegate {
    public func controlTextDidChange(_ notification: Notification) {
        guard notification.object as? NSTextField == deviceTokenTextField else {
            return
        }
        let deviceToken = deviceTokenTextField.stringValue
        pusherStore.dispatch(actionType: .deviceToken(deviceToken))
    }
}

// MARK: - NSTextViewDelegate

extension PusherViewController: NSTextViewDelegate {
    public func textDidChange(_ notification: Notification) {
        pusherStore.dispatch(actionType: .payloadDidChange(fileURL: jsonFileURL))
    }
}

// MARK: - DeviceSettingsControls

@objc final class DeviceSettingsControls: NSObject {
    @IBOutlet private weak var deviceTokenTextField: NSTextField!
    @IBOutlet private weak var orLabel: NSTextField!
    @IBOutlet private weak var selectDeviceButtonContainer: NSView!
    @IBOutlet private weak var apnsButtonsContainer: NSView!
    @IBOutlet private weak var priorityTextField: NSTextField!
    @IBOutlet private weak var collapseIdTextField: NSTextField!
    @IBOutlet private weak var sandBoxCheckBox: NSButton!
    @IBOutlet private weak var serverKeyTextFieldContainter: NSView!

    private var iOSControls: [NSView] {
        [deviceTokenTextField, orLabel, selectDeviceButtonContainer, apnsButtonsContainer,
         priorityTextField, collapseIdTextField, sandBoxCheckBox]
    }
    private var androidControls: [NSView] {
        [deviceTokenTextField, serverKeyTextFieldContainter, collapseIdTextField]
    }

    func setVisible(for destination: Destination) {
        (iOSControls + androidControls).forEach { $0.isHidden = true }
        switch destination {
        case .iOSDevice:
            iOSControls.forEach { $0.isHidden = false }
        case .androidDevice:
            androidControls.forEach { $0.isHidden = false }
        case .iOSSimulator: ()
        }
    }
}
