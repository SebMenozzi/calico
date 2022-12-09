/*
import AppKit
import MetalKit
import Renderer_macOS

public final class RenderViewController: NSViewController {
    
    private enum Constants {
        static let sidebarWidth: CGFloat = 250
    }
    
    private var renderView: MTKView!
    
    private var renderer: Renderer!
    private var scene: Scene!
    private var size: CGSize = .zero
    
    private var useSinglePassDeferred: Bool {
        #if targetEnvironment(simulator)
        return false
        #else
        let device = MTLCreateSystemDefaultDevice()!
        return device.supportsFamily(.apple1)
        #endif
    }

    public override func loadView() {
        self.view = NSView()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Unable to create default Metal Device")
        }
        
        renderView = MTKView(frame: .zero, device: device)
        view.addSubview(renderView)
        renderView.fillSuperview()

        // Set the pixel formats of the render destination.
        renderView.depthStencilPixelFormat = .depth32Float_stencil8
        renderView.colorPixelFormat = .bgra8Unorm_srgb
        
        scene = Scene(device: device)

        if useSinglePassDeferred {
            renderer = SinglePassDeferredRenderer(
                device: device,
                scene: scene,
                renderDestination: renderView
            ) { [weak self] in
                
                guard let self = self else { return }
                                        
                if !self.renderView.isPaused {
                    self.scene.update()
                }
            }
        } else {
            renderer = TraditionalDeferredRenderer(
                device: device,
                scene: scene,
                renderDestination: renderView
            ) { [weak self] in
                guard let self = self else { return }
                                        
                if !self.renderView.isPaused {
                    self.scene.update()
                }
            }
        }
        
        // Getter for the currentDrawable, note that this is optional.
        // The renderer does not need to draw to a drawable, it could draw to an offscreen texture instead.
        renderer.getCurrentDrawable = { [weak self] in
            self?.renderView.currentDrawable
        }
        
        renderer.mtkView(renderView, drawableSizeWillChange: renderView.drawableSize)
        
        // Called when the drawable size changes, again, this is optional.
        // The renderer does not need to draw to a drawable, it could draw to an offscreen texture instead.
        renderer.drawableSizeWillChange = drawableSizeWillChange
        
        // The renderer serves as the MTKViewDelegate.
        renderView.delegate = renderer
    }
    
    private var drawableSizeWillChange: ((MTLDevice, CGSize, MTLStorageMode) -> Void) { { [weak self] device, size, gBufferStorageMode in
        guard size.width != 0 && size.height != 0 else {
            return
        }
        
        self?.scene.camera.updateProjection(drawableSize: size)
    
        // Re-create GBuffer textures to match the new drawable size.
        self?.scene.gBufferTextures.makeTextures(device: device, size: size, storageMode: gBufferStorageMode)
    }}
}
*/
