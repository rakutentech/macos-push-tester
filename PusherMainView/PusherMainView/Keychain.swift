import Foundation

enum Keychain {
    static func string(for key: String) -> String? {
        guard let service = Bundle.main.bundleIdentifier else {
            return nil
        }

        let queryLoad: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let resultCodeLoad = SecItemCopyMatching(queryLoad as CFDictionary, &result)
        if resultCodeLoad == errSecSuccess,
           let resultVal = result as? Data,
           let keyValue = String(data: resultVal, encoding: .utf8) {
            return keyValue
        }
        return nil
    }

    static func set(value: String?, forKey key: String) {
        guard let service = Bundle.main.bundleIdentifier else {
            return
        }

        let queryFind: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]

        guard let valueNotNil = value, let data = valueNotNil.data(using: .utf8) else {
            SecItemDelete(queryFind as CFDictionary)
            return
        }

        let updatedAttributes: [String: Any] = [
            kSecValueData as String: data
        ]

        var resultCode = SecItemUpdate(queryFind as CFDictionary, updatedAttributes as CFDictionary)

        if resultCode == errSecItemNotFound {
            let queryAdd: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: key,
                kSecValueData as String: data,
                kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
            ]

            resultCode = SecItemAdd(queryAdd as CFDictionary, nil)
        }

        if resultCode != errSecSuccess {
            NSException(name: NSExceptionName(rawValue: "Keychain Error"), reason: "Unable to store data \(resultCode)", userInfo: nil).raise()
        }
    }
}
