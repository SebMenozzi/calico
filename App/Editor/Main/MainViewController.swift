import AppKit

final class MainViewController: PlatformViewController {
    
    private enum Constants {
        static let sidebarWidth: CGFloat = 250
    }
    
    override func loadView() {
        self.view = NSView(frame: NSRect(x: 0, y: 0, width: 1280, height: 720))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let splitViewController = NSSplitViewController()
        view.addSubview(splitViewController.view)
        splitViewController.view.fillSuperview()

        let sidebarItem = NSSplitViewItem(sidebarWithViewController: SidebarViewController())
        sidebarItem.canCollapse = true
        sidebarItem.maximumThickness = Constants.sidebarWidth
        splitViewController.addSplitViewItem(sidebarItem)
        
        let renderItem = NSSplitViewItem(sidebarWithViewController: EditorViewController())
        renderItem.canCollapse = false
        splitViewController.addSplitViewItem(renderItem)
    }
}
