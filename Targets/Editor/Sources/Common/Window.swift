import AppKit
import Platform_macOS

final class Window: NSWindow {

    init(contentRect: NSRect, contentViewController: PlatformViewController) {
        super.init(
            contentRect: contentRect,
            styleMask: [
                .titled,
                .closable,
                .resizable,
                .miniaturizable,
                .fullSizeContentView
            ],
            backing: .buffered,
            defer: false
        )
        
        self.contentView = contentViewController.view

        setup()
    }
    
    // MARK: - Setup
    
    private func setup() {
        alphaValue = 1.0
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        toolbar = NSToolbar()
        toolbar?.showsBaselineSeparator = false
        standardWindowButton(.zoomButton)?.isEnabled = false
    }
}
