import Foundation
import Security

enum APNSSecIdentity {
    // http://www.apple.com/certificateauthority/Apple_WWDR_CPS
    static let developmentCustomExtension = "1.2.840.113635.100.6.3.1"
    static let productionCustomExtension = "1.2.840.113635.100.6.3.2"
    static let universalCustomExtension = "1.2.840.113635.100.6.3.6"
    
    enum APNSSecIdentityType: Int {
        case invalid, development, production, universal
    }
    
    private static func values(for identity: SecIdentity) -> [String: Any]? {
        var certificate: SecCertificate?
        
        SecIdentityCopyCertificate(identity, &certificate)
        
        guard let cert = certificate else {
            return [:]
        }
        
        let keys: NSArray = [
            developmentCustomExtension,
            productionCustomExtension,
            universalCustomExtension,
        ]
        
        let values: [String: Any]? = SecCertificateCopyValues(cert, keys, nil) as? [String: Any]
        
        certificate = nil
        
        return values
    }
    
    static func type(for identity: SecIdentity) -> APNSSecIdentityType {
        guard let values = values(for: identity) else {
            return .invalid
        }
        
        if (values[developmentCustomExtension] != nil) && (values[productionCustomExtension] != nil) {
            return .universal
            
        } else if (values[developmentCustomExtension]) != nil {
            return .development
            
        } else if (values[productionCustomExtension]) != nil {
            return .production
            
        } else {
            return .invalid
        }
    }
}
