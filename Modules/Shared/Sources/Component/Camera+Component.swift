import AppKit

public final class CameraComponent: Component {
    
    public var title: String { "Camera" }
    public var enabled: Bool = true
    public var icon: NSImage { NSImage(named: .caution)! }
    
    public var yaw: Float = 0
    public var pitch: Float = 0
    public var roll: Float = 0

    public var direction: Float3 = [0, 0, 0]

    public required init() {}
}
