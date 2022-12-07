#if os(iOS) || os(tvOS)
import UIKit
typealias PlatformView = UIView
#else
import AppKit
typealias PlatformView = NSView
#endif

class View: PlatformView {

   init() {
        super.init(frame: .zero)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    #if os(macOS)
    var isUserInteractionsEnabled = true
    
    override func mouseDown(with event: NSEvent) {
        if isUserInteractionsEnabled {
            super.mouseDown(with: event)
        }
    }

    override func mouseUp(with event: NSEvent) {
        if isUserInteractionsEnabled {
            super.mouseUp(with: event)
        }
    }
    #endif
}
