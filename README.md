![Platform](https://img.shields.io/badge/Platform-macOS-black) 
![Compatibility](https://img.shields.io/badge/Compatibility-macOS%20%3E%3D%2010.13-orange) 
![Compatibility](https://img.shields.io/badge/Swift-5.0-orange.svg) 
![License](https://img.shields.io/badge/License-MIT-lightgrey.svg) 
![Build Status](https://app.bitrise.io/app/120aff9438a0a19e.svg?token=fX7evo54lwDdFSg5xQfkWg&branch=master)

# The macOS Push Tester App

The macOS Push Tester App allows you to send push notifications through APNS (Apple Push Notification Service) or FCM (Firebase Cloud Messaging) and receive them on a device or simulator/emulator.

The macOS Push Tester App can also send push notifications to Live Activities on iOS devices (iOS >= 16.1). This feature only works with APNS token.

Android emulators must enable the Google API for Google Play services.

It can also get device tokens from any iPhone on the same wifi network.

**Notice**: This app was created to be used by the Rakuten SDK team internally. Anyone is free to use it but please be aware that it is unsupported.

## How to build/run from source

- 1) Run `pod install` from root folder
- 2) Open pusher.xcworkspace*
- 3) Build and run

## How to build with Fastlane

### Install fastlane
- 1) Using RubyGems `sudo gem install fastlane -NV` (or simply `bundle install`)

- 2) Alternatively using Homebrew `brew cask install fastlane`

### Run fastlane
Run `fastlane ci`

## Make your iOS app discoverable by the macOS Push Tester App

- 1) Add this class to your iOS app

```swift
import Foundation
import MultipeerConnectivity

/// A device token can be generated from APNS or ActivityKit.
public enum DeviceTokenType: String {
    case apns = "APNS"
    case activityKit = "ActivityKit"
}

public final class DeviceAdvertiser: NSObject {
    private var nearbyServiceAdvertiser: MCNearbyServiceAdvertiser?
    private let serviceType: String

    private enum Keys {
        static let deviceToken = "token"
        static let applicationIdentifier = "appID"
        static let deviceTokenType = "type"
    }
    
    public init(serviceType: String) {
        self.serviceType = serviceType
        super.init()
    }

    /// Start advertising peer with device token (token), app identifier (appID) and device token type (type).
    ///
    /// - Parameters:
    ///    - deviceToken: The APNS or ActivityKit device token
    ///    - type: the device token type (APNS or ActivityKit)
    public func setDeviceToken(_ deviceToken: String,
                               type: DeviceTokenType = .apns) {
        if let advertiser = nearbyServiceAdvertiser {
            advertiser.stopAdvertisingPeer()
        }

        let peerID = MCPeerID(displayName: UIDevice.current.name)
        
        nearbyServiceAdvertiser = MCNearbyServiceAdvertiser(
            peer: peerID,
            discoveryInfo: [Keys.deviceToken: deviceToken,
                            Keys.applicationIdentifier: Bundle.main.bundleIdentifier ?? "",
                            Keys.deviceTokenType: type.rawValue],
            serviceType: serviceType
        )
        
        nearbyServiceAdvertiser?.delegate = self
        nearbyServiceAdvertiser?.startAdvertisingPeer()
    }
}

extension DeviceAdvertiser: MCNearbyServiceAdvertiserDelegate {
    public func advertiser(_ advertiser: MCNearbyServiceAdvertiser,
                           didReceiveInvitationFromPeer peerID: MCPeerID,
                           withContext context: Data?,
                           invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(false, MCSession())
    }
    
    public func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
    }
}
```
- 2) Instantiate `DeviceAdvertiser`

```swift
let deviceAdvertiser = DeviceAdvertiser(serviceType: "pusher")
```

- 3) Set the device token

```swift
func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    deviceAdvertiser.setDeviceToken(deviceToken.hexadecimal)
}
```

- 4) Add this `Data` extension to convert deviceToken to `String`

```swift
import Foundation

extension Data {
    var hexadecimal: String {
        map { String(format: "%02x", $0) }.joined()
    }
}
```

- 5) Add the following to your targets info.plist (required for iOS 14 and above)

```xml
<key>NSBonjourServices</key>
<array>
	<string>_pusher._tcp</string>
	<string>_pusher._udp</string>
</array>
<key>NSLocalNetworkUsageDescription</key>
<string>To allow Pusher App to discover this device on the network.</string>
```

## UI Preview

![Send push notification to iOS device](preview-push-ios-device.png)
![Send push notification to iOS simulator](preview-push-ios-simulator.png)
![Send push notification to Android device](preview-push-android-device.png)

