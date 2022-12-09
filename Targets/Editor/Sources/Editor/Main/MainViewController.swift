import AppKit
import Platform_macOS
import PeerTalk_macOS

final class MainViewController: PlatformViewController {

    // We use a serial queue that we toggle depending on if we are connected or
    // not. When we are not connected to a peer, the queue is running to handle
    // "connect" tries. When we are connected to a peer, the queue is suspended
    // thus no longer trying to connect.
    private lazy var notConnectedQueue: DispatchQueue = DispatchQueue(label: "PTExample.notConnectedQueue")
    private var notConnectedQueueSuspended: Bool = false

    private let usbMuxManager: USBMuxManager = USBMuxManager.shared()
    private weak var connectedChannel: PTChannel? {
        didSet {
            // Toggle the notConnectedQueue_ depending on if we are connected or not
            if (connectedChannel == nil && notConnectedQueueSuspended) {
                notConnectedQueue.resume()
                notConnectedQueueSuspended = false
            } else if (connectedChannel != nil && !notConnectedQueueSuspended) {
                notConnectedQueue.suspend()
                notConnectedQueueSuspended = true
            }

            if (connectedChannel == nil && connectingToDeviceID != nil) {
                enqueueConnectToUSBDevice()
            }
        }
    }

    private var connectingToDeviceID: Int?
    private var connectedDeviceID: Int?

    private var pings: [UInt32: Date] = [:]

    private enum Frame: UInt32 {
        case deviceInfo = 100
        case textMessage = 101
        case ping = 102
        case pong = 103
    }

    private enum Constants {
        static let sidebarWidth: CGFloat = 250
    }
    
    override func loadView() {
        self.view = PlatformView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let splitViewController = NSSplitViewController()
        view.addSubview(splitViewController.view)
        splitViewController.view.fillSuperview()

        let sidebarItem = NSSplitViewItem(sidebarWithViewController: SidebarViewController())
        sidebarItem.canCollapse = true
        sidebarItem.maximumThickness = Constants.sidebarWidth
        splitViewController.addSplitViewItem(sidebarItem)
        
        let renderItem = NSSplitViewItem(sidebarWithViewController: SidebarViewController())
        renderItem.canCollapse = false
        splitViewController.addSplitViewItem(renderItem)

        /// Start listening for device attached/detached notifications
        startListeningForDevices()

        /// Start pinging
        ping()
    }

    func append(output message: String) {
        print(message)
    }
}

// MARK: - Ping

extension MainViewController {

