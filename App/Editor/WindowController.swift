import AppKit

public final class WindowController: NSWindowController {

    public init() {
        super.init(window: nil)
        
        presentMainWindow()
        // presentCreateProjectWindow()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func presentMainWindow() {
        let vc = MainViewController()
        
        window = Window(contentViewController: vc)
        window?.makeKeyAndOrderFront(self)
        window?.center()
    }
    
    private func presentCreateProjectWindow() {
        let vc = CreateProjectViewController()
        
        window = Window(contentViewController: vc)
        window?.styleMask.remove(.resizable)
        window?.makeKeyAndOrderFront(self)
        window?.center()
    }
}
