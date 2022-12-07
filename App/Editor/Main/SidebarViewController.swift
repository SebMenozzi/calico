import AppKit

final class SidebarViewController: NSViewController {
    
    private let visualEffectView = NSVisualEffectView()..{
        $0.material = .sidebar
        $0.blendingMode = .behindWindow
    }

    override func loadView() {
        self.view = NSView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //view.addSubview(visualEffectView)
        //visualEffectView.fillSuperview()
    }
}