    @objc private func ping() {
        if let connectedChannel = connectedChannel {
            let tag = connectedChannel.protocol.newTag()
            let now = Date()
            pings[tag] = now

            connectedChannel.sendFrame(type: Frame.ping.rawValue, tag: tag, payload: nil) { [weak self] error in
                guard let self = self else { return }

                self.perform(#selector(self.ping), with: nil, afterDelay: PTPingDelay)

                if error != nil {
                    self.pings.removeValue(forKey: tag)
                }
            }
        } else {
            perform(#selector(self.ping), with: nil, afterDelay: PTPingDelay)
        }
    }

    private func pongWithTag(tag: UInt32) {
        if let pingDate = pings[tag] {
            pings.removeValue(forKey: tag)

            print("Ping total roundtrip time: \(Date().timeIntervalSince(pingDate) * 1000) ms")
        }
    }
}

// MARK: - PTChannelDelegate

extension MainViewController: PTChannelDelegate {

    func channel(_ channel: PTChannel, shouldAcceptFrame type: UInt32, tag: UInt32, payloadSize: UInt32) -> Bool {
        if type != Frame.deviceInfo.rawValue &&
            type != Frame.textMessage.rawValue &&
            type != Frame.ping.rawValue &&
            type != Frame.pong.rawValue &&
            type != PTFrameTypeEndOfStream {
            print("Unexpected frame of type \(type)")
            channel.close()

            return false
        }

        return true
    }

    func channel(_ channel: PTChannel, didReceiveFrame type: UInt32, tag: UInt32, payload: Data?) {
        if type == Frame.deviceInfo.rawValue {
            guard let payload = payload else { return }

            if let deviceInfo = try? PropertyListSerialization.propertyList(from: payload, options: PropertyListSerialization.ReadOptions.mutableContainers, format: nil) {
                print("Connected to: \(deviceInfo)")
            }
        } else if type == Frame.textMessage.rawValue {
            guard let payload = payload else { return }

            // We need to convert this code in Objective-C to Swift
            //
            // PTExampleTextFrame *textFrame = (PTExampleTextFrame*)payload.bytes;
            // textFrame->length = ntohl(textFrame->length);
            // NSString *message = [[NSString alloc] initWithBytes:textFrame->utf8text length:textFrame->length encoding:NSUTF8StringEncoding];

            payload.withUnsafeBytes { (ptr: UnsafePointer<PTExampleTextFrame>) in
                let mutablePtr = UnsafeMutablePointer(mutating: ptr)
                mutablePtr.pointee.length = CFSwapInt32(mutablePtr.pointee.length)

                let bytesLength = Int(mutablePtr.pointee.length)
                // I don't understand why this works
                let bytesPtr = mutablePtr.advanced(by: 1)

                let message = String(bytesNoCopy: bytesPtr, length: bytesLength, encoding: .utf8, freeWhenDone: false)

                print("MESSAGE: \(message ?? "???")")
            }

        } else if type == Frame.pong.rawValue {
            pongWithTag(tag: tag)
        }
    }

    func channelDidEnd(_ channel: PTChannel, error: Error?) {
        if let userInfo = channel.userInfo as? Int,
            let connectedDeviceID = connectedDeviceID,
            connectedDeviceID == userInfo {
            didDisconnectFromDevice(deviceID: connectedDeviceID)
        }

        if connectedChannel == channel {
            connectedChannel = nil
        }
    }
}

// MARK: - Wired device connections

extension MainViewController {

    private func startListeningForDevices() {
        NotificationCenter.default.addObserver(forName: .PTUSBDeviceDidAttach, object: usbMuxManager, queue: nil) { [weak self] notification in
            guard let self = self,
                  let deviceID = notification.userInfo?[USBMuxPacketKey.deviceID] as? Int else {
                return
            }

            print("Attached device ID: \(deviceID)")

            self.notConnectedQueue.async {
                if (self.connectingToDeviceID == nil || deviceID != self.connectingToDeviceID) {
                    self.disconnectFromCurrentChannel()

                    self.connectingToDeviceID = deviceID
                    self.enqueueConnectToUSBDevice()
                }
            }
        }

        NotificationCenter.default.addObserver(forName: .PTUSBDeviceDidDetach, object: usbMuxManager, queue: nil) {  [weak self] notification in
            guard let self = self,
                  let deviceID = notification.userInfo?[USBMuxPacketKey.deviceID] as? Int else {
                return
            }

            print("Detached device ID: \(deviceID)")

            if self.connectingToDeviceID == deviceID {
                self.connectingToDeviceID = nil

                if let connectedChannel = self.connectedChannel {
                    connectedChannel.close()
                }
            }
        }
    }

    private func didDisconnectFromDevice(deviceID: Int) {
        if connectedDeviceID == deviceID {
            connectedDeviceID = nil
        }
    }

    private func disconnectFromCurrentChannel() {
        if connectedDeviceID != nil && connectedChannel != nil {
            connectedChannel?.close()
            connectedChannel = nil
        }
    }

    @objc private func enqueueConnectToUSBDevice() {
        notConnectedQueue.async {
            DispatchQueue.main.async {
                self.connectToUSBDevice()
            }
        }
    }

    private func connectToUSBDevice() {
        guard let connectingToDeviceID = connectingToDeviceID else {
            return
        }

        let channel = PTChannel(protocol: nil, delegate: self)
        channel.userInfo = connectingToDeviceID as Any

        channel.connect(to: PTExampleProtocolIPv4PortNumber, with: usbMuxManager, deviceID: NSNumber(value: connectingToDeviceID)) { [weak self] error in
            guard let self = self else { return }

            if let error = error {
                print("Failed to connect to device \(channel.userInfo): \(error)")

                self.perform(#selector(self.enqueueConnectToUSBDevice), with: nil, afterDelay: PTAppReconnectDelay)
            } else {
                self.connectedDeviceID = connectingToDeviceID
                self.connectedChannel = channel
            }
        }
    }
}
