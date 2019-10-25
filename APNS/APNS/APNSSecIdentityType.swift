import Foundation
import Security

// http://www.apple.com/certificateauthority/Apple_WWDR_CPS
let APNSSecIdentityTypeDevelopmentCustomExtension = "1.2.840.113635.100.6.3.1"
let APNSSecIdentityTypeProductionCustomExtension = "1.2.840.113635.100.6.3.2"
let APNSSecIdentityTypeUniversalCustomExtension = "1.2.840.113635.100.6.3.6"

enum APNSSecIdentityType: Int {
    case invalid, development, production, universal
}

private func APNSecValuesForIndentity(_ identity: SecIdentity) -> [String: Any]? {
    var certificate: SecCertificate?
    
    SecIdentityCopyCertificate(identity, &certificate)
    
    guard let cert = certificate else {
        return [:]
    }
    
    let keys: NSArray = [
        APNSSecIdentityTypeDevelopmentCustomExtension,
        APNSSecIdentityTypeProductionCustomExtension,
        APNSSecIdentityTypeUniversalCustomExtension,
    ]
    
    let values: [String: Any]? = SecCertificateCopyValues(cert, keys, nil) as? [String: Any]
    
    certificate = nil
    
    return values
}

func APNSSecIdentityGetType(_ identity: SecIdentity) -> APNSSecIdentityType {
    guard let values = APNSecValuesForIndentity(identity) else {
        return .invalid
    }
    
    if (values[APNSSecIdentityTypeDevelopmentCustomExtension] != nil) && (values[APNSSecIdentityTypeProductionCustomExtension] != nil) {
        return .universal
        
    } else if (values[APNSSecIdentityTypeDevelopmentCustomExtension]) != nil {
        return .development
        
    } else if (values[APNSSecIdentityTypeProductionCustomExtension]) != nil {
        return .production
        
    } else {
        return .invalid
    }
}
