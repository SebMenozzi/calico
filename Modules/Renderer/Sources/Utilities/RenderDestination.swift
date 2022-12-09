import MetalKit

// MARK: - RenderDestination

/// Defines requirements that the renderer expects the render destination to meet.
public protocol RenderDestination {
    var colorPixelFormat: MTLPixelFormat { get set }
    var depthStencilPixelFormat: MTLPixelFormat { get set }
}

extension MTKView: RenderDestination { }
