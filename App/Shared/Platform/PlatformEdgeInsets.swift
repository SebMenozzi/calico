#if os(iOS) || os(tvOS)
import UIKit
typealias PlatformEdgeInsets = UIEdgeInsets
#else
import AppKit
typealias PlatformEdgeInsets = NSEdgeInsets
#endif
