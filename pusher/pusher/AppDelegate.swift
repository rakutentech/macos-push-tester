import Cocoa
import PusherMainView

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var window: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        window = NSWindow(size: NSSize(width: 480, height: 480))
        window?.contentViewController = PusherViewController.create()
        NSApplication.shared.loadMainMenu()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        #if DEBUG
        print("App should terminate after last window closed")
        #endif
        return true
    }

    func applicationWillTerminate(_ notification: Notification) {
        #if DEBUG
        print("App will terminate")
        #endif
    }
}

private extension NSWindow {
    convenience init(size windowSize: NSSize) {
        let screenSize = NSScreen.main?.frame.size ?? .zero
        let rect = NSRect(x: screenSize.width/2 - windowSize.width/2,
                          y: screenSize.height/2 - windowSize.height/2,
                          width: windowSize.width,
                          height: windowSize.height)
        self.init(contentRect: rect,
                  styleMask: [.miniaturizable, .closable, .resizable, .titled],
                  backing: .buffered,
                  defer: false)
        minSize = windowSize
        makeKeyAndOrderFront(nil)
    }
}

private extension NSApplication {
    func loadMainMenu() {
        var topLevelObjects: NSArray? = []
        Bundle.main.loadNibNamed("Application", owner: self, topLevelObjects: &topLevelObjects)
        mainMenu = topLevelObjects?.filter { $0 is NSMenu }.first as? NSMenu
    }
}
