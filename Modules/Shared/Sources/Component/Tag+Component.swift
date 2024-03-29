import AppKit
import ECS

public class TagComponent: Component {

    public var title: String { "Tag" }
    public var enabled: Bool = true
    public var icon: NSImage { NSImage(named: .caution)! }
    
    public enum Tag: Int {
        case `default` = 0
        case player = 1
        case enemy = 2
        case light = 3
        case camera = 4
        case script = 5
        case skybox = 6
        
        public static let tagStrings: [String] = [
            "Default",
            "Player",
            "Enemy",
            "Light",
            "Camera",
            "Script",
            "Skybox"
        ]
    }
    
    public var tag: Tag = .default
    
    public required init() { }
}