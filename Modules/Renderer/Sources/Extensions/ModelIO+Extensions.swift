import ModelIO

// MARK: - MDLVertexDescriptor
extension MDLVertexDescriptor {
    
    /// Returns the vertex buffer attribute descriptor at the specified index.
    public func attribute(_ index: UInt32) -> MDLVertexAttribute {
        guard let attributes = attributes as? [MDLVertexAttribute] else { fatalError() }
        return attributes[Int(index)]
    }
    
    /// Returns the vertex buffer layout descriptor at the specified index.
    public func layout(_ index: UInt32) -> MDLVertexBufferLayout {
        guard let layouts = layouts as? [MDLVertexBufferLayout] else { fatalError() }
        return layouts[Int(index)]
    }
}
