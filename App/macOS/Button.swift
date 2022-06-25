import AppKit

open class Button: NSButton {
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }   
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func updateTrackingAreas() {
        super.updateTrackingAreas()
        
        let area = NSTrackingArea(
            rect: bounds,
            options: [
                .mouseEnteredAndExited,
                .activeAlways
            ],
            owner: self,
            userInfo: nil
        )
        addTrackingArea(area)
        
        
        super.updateTrackingAreas()
    }
    
    open func mouseEntered() {
        NSCursor.pointingHand.set()
        
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.2
            self.animator().alphaValue = 0.5
        })
    }
    
    open func mouseExited() {
        NSCursor.arrow.set()
        
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.2
            self.animator().alphaValue = 1.0
        })
    }
    
    public override func mouseEntered(with event: NSEvent) {
        mouseEntered()
    }

    public override func mouseExited(with event: NSEvent) {
        mouseExited()
    }
}
