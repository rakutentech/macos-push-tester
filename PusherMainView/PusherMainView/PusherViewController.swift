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
    private let pusherStore: PusherInteracting
    
    // MARK: - Init
    
    required init?(coder: NSCoder) {
        pusherStore = PusherStore(apnsPusher: APNSPusher(), router: Router())
        super.init(coder: coder)
        pusherStore.subscribe(self)
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
        
        deviceTokenTextField.placeholderString = "Enter a device token"
        apnsCollapseIdTextField.placeholderString = "Enter APNS Collapse ID"
        appBundleIDTextField.placeholderString = "Enter your app bundle ID"
        priorityTextField.placeholderString = "Enter APNS priority"
        
        priorityTextField.stringValue = "10"
        
        payloadTextView.isRichText = false
        payloadTextView.isAutomaticTextCompletionEnabled = false
        payloadTextView.isAutomaticQuoteSubstitutionEnabled = false
        payloadTextView.string = "{\n\t\"aps\":{\n\t\t\"alert\":\"Test\",\n\t\t\"sound\":\"default\",\n\t\t\"badge\":1\n\t}\n}"
    }
    
    public override func viewDidAppear() {
        super.viewDidAppear()
        view.window?.title = "The macOS Pusher App"
    }
    
    // MARK: - Actions
    
    @IBAction func chooseIdentity(_ sender: Any) {
        pusherStore.dispatch(actionType: .chooseIdentity(fromViewController: self))
    }
    
    @IBAction func chooseAuthenticationToken(_ sender: Any) {
        pusherStore.dispatch(actionType: .chooseAuthToken(fromViewController: self))
    }
    
    @IBAction func sendPush(_ sender: Any) {
        pusherStore.dispatch(actionType: .push(payloadTextView.string,
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
    }
}
