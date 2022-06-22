#if os(iOS) || os(tvOS)
import UIKit
typealias PlatformViewController = UIViewController
#else
import AppKit
typealias PlatformViewController = NSViewController
#endif

import MetalKit

final class ViewController: PlatformViewController {

    var renderView: MTKView!
    
    //var renderer: Renderer!
    //var scene: Scene!
    
    #if os(macOS)
    override func loadView() {
        self.view = NSView(frame: NSRect(x: 0, y: 0, width: 1280, height: 720))
    }
    #endif

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Unable to create default Metal Device")
        }
        
        renderView = MTKView(frame: .zero, device: device)
        renderView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(renderView)
        
        NSLayoutConstraint.activate([
            renderView.topAnchor.constraint(equalTo: view.topAnchor),
            renderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            renderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            renderView.bottomAnchor.constraint(equalTo: view.bottomAnchor)]
        )

        // Set the pixel formats of the render destination.
        renderView.depthStencilPixelFormat = .depth32Float_stencil8
        renderView.colorPixelFormat = .bgra8Unorm_srgb
        
        /*
        scene = Scene(device: device)

        if useSinglePassDeferred {
            renderer = SinglePassDeferredRenderer(device: device,
                                                scene: scene,
                                                renderDestination: renderView) { [weak self] in
                
                guard let self = self else { return }
                                        
                if !self.renderView.isPaused {
                    self.scene.update()
                }
            }
        } else {
            renderer = TraditionalDeferredRenderer(device: device,
                                                   scene: scene,
                                            renderDestination: renderView) { [weak self] in
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
        
        // Called when the drawable size changes, again, this is optional.
        // The renderer does not need to draw to a drawable, it could draw to an offscreen texture instead.
        renderer.drawableSizeWillChange = drawableSizeWillChange
        
        renderer.mtkView(renderView, drawableSizeWillChange: renderView.drawableSize)
        
        // The renderer serves as the MTKViewDelegate.
        renderView.delegate = renderer
        */
    }
    
    /*
    var drawableSizeWillChange: ((MTLDevice, CGSize, MTLStorageMode) -> Void) { { [weak self] device, size, gBufferStorageMode in
            self?.scene.camera.updateProjection(drawableSize: size)
        
            // Re-create GBuffer textures to match the new drawable size.
            self?.scene.gBufferTextures.makeTextures(device: device, size: size, storageMode: gBufferStorageMode)
        }
    }
    
    var useSinglePassDeferred: Bool {
        #if targetEnvironment(simulator)
        return false
        #else
        let device = MTLCreateSystemDefaultDevice()!
        return device.supportsFamily(.apple1)
        #endif
    }
    */
}
