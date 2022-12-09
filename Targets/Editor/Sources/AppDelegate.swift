import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let rect = NSRect(x: 0, y: 0, width: 1280, height: 720)
        let viewController = ViewController()

        let window = Window(contentRect: rect, contentViewController: viewController)
        window.makeKeyAndOrderFront(nil)
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}
