import AppKit
import ECS

public final class TransformComponent: Component {
    
    public var title: String { "Transform" }
    public var enabled: Bool = true
    public var icon: NSImage { NSImage(named: .caution)! }
    
    public var position: Float3 = [0, 0, 0]
    public var rotation: Float3 = [0, 0, 0]
    public var scale: Float3 = [0, 0, 0]

    public required init() {}
}
