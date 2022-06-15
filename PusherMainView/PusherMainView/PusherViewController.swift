import Cocoa
import APNS

public final class PusherViewController: NSViewController {
    @IBOutlet private var deviceTokenTextField: NSTextField!
    @IBOutlet private var apnsCollapseIdTextField: NSTextField!
    @IBOutlet private var payloadTextView: NSTextView!
    @IBOutlet private var appBundleIDTextField: NSTextField!
    @IBOutlet private var priorityTextField: NSTextField!
    @IBOutlet private var sandBoxCheckBox: NSButton!
    @IBOutlet private var apnsCertificateRadioButton: NSButton!
    @IBOutlet private var apnsAuthTokenRadioButton: NSButton!
    @IBOutlet private var loadJSONFileButton: NSButton!
    @IBOutlet private var sendToDeviceButton: NSButton!
    @IBOutlet private var sendToSimulatorButton: NSButton!
    @IBOutlet private var deviceSettingsControls: DeviceSettingsControls!
    private let pusherStore: PusherInteracting
    private var selectedDestination = Destination.device
    private var jsonFileURL: URL?

    // MARK: - Init

    required init?(coder: NSCoder) {
        pusherStore = PusherStore(apnsPusher: APNSPusher(), router: Router())
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

        apnsCollapseIdTextField.placeholderString = "enter.apns.collapse.id".localized
        appBundleIDTextField.placeholderString = "enter.your.app.bundle.id".localized
        priorityTextField.placeholderString = "enter.apns.priority".localized

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
        case sendToDeviceButton:
            selectedDestination = .device
            pusherStore.dispatch(actionType: .chooseDevice)
        case sendToSimulatorButton:
            selectedDestination = .simulator
            pusherStore.dispatch(actionType: .chooseSimulator)
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
        pusherStore.dispatch(actionType: .push(payloadTextView.string,
                                               destination: selectedDestination,
                                               deviceToken: deviceTokenTextField.stringValue,
                                               appBundleID: appBundleIDTextField.stringValue,
                                               priority: priorityTextField?.integerValue ?? 10,
                                               collapseID: apnsCollapseIdTextField.stringValue,
                                               sandbox: sandBoxCheckBox.state.rawValue == 1) { _ in })
    }

    @IBAction func selectDevice(_ sender: Any) {
        pusherStore.dispatch(actionType: .devicesList(fromViewController: self))
    }
}

extension PusherViewController: PusherInteractable {
    func newState(state: PusherState) {
        deviceTokenTextField.stringValue = state.deviceTokenString
        appBundleIDTextField.stringValue = state.appID
        apnsCertificateRadioButton.state = state.certificateRadioState
        apnsAuthTokenRadioButton.state = state.authTokenRadioState
        sendToDeviceButton.state = state.deviceRadioState
        sendToSimulatorButton.state = state.simulatorRadioState
        deviceSettingsControls.set(visible: state.deviceRadioState == .on)
        view.window?.title = state.appTitle
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
    @IBOutlet private weak var apnsCollapseIdTextField: NSTextField!
    @IBOutlet private weak var sandBoxCheckBox: NSButton!

    private var allControls: [NSView] {
        [deviceTokenTextField, orLabel, selectDeviceButtonContainer, apnsButtonsContainer,
         priorityTextField, apnsCollapseIdTextField, sandBoxCheckBox]
    }

    func set(visible: Bool) {
        allControls.forEach { $0.isHidden = !visible }
    }
}
