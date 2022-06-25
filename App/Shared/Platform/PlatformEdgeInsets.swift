#if os(iOS) || os(tvOS)
import UIKit
public typealias PlatformEdgeInsets = UIEdgeInsets
#else
import AppKit
public typealias PlatformEdgeInsets = NSEdgeInsets
#endif
