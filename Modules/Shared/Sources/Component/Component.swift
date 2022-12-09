import AppKit
import ECS

public protocol Component: ECSComponent {

    var title: String { get }
    var enabled: Bool { get set }
    var icon: NSImage { get }
}
