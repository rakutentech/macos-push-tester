import Foundation
import MultipeerConnectivity

public protocol APNSServiceBrowsing: AnyObject {
    func didUpdateDevices()
}

public final class APNSServiceBrowser: NSObject {
    public private(set) var devices: [APNSServiceDevice]
    private var browser: MCNearbyServiceBrowser
    private var peerIDToDeviceMap: [MCPeerID: APNSServiceDevice]
    private var _searching: Bool

    public weak var delegate: APNSServiceBrowsing?

    public var searching: Bool {
        get {
            return _searching
        }
        set(value) {
            _searching = value

            if _searching {
                browser.startBrowsingForPeers()

            } else {
                browser.stopBrowsingForPeers()
            }
        }
    }

    public init(serviceType: String) {
        peerIDToDeviceMap = [:]
        devices = []
        _searching = false
        let peerID = MCPeerID(displayName: Host.current().localizedName ?? "")
        browser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
        super.init()
        browser.delegate = self
    }
}

extension APNSServiceBrowser: MCNearbyServiceBrowserDelegate {
    public func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        guard let token = info?["token"], let appID = info?["appID"] else {
            return
        }
        let device = APNSServiceDevice(displayName: peerID.displayName,
                                       token: token,
                                       appID: appID)
        DispatchQueue.main.async {
            self.devices.insert(device, at: self.devices.count)
            self.peerIDToDeviceMap[peerID] = device
            self.delegate?.didUpdateDevices()
        }
    }

    public func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        guard let lostDevice = peerIDToDeviceMap[peerID] else {
            return
        }

        DispatchQueue.main.async {
            guard let foundDevice = self.devices.firstIndex(where: { $0 == lostDevice }) else {
                return
            }

            self.devices.remove(at: foundDevice)
            self.peerIDToDeviceMap.removeValue(forKey: peerID)
            self.delegate?.didUpdateDevices()
        }
    }
}
