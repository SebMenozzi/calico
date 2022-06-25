import CoreGraphics
import simd

struct Camera {
    var nearPlane: Float
    var farPlane: Float
    var fieldOfView: Float
    var projectionMatrix = Float4x4()
    
    mutating func updateProjection(drawableSize: CGSize) {
        let fov = fieldOfView.degreesToRadians
        let aspectRatio = Float(drawableSize.width) / Float(drawableSize.height)
        
        projectionMatrix = Float4x4.perspectiveProjection(
            fov: fov,
            aspectRatio: aspectRatio,
            near: nearPlane,
            far: farPlane
        )
    }
}
