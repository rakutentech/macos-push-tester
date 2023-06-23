import Foundation

struct PlistFinder<T: Decodable> {
    static func model(for plistName: String, and aClass: AnyClass) -> T? {
        let bundle = Bundle(for: aClass)

        guard let url = bundle.url(forResource: plistName, withExtension: "plist"),
              let data = try? Data(contentsOf: url) else {
            return nil
        }

        return try? PropertyListDecoder().decode(T.self, from: data)
    }
}
