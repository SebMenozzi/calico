import Cocoa

let delegate = AppDelegate()
NSApplication.shared.delegate = delegate
NSApplication.shared.setActivationPolicy(.regular)

_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
