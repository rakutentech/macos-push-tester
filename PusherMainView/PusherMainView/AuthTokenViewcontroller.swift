import Foundation
import APNS

final class AuthTokenViewcontroller: NSViewController {
    private var pusherInteractor: PusherInteracting?
    private var p8FileURL: URL?
    @IBOutlet private var keyIDTextField: NSTextField!
    @IBOutlet private var teamIDTextField: NSTextField!
    @IBOutlet private var p8Label: NSTextField!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    static func create(pusherInteractor: PusherInteracting) -> AuthTokenViewcontroller? {
        let bundle = Bundle(for: PusherViewController.self)
        let storyboard = NSStoryboard(name: "Pusher", bundle: bundle)
        guard let viewController = storyboard.instantiateController(withIdentifier: "AuthTokenViewcontroller") as? AuthTokenViewcontroller else {
            return nil
        }
        viewController.pusherInteractor = pusherInteractor
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        keyIDTextField.stringValue = pusherInteractor?.authToken?.keyID ?? ""
        teamIDTextField.stringValue = pusherInteractor?.authToken?.teamID ?? ""
        p8Label.stringValue = pusherInteractor?.authToken?.p8FileURLString ?? ""
        
        if let urlString = pusherInteractor?.authToken?.p8FileURLString {
            p8FileURL = URL(string: urlString)
        }
    }
    
    // MARK:- Actions
    
    @IBAction private func didTapOpenP8Button(_ sender: Any) {
        pusherInteractor?.dispatch(actionType: .browsingFiles(fromViewController: self, completion: { (p8FileURL) in
            self.p8FileURL = p8FileURL
            self.p8Label.stringValue = "\(p8FileURL)"
        }))
    }
    
    @IBAction private func didTapCancelButton(_ sender: Any) {
        pusherInteractor?.dispatch(actionType: .selectAuthToken)
        dismiss(self)
    }
    
    @IBAction private func didTapValidateButton(_ sender: Any) {
        guard teamIDTextField.stringValue.count > 0 else {
            pusherInteractor?.dispatch(actionType: .alert(message: "Please enter Team ID", fromWindow: view.window))
            return
        }
        
        guard keyIDTextField.stringValue.count > 0 else {
            pusherInteractor?.dispatch(actionType: .alert(message: "Please enter Key ID", fromWindow: view.window))
            return
        }
        
        guard let p8FileURL = p8FileURL,
            let p8String = try? String(contentsOf: p8FileURL, encoding: .utf8) else {
                pusherInteractor?.dispatch(actionType: .alert(message: "p8 file is incorrect", fromWindow: view.window))
                return
        }
        
        pusherInteractor?.dispatch(actionType: .saveAuthToken(teamID: teamIDTextField.stringValue,
                                                              keyID: keyIDTextField.stringValue,
                                                              p8FileURL: p8FileURL,
                                                              p8: p8String))
        dismiss(self)
    }
}
