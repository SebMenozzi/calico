#if os(iOS) || os(tvOS)
import UIKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.rootViewController = ViewController()

        return true
    }
}
#else
import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let rect = NSRect(x: 0, y: 0, width: 1280, height: 720)

        window = NSWindow(
            contentRect: rect,
            styleMask: [.miniaturizable, .closable, .resizable, .titled],
            backing: .buffered, defer: false
        )
        window?.center()
        window?.title = "Calico"
        window?.makeKeyAndOrderFront(nil)
        
        let viewController = ViewController()
        window?.contentView?.addSubview(viewController.view)
    }

}
#endif
