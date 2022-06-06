import Foundation

private enum MenuItemName {
    static let file = "File"
    static let save = "Save…"
}

extension NSApplication {
    var fileMenu: NSMenu? {
        return NSApplication.shared.mainMenu?.item(withTitle: MenuItemName.file)?.submenu
    }

    var saveMenuItem: NSMenuItem? {
        return fileMenu?.item(withTitle: MenuItemName.save)
    }
}
