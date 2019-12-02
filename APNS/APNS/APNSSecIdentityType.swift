import Foundation
import Security

enum APNSSecIdentityType: String {
    // http://www.apple.com/certificateauthority/Apple_WWDR_CPS
    case invalid = ""
    case development = "1.2.840.113635.100.6.3.1"
    case production = "1.2.840.113635.100.6.3.2"
    case universal = "1.2.840.113635.100.6.3.6"
    
    private static func values(for identity: SecIdentity) -> [String: Any]? {
        var certificate: SecCertificate?
        
        SecIdentityCopyCertificate(identity, &certificate)
        
        guard let cert = certificate else {
            return [:]
        }
        
        let keys: NSArray = [
            APNSSecIdentityType.development.rawValue,
            APNSSecIdentityType.production.rawValue,
            APNSSecIdentityType.universal.rawValue,
        ]
        
        let values: [String: Any]? = SecCertificateCopyValues(cert, keys, nil) as? [String: Any]
        
        certificate = nil
        
        return values
    }
    
    static func type(for identity: SecIdentity) -> APNSSecIdentityType {
        guard let values = values(for: identity) else {
            return .invalid
        }
        
        if (values[APNSSecIdentityType.development.rawValue] != nil) && (values[APNSSecIdentityType.production.rawValue] != nil) {
            return .universal
            
        } else if (values[APNSSecIdentityType.development.rawValue]) != nil {
            return .development
            
        } else if (values[APNSSecIdentityType.production.rawValue]) != nil {
            return .production
            
        } else {
            return .invalid
        }
    }
}
