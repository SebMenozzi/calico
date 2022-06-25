#if os(iOS) || os(tvOS)
import UIKit
#else
import AppKit
#endif

final class RootViewController: PlatformViewController {
    
    #if os(macOS)
    override func loadView() {
        self.view = NSView()
    }
    #endif

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer = CALayer()
        view.layer?.backgroundColor = NSColor.red.cgColor
    }
}
