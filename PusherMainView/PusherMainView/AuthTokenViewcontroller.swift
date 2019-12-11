import Foundation
import APNS

final class AuthTokenViewcontroller: NSViewController {
    private var pusherStore: PusherInteracting?
    private var p8FileURL: URL?
    @IBOutlet private var keyIDTextField: NSTextField!
    @IBOutlet private var teamIDTextField: NSTextField!
    @IBOutlet private var p8Label: NSTextField!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        #if DEBUG
        print("\(self.className) init")
        #endif
    }
    
    deinit {
        #if DEBUG
        print("\(self.className) deinit")
        #endif
    }
    
    static func create(pusherStore: PusherInteracting) -> AuthTokenViewcontroller? {
        let bundle = Bundle(for: PusherViewController.self)
        let storyboard = NSStoryboard(name: "Pusher", bundle: bundle)
        guard let viewController = storyboard.instantiateController(withIdentifier: "AuthTokenViewcontroller") as? AuthTokenViewcontroller else {
            return nil
        }
        viewController.pusherStore = pusherStore
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        keyIDTextField.stringValue = pusherStore?.authToken?.keyID ?? ""
        teamIDTextField.stringValue = pusherStore?.authToken?.teamID ?? ""
        p8Label.stringValue = pusherStore?.authToken?.p8FileURLString.prettyDisplay ?? ""
        
        if let urlString = pusherStore?.authToken?.p8FileURLString {
            p8FileURL = URL(string: urlString)
        }
    }
    
    // MARK:- Actions
    
    @IBAction private func didTapOpenP8Button(_ sender: Any) {
        pusherStore?.dispatch(actionType: .browsingFiles(fromViewController: self, completion: { (p8FileURL) in
            self.p8FileURL = p8FileURL
            self.p8Label.stringValue = p8FileURL.absoluteString.prettyDisplay
        }))
    }
    
    @IBAction private func didTapCancelButton(_ sender: Any) {
        pusherStore?.dispatch(actionType: .cancelAuthToken)
        pusherStore?.dispatch(actionType: .dismiss(fromViewController: self))
    }
    
    @IBAction private func didTapValidateButton(_ sender: Any) {
        guard teamIDTextField.stringValue.count > 0 else {
            pusherStore?.dispatch(actionType: .alert(message: "Please enter Team ID", fromWindow: view.window))
            return
        }
        
        guard keyIDTextField.stringValue.count > 0 else {
            pusherStore?.dispatch(actionType: .alert(message: "Please enter Key ID", fromWindow: view.window))
            return
        }
        
        guard let p8FileURL = p8FileURL,
            let p8String = try? String(contentsOf: p8FileURL, encoding: .utf8) else {
                pusherStore?.dispatch(actionType: .alert(message: "p8 file is incorrect", fromWindow: view.window))
                return
        }
        
        pusherStore?.dispatch(actionType: .saveAuthToken(teamID: teamIDTextField.stringValue,
                                                         keyID: keyIDTextField.stringValue,
                                                         p8FileURL: p8FileURL,
                                                         p8: p8String))
        pusherStore?.dispatch(actionType: .dismiss(fromViewController: self))
    }
}

private extension String {
    var prettyDisplay: String {
        let headerLength = "file://".count
        let totalLength = self.count
        return "\(self.suffix(totalLength - headerLength))"
    }
}
