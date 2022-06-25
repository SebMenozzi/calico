import AppKit

public final class Window: NSWindow {

    public init(contentViewController: NSViewController) {
        super.init(
            contentRect: .zero,
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
        
        self.contentViewController = contentViewController

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
