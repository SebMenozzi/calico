extension Float2 {
    
    public init(_ v0: Double, _ v1: Double) {
        self.init(Float(v0), Float(v1))
    }
    
    public init(x: Double, y: Double) {
        self.init(x, y)
    }
    
    public init(_ v0: Int, _ v1: Int) {
        self.init(Float(v0), Float(v1))
    }
    
    public init(x: Int, y: Int) {
        self.init(x, y)
    }
}

extension Float3 {

    public init(xy: Float2, z: Float) {
        self.init(xy.x, xy.y, z)
    }
    
    public init(x: Float, yz: Float2) {
        self.init(x, yz.x, yz.y)
    }
    
    public var xy: Float2 {
        get { Float2(x, y) }
        set {
            x = newValue.x
            y = newValue.y
        }
    }
    public var yz: Float2 {
        get { Float2(y, z) }
        set {
            y = newValue.x
            z = newValue.y
        }
    }
    
    public init(_ v0: Double, _ v1: Double, _ v2: Double) {
        self.init(Float(v0), Float(v1), Float(v2))
    }
    
    public init(x: Double, y: Double, z: Double) {
        self.init(x, y, z)
    }
    
    public init(_ v0: Int, _ v1: Int, _ v2: Int) {
        self.init(Float(v0), Float(v1), Float(v2))
    }
    
    public init(x: Int, y: Int, z: Int) {
        self.init(x, y, z)
    }
}

extension Float4 {

    public init(xy: Float2, zw: Float2) {
        self.init(xy.x, xy.y, zw.x, zw.y)
    }
    
    public init(xyz: Float3, w: Float) {
        self.init(xyz.x, xyz.y, xyz.z, w)
    }
    
    public init(x: Float, yzw: Float3) {
        self.init(x, yzw.x, yzw.y, yzw.z)
    }
    
    public var xyz: Float3 {
        get { Float3(x, y, z) }
        set {
            x = newValue.x
            y = newValue.y
            z = newValue.z
        }
    }
    
    public var xy: Float2 {
        get { Float2(x, y) }
        set {
            x = newValue.x
            y = newValue.y
        }
    }
    
    public var zw: Float2 {
        get { Float2(z, w) }
        set {
            z = newValue.x
            w = newValue.y
        }
    }
    
    public init(_ v0: Double, _ v1: Double, _ v2: Double, _ v3: Double) {
        self.init(Float(v0), Float(v1), Float(v2), Float(v3))
    }
    
    public init(x: Double, y: Double, z: Double, w: Double) {
        self.init(x, y, z, w)
    }
    
    public init(_ v0: Int, _ v1: Int, _ v2: Int, _ v3: Int) {
        self.init(Float(v0), Float(v1), Float(v2), Float(v3))
    }
    
    public init(x: Int, y: Int, z: Int, w: Int) {
        self.init(x, y, z, w)
    }
}
