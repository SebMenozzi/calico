import AppKit
import Platform_macOS

final class SidebarViewController: PlatformViewController {
    
    private let visualEffectView = NSVisualEffectView()..{
        $0.material = .sidebar
        $0.blendingMode = .behindWindow
    }

    override func loadView() {
        self.view = NSView()
    }

    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }

    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //view.addSubview(visualEffectView)
        //visualEffectView.fillSuperview()
    }
}
