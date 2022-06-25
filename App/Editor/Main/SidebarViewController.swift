import AppKit

public final class SidebarViewController: NSViewController {
    
    private let visualEffectView = NSVisualEffectView()..{
        $0.material = .sidebar
        $0.blendingMode = .behindWindow
    }

    public override func loadView() {
        self.view = NSView()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        //view.addSubview(visualEffectView)
        //visualEffectView.fillSuperview()
    }
}
