import UIKit
import Platform_iOS
import PeerTalk_iOS

final class ViewController: PlatformViewController {

    private lazy var notConnectedQueue: DispatchQueue = DispatchQueue(label: "PTExample.notConnectedQueue")

    private weak var localServerChannel: PTChannel?
    private weak var peerChannel: PTChannel?

    override func viewDidLoad() {
        super.viewDidLoad()

        enqueueListen()
    }

    private func listen() {
        // Create a new channel that is listening on our IPv4 port
        let channel = PTChannel(protocol: nil, delegate: self)

        channel.listen(on: in_port_t(PTExampleProtocolIPv4PortNumber), IPv4Address: INADDR_ANY) { [weak self] error in
            guard let self = self else { return }

            if let error = error {
                print("Error while listening: \(error)")

                let isAlreadyListening = error._domain == NSPOSIXErrorDomain && error._code == 48

                if !isAlreadyListening {
                    self.perform(#selector(self.enqueueListen), with: nil, afterDelay: PTAppReconnectDelay)
                }
            } else {
                print("Listening on 127.0.0.1:\(PTExampleProtocolIPv4PortNumber)")

                self.localServerChannel = channel
            }
        }
    }

    @objc private func enqueueListen() {
        notConnectedQueue.async {
            DispatchQueue.main.async {
                self.listen()
            }
        }
    }

    private func sendMessage(message: String) {
        if let peerChannel = peerChannel {
            let payload = PTExampleTextCreateMessagePayload(message)

            peerChannel.sendFrame(type: PTExampleFrameTypeTextMessage.rawValue, tag: PTFrameNoTag, payload: payload) { error in
                if let error = error {
                    print("Failed to send message: \(error)")
                }
            }

            print("[YOU] \(message)")
        } else {
            print("Can not send message — not connected")
        }
    }
}

// MARK: - Communicating

extension ViewController {

    private func sendDeviceInfo() {
        guard let peerChannel = peerChannel else {
            return
        }

        print("Sending device info to \(peerChannel.userInfo)")

        let screen = UIScreen.main
        let screenSize = screen.bounds.size
        let device = UIDevice.current

        let plist: [String: Any] = [
            "localizedModel": device.localizedModel,
            "multitaskingSupported": device.isMultitaskingSupported,
            "name": device.name,
            "orientation": device.orientation.isLandscape ? "landscape" : "portrait",
            "systemName": device.systemName,
            "systemVersion": device.systemVersion,
            "screenSize": screenSize.dictionaryRepresentation,
            "screenScale": Double(screen.scale)
        ]

        let payload = try? PropertyListSerialization.data(fromPropertyList: plist, format: .binary, options: .zero)

        peerChannel.sendFrame(type: PTExampleFrameTypeDeviceInfo.rawValue, tag: PTFrameNoTag, payload: payload) { error in
            if let error = error {
                print("Failed to send PTExampleFrameTypeDeviceInfo: \(error)")
            }
        }
    }
}

// MARK: - PTChannelDelegate

extension ViewController: PTChannelDelegate {

    func channel(_ channel: PTChannel, shouldAcceptFrame type: UInt32, tag: UInt32, payloadSize: UInt32) -> Bool {
        if channel != peerChannel {
            // A previous channel that has been canceled but not yet ended. Ignore.
            return false
        } else if type != PTExampleFrameTypeTextMessage.rawValue && type != PTExampleFrameTypePing.rawValue {
            print("Unexpected frame of type: \(type)")
            channel.close()
            return false
        }

        return true
    }

    func channel(_ channel: PTChannel, didReceiveFrame type: UInt32, tag: UInt32, payload: Data?) {
        if type == PTExampleFrameTypeTextMessage.rawValue {
            guard let payload = payload else { return }

            if let message = PTExampleTextRetrieveMessageFromPayload(payload) {
                print("[\(channel.userInfo)] \(message)")
            }
        } else if let peerChannel = peerChannel, type == PTExampleFrameTypePing.rawValue {
            peerChannel.sendFrame(type: PTExampleFrameTypePong.rawValue, tag: tag, payload: nil)
        }
    }

    func channelDidEnd(_ channel: PTChannel, error: Error?) {
        if let error = error {
            print("\(channel.userInfo) ended with error: \(error)")
        } else {
            print("Disconnected from \(channel.userInfo)")
        }

        localServerChannel = nil
        peerChannel = nil

        perform(#selector(enqueueListen), with: nil, afterDelay: PTAppReconnectDelay)
    }

    func channel(_ channel: PTChannel, didAcceptConnection otherChannel: PTChannel, from address: PTAddress) {
        if let peerChannel = peerChannel {
            peerChannel.cancel()
        }

        peerChannel = otherChannel
        peerChannel?.userInfo = address

        print("Connected to \(address)")

        // Send some information about ourselves to the other end
        sendDeviceInfo()
    }
}

extension FixedWidthInteger {

    var data: Data {
        var bytes = self
        return Data(bytes: &bytes, count: MemoryLayout.size(ofValue: self))
    }
}
