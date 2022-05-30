import Foundation

protocol Routing {
    func presentDevicesList(from fromViewController: NSViewController, pusherStore: PusherInteracting)
    func presentAuthTokenAlert(from fromViewController: NSViewController, pusherStore: PusherInteracting)
    func show(message: String, window: NSWindow?)
    func browseFiles(from fromViewController: NSViewController, completion: @escaping (_ p8FileURL: URL) -> Void)
    func dismiss(from fromViewController: NSViewController)
}

struct Router {
    private func presentAsSheet(_ viewController: NSViewController,
                                from fromViewController: NSViewController) {
        fromViewController.presentAsSheet(viewController)
        viewController.view.window?.minSize = fromViewController.view.window?.minSize ?? .zero
        viewController.view.window?.maxSize = fromViewController.view.window?.minSize ?? .zero
    }
}

extension Router: Routing {
    func presentDevicesList(from fromViewController: NSViewController, pusherStore: PusherInteracting) {
        guard let viewController = DevicesViewController.create(pusherStore: pusherStore) else {
            return
        }
        presentAsSheet(viewController, from: fromViewController)
    }

    func presentAuthTokenAlert(from fromViewController: NSViewController, pusherStore: PusherInteracting) {
        guard let viewController = AuthTokenViewcontroller.create(pusherStore: pusherStore) else {
            return
        }
        presentAsSheet(viewController, from: fromViewController)
    }

    func show(message: String, window: NSWindow?) {
        NSAlert.show(message: message, window: window)
    }

    func browseFiles(from fromViewController: NSViewController, completion: @escaping (_ p8FileURL: URL) -> Void) {
        guard let window = fromViewController.view.window else { return }

        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false

        panel.beginSheetModal(for: window) { (result) in
            if result.rawValue == NSApplication.ModalResponse.OK.rawValue,
               let p8fileURL = panel.urls.first {
                completion(p8fileURL)
            }
        }
    }

    func dismiss(from fromViewController: NSViewController) {
        fromViewController.presentingViewController?.dismiss(fromViewController)
    }
}

private extension NSAlert {
    static func show(message: String, window: NSWindow?) {
        guard let window = window else {
            return
        }
        let alert = NSAlert()
        alert.messageText = message
        alert.addButton(withTitle: "close".localized)
        alert.beginSheetModal(for: window)
    }
}
