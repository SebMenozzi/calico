import AppKit
import Platform_macOS
import PeerTalk_macOS

final class MainViewController: PlatformViewController {

    private enum Frame: UInt32 {
        case deviceInfo = 100
        case message = 101
        case ping = 102
        case pong = 103
    }

    private enum Constants {
        static let sidebarWidth: CGFloat = 250
    }
    
    override func loadView() {
        self.view = PlatformView()
    }

    private var serverChannel: PTChannel?
    private var peerChannel: PTChannel?

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

        listen()
    }

    private func listen() {
        // Create a new channel that is listening on our IPv4 port
        let channel = PTChannel(protocol: nil, delegate: self)
        channel.listen(on: in_port_t(PTExampleProtocolIPv4PortNumber), IPv4Address: INADDR_LOOPBACK) { error in
            if let error = error {
                self.append(output: "Failed to listen on 127.0.0.1:\(PTExampleProtocolIPv4PortNumber) \(error)")
            } else {
                self.append(output: "Listening on 127.0.0.1:\(PTExampleProtocolIPv4PortNumber)")
                self.serverChannel = channel
            }
        }
    }

    func append(output message: String) {
        print(message)
    }
}

extension MainViewController: PTChannelDelegate {

    func channel(_ channel: PTChannel, didRecieveFrame type: UInt32, tag: UInt32, payload: Data?) {
        guard let type = Frame(rawValue: type) else {
            return
        }

        switch type {
        case .message:
            guard let payload = payload else {
                return
            }
            payload.withUnsafeBytes { buffer in
                let textBytes = buffer[(buffer.startIndex + MemoryLayout<UInt32>.size)...]
                if let message = String(bytes: textBytes, encoding: .utf8) {
                  append(output: "[\(channel.userInfo)] \(message)")
                }
            }
        case .ping:
            peerChannel?.sendFrame(type: Frame.pong.rawValue, tag: 0, payload: nil, callback: nil)
        default:
            break
        }
    }

    func channel(_ channel: PTChannel, shouldAcceptFrame type: UInt32, tag: UInt32, payloadSize: UInt32) -> Bool {
        guard channel == peerChannel else {
            return false
        }

        guard let type = Frame(rawValue: type),
              type == .ping || type == .message else {
            print("Unexpected frame of type: \(type)")
            return false
        }

        return true
    }

    func channel(_ channel: PTChannel, didAcceptConnection otherChannel: PTChannel, from address: PeerAddress) {
        peerChannel?.cancel()
        peerChannel = otherChannel
        peerChannel?.userInfo = address

        self.append(output: "Connected to \(address)")
    }

    func channelDidEnd(_ channel: PTChannel, error: Error?) {
        if let error = error {
            append(output: "\(channel) ended with \(error)")
        } else {
            append(output: "Disconnected from \(channel.userInfo)")
        }
    }
}
