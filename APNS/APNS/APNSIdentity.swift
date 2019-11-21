import Foundation

public enum APNSIdentity {
    public static func identities() -> [Any] {
        guard let kCFBooleanTrueNotNil = kCFBooleanTrue else {
            return []
        }
        
        let query: NSDictionary = [
            kSecClass: kSecClassIdentity,
            kSecMatchLimit: kSecMatchLimitAll,
            kSecReturnRef: kCFBooleanTrueNotNil
        ]
        var identities: CFTypeRef?
        let status: OSStatus = SecItemCopyMatching(query, &identities)
        
        guard status == noErr,
            let idsArray = identities as? NSArray,
            let result = NSMutableArray(array: idsArray) as? [SecIdentity] else {
                return []
        }
        
        // Allow only identities with APNS certificate
        
        let filtered = result.filter { APNSSecIdentity.type(for: $0) != .invalid }.sorted { (id1, id2) -> Bool in
                var cert1: SecCertificate?
                var cert2: SecCertificate?
                
                SecIdentityCopyCertificate(id1, &cert1)
                SecIdentityCopyCertificate(id2, &cert2)
                
                guard let cert1NotNil = cert1, let cert2NotNil = cert2 else {
                        return false
                }
                
                guard let name1 = SecCertificateCopyShortDescription(nil, cert1NotNil, nil),
                    let name2 = SecCertificateCopyShortDescription(nil, cert2NotNil, nil) else {
                        return false
                }
                
                cert1 = nil
                cert2 = nil
                
                return (name1 as NSString).compare(name2 as String) == .orderedAscending
        }
        
        return filtered
    }
}
