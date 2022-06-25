import AppKit

public enum Font {
    
    public static func largeTitle(_ weight: NSFont.Weight) -> NSFont {
        return NSFont.systemFont(ofSize: 26, weight: weight)
    }
    
    public static func title1(_ weight: NSFont.Weight) -> NSFont {
        return NSFont.systemFont(ofSize: 22, weight: weight)
    }

    public static func title2(_ weight: NSFont.Weight) -> NSFont {
        return NSFont.systemFont(ofSize: 17, weight: weight)
    }

    public static func title3(_ weight: NSFont.Weight) -> NSFont {
        return NSFont.systemFont(ofSize: 15, weight: weight)
    }

    public static func body(_ weight: NSFont.Weight) -> NSFont {
        return NSFont.systemFont(ofSize: 13, weight: weight)
    }

    public static func callout(_ weight: NSFont.Weight) -> NSFont {
        return NSFont.systemFont(ofSize: 12, weight: weight)
    }
    
    public static func small(_ weight: NSFont.Weight) -> NSFont {
        return NSFont.systemFont(ofSize: 8, weight: weight)
    }
}
