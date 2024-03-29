import AppKit

open class ImageView: NSImageView {
  
    open override var image: NSImage? {
        set {
            self.layer = CALayer()
            self.layer?.contentsGravity = CALayerContentsGravity.resizeAspectFill
            self.layer?.contents = newValue
            self.wantsLayer = true

            super.image = newValue
        }

        get {
            return super.image
        }
    }
}
