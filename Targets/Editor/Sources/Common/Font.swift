import AppKit

enum Font {
    
    static func largeTitle(_ weight: NSFont.Weight) -> NSFont {
        return NSFont.systemFont(ofSize: 26, weight: weight)
    }
    
    static func title1(_ weight: NSFont.Weight) -> NSFont {
        return NSFont.systemFont(ofSize: 22, weight: weight)
    }

    static func title2(_ weight: NSFont.Weight) -> NSFont {
        return NSFont.systemFont(ofSize: 17, weight: weight)
    }

    static func title3(_ weight: NSFont.Weight) -> NSFont {
        return NSFont.systemFont(ofSize: 15, weight: weight)
    }

    static func body(_ weight: NSFont.Weight) -> NSFont {
        return NSFont.systemFont(ofSize: 13, weight: weight)
    }

    static func callout(_ weight: NSFont.Weight) -> NSFont {
        return NSFont.systemFont(ofSize: 12, weight: weight)
    }
    
    static func small(_ weight: NSFont.Weight) -> NSFont {
        return NSFont.systemFont(ofSize: 8, weight: weight)
    }
}
