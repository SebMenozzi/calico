import AppKit

public class Label: NSTextField {

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        isEditable = false
        drawsBackground = false
        isBordered = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}