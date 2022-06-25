#if os(iOS) || os(tvOS)
import UIKit
public typealias PlatformView = UIView
#else
import AppKit
public typealias PlatformView = NSView
#endif

public class View: PlatformView {

    public init() {
        super.init(frame: .zero)
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    #if os(macOS)
    public var isUserInteractionsEnabled = true
    
    public override func mouseDown(with event: NSEvent) {
        if isUserInteractionsEnabled {
            super.mouseDown(with: event)
        }
    }

    public override func mouseUp(with event: NSEvent) {
        if isUserInteractionsEnabled {
            super.mouseUp(with: event)
        }
    }
    #endif
}