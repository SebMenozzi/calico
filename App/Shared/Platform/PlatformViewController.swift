#if os(iOS) || os(tvOS)
import UIKit
public typealias PlatformViewController = UIViewController
#else
import AppKit
public typealias PlatformViewController = NSViewController
#endif