#if os(iOS) || os(tvOS)
import UIKit
public typealias PlatformView = UIView
#else
import AppKit
public typealias PlatformView = NSView
#endif
