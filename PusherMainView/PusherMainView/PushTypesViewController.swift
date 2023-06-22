import Foundation
import APNS

final class PushTypesViewController: NSViewController {
    @IBOutlet private var tableView: NSTableView!
    var pusherStore: PusherInteracting?
    private let pushTypes: [String]
    private let cellIdentifier = "PushTypeTableCellView"

    required init?(coder: NSCoder) {
        guard let pushTypes = PlistFinder<[String]>.model(for: "pushtypes", and: PushTypesViewController.self) else {
            return nil
        }

        self.pushTypes = pushTypes

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

    // MARK: - Life Cycle

    override func viewDidAppear() {
        super.viewDidAppear()
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }

    // MARK: - Actions

    @IBAction private func didTapCloseButton(_ sender: Any) {
        pusherStore?.dispatch(actionType: .dismiss(fromViewController: self))
    }
}

extension PushTypesViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return pushTypes.count
    }
}

extension PushTypesViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier),
                                            owner: nil) as? NSTableCellView,
              let identifier = tableColumn?.identifier else {
            return nil
        }

        switch identifier.rawValue {
        case "name":
            cell.textField?.stringValue = pushTypes[row]
        default: ()
        }

        return cell
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        guard tableView.selectedRow != -1 else {
            return
        }
        let pushType = pushTypes[tableView.selectedRow]
        pusherStore?.dispatch(actionType: .selectPushType(pushType: pushType))
        pusherStore?.dispatch(actionType: .dismiss(fromViewController: self))
    }
}
