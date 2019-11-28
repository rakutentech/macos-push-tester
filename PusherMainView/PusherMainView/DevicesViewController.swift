import Foundation
import APNS

final class DevicesViewController: NSViewController {
    @IBOutlet private var tableView: NSTableView!
    private let apnsServiceBrowser = APNSServiceBrowser(serviceType: "pusher")
    private var pusherInteractor: PusherInteracting?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        apnsServiceBrowser.delegate = self
        #if DEBUG
        print("\(self.className) init")
        #endif
    }
    
    static func create(pusherInteractor: PusherInteracting) -> DevicesViewController? {
        let bundle = Bundle(for: PusherViewController.self)
        let storyboard = NSStoryboard(name: "Pusher", bundle: bundle)
        guard let viewController = storyboard.instantiateController(withIdentifier: "DevicesViewController") as? DevicesViewController else {
            return nil
        }
        viewController.pusherInteractor = pusherInteractor
        return viewController
    }
    
    deinit {
        #if DEBUG
        print("\(self.className) deinit")
        #endif
        apnsServiceBrowser.searching = false
    }
    
    // MARK:- Life Cycle
    
    override func viewDidAppear() {
        super.viewDidAppear()
        apnsServiceBrowser.searching = true
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        apnsServiceBrowser.searching = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    // MARK:- Actions
    
    @IBAction private func didTapCloseButton(_ sender: Any) {
        presentingViewController?.dismiss(self)
    }
}

extension DevicesViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return apnsServiceBrowser.devices.count
    }
}

extension DevicesViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "DeviceTableCellView"), owner: nil) as? NSTableCellView,
            let identifier = tableColumn?.identifier else {
            return nil
        }
        
        switch identifier.rawValue {
        case "name":
            cell.textField?.stringValue = apnsServiceBrowser.devices[row].displayName
        case "token":
            cell.textField?.stringValue = apnsServiceBrowser.devices[row].token
        case "appID":
            cell.textField?.stringValue = apnsServiceBrowser.devices[row].appID
        default: ()
        }
        
        return cell
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard tableView.selectedRow != -1 else {
            return
        }
        let device = apnsServiceBrowser.devices[tableView.selectedRow]
        pusherInteractor?.dispatch(actionType: .selectDevice(device: device))
        presentingViewController?.dismiss(self)
    }
}

extension DevicesViewController: APNSServiceBrowsing {
    func didUpdateDevices() {
        tableView.reloadData()
    }
}
