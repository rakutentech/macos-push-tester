import Cocoa
import SecurityInterface.SFChooseIdentityPanel
import APNS

public final class PusherViewController: NSViewController {
    @IBOutlet private var deviceTokenTextField: NSTextField!
    @IBOutlet private var appBundleIDTextField: NSTextField!
    @IBOutlet private var apnsCollapseIdTextField: NSTextField!
    @IBOutlet private var payloadTextView: NSTextView!
    @IBOutlet private var sandBoxCheckBox: NSButton!
    @IBOutlet private var apnsCertificateRadioButton: NSButton!
    @IBOutlet private var apnsAuthTokenRadioButton: NSButton!
    private let pusherInteractor: PusherInteracting
    
    // MARK: - Init
    
    required init?(coder: NSCoder) {
        pusherInteractor = PusherInteractor(apnsPusher: APNSPusher(), router: Router())
        super.init(coder: coder)
        pusherInteractor.delegate = self
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
        appBundleIDTextField.placeholderString = "Enter your app bundle ID"
        apnsCollapseIdTextField.placeholderString = "Enter apns-collapse-id"
        
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
        apnsAuthTokenRadioButton.state = .off
        
        let panel = SFChooseIdentityPanel.shared()
        panel?.setAlternateButtonTitle("Cancel")
        panel?.beginSheet(for: view.window,
                          modalDelegate: self,
                          didEnd: #selector(chooseIdentityPanelDidEnd(_:returnCode:contextInfo:)),
                          contextInfo: nil,
                          identities: APNSIdentityManager.identities(),
                          message: "Choose the identity to use for delivering notifications: \n(Issued by Apple in the Provisioning Portal)")
    }
    
    @objc func chooseIdentityPanelDidEnd(_ sheet: NSWindow, returnCode: Int, contextInfo: Any) {
        guard returnCode == NSApplication.ModalResponse.OK.rawValue, let identity = SFChooseIdentityPanel.shared()?.identity() else {
            apnsCertificateRadioButton.state = .off
            return
        }
        
        willChangeValue(forKey: "identityName")
        pusherInteractor.updateIdentity(identity.takeUnretainedValue() as SecIdentity)
        didChangeValue(forKey: "identityName")
    }
    
    @IBAction func chooseAuthenticationToken(_ sender: Any) {
        apnsCertificateRadioButton.state = .off
        pusherInteractor.present(actionType: .authToken(fromViewController: self))
    }
    
    @IBAction func sendPush(_ sender: Any) {
        pusherInteractor.push(payloadTextView.string,
                              toToken: deviceTokenTextField.stringValue,
                              withTopic: appBundleIDTextField.stringValue,
                              priority: 10,
                              collapseID: apnsCollapseIdTextField.stringValue,
                              inSandbox: sandBoxCheckBox.state.rawValue == 1) { _ in }
    }
    
    @IBAction func selectDevice(_ sender: Any) {
        pusherInteractor.present(actionType: .devicesList(fromViewController: self))
    }
}

extension PusherViewController: PusherInteractable {
    func didSelectDevicetoken(_ device: String) {
        deviceTokenTextField.stringValue = device
    }
    
    func didCancelSelectingAuthToken() {
        apnsAuthTokenRadioButton.state = .off
    }
}
