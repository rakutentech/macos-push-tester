import Foundation

extension String {
    var localized: String {
        guard let bundle = Bundle.sdkAssets else {
            return self
        }
        return NSLocalizedString(self, bundle: bundle, comment: "")
    }
}

private extension Bundle {
    static func bundle(bundleIdSubstring: String) -> Bundle? {
        (allBundles + allFrameworks).first(where: { $0.bundleIdentifier?.contains(bundleIdSubstring) == true })
    }

    static var sdk: Bundle? {
        .bundle(bundleIdSubstring: "PusherMainView")
    }

    static var sdkAssets: Bundle? {
        if let resourceBundle = bundle(bundleIdSubstring: "PusherMainViewResources") {
            return resourceBundle
        }

        guard let sdkBundleURL = sdk?.resourceURL else {
            return nil
        }
        return .init(url: sdkBundleURL.appendingPathComponent("PusherMainViewResources.bundle"))
    }
}
