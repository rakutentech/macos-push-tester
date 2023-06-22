import Foundation

struct InterfaceFactory<T: NSObjectProtocol> {
    static func create(for storyboardName: String) -> T? {
        let aClass = T.self
        let bundle = Bundle(for: aClass.self)
        let storyboard = NSStoryboard(name: storyboardName, bundle: bundle)
        let absoluteIdentifier = NSStringFromClass(aClass)
        let module = String(String(reflecting: T.self).prefix { $0 != "." })
        let identifier = absoluteIdentifier[module.count + 1..<absoluteIdentifier.count]

        guard let viewController = storyboard.instantiateController(withIdentifier: identifier) as? T else {
            return nil
        }
        return viewController
    }
}
