import MetalKit

public struct SubMesh {
    
    // A MetalKit submesh mesh containing the primitive type, index buffer, and index count
    //   used to draw all or part of its parent AAPLMesh object
    let metalKitSubmesh: MTKSubmesh
    
    // Material to set in the Metal Render Command Encoder
    //  before drawing the submesh
    var material: Material?
    
    public init(metalKitSubmesh: MTKSubmesh) {
        self.metalKitSubmesh = metalKitSubmesh
    }
    
    public init(
        modelIOSubmesh: MDLSubmesh,
        metalKitSubmesh: MTKSubmesh,
        textureLoader: MTKTextureLoader
    ) {
        self.metalKitSubmesh = metalKitSubmesh
        
        if let mdlMaterial = modelIOSubmesh.material {
            material = Material(mdlMaterial, textureLoader: textureLoader)
        }
    }
}

