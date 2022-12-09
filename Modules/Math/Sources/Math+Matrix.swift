import simd

public typealias Float2x2 = simd_float2x2
public typealias Float3x3 = simd_float3x3
public typealias Float4x4 = simd_float4x4

extension Float2x2 {

    public static var identity: Float2x2 {
        get { matrix_identity_float2x2 }
    }
}

extension Float3x3 {

    public static var identity: Float3x3 {
        get { matrix_identity_float3x3 }
    }
}

extension Float4x4 {

    public var upperLeft: Float3x3 {
        let c0 = columns.0.xyz
        let c1 = columns.1.xyz
        let c2 = columns.2.xyz
        
        return Float3x3(columns: (c0, c1, c2))
    }
    
    public var normalMatrix: Float3x3 {
        return inverse.transpose.upperLeft
    }
    
    // MARK: - Static
    
    public static var identity: Float4x4 {
        get { matrix_identity_float4x4 }
    }

    /// Returns a translation matrix specified by x, y, and z components.
    public static func translationMatrix(_ translation: Float3) -> Float4x4 {
        let c0 = Float4(1, 0, 0, 0)
        let c1 = Float4(0, 1, 0, 0)
        let c2 = Float4(0, 0, 1, 0)
        let c3 = Float4(translation, 1)

        return .init(c0, c1, c2, c3)
    }

    /// Returns a uniform scale matrix specified by x, y, and z components.
    public static func scaleMatrix(_ scale: Float3) -> Float4x4 {
        let c0 = Float4(scale.x, 0, 0, 0)
        let c1 = Float4(0, scale.y, 0, 0)
        let c2 = Float4(0, 0, scale.z, 0)
        let c3 = Float4(0, 0, 0, 1)
        
        return .init(c0, c1, c2, c3)
    }
    
    /// Returns a rotation matrix specified by an angle and an axis or rotation.
    public static func rotationMatrix(angle: Float, axis: Float3) -> Float4x4 {
        let normalizedAxis = simd_normalize(axis)
        
        let ct = cosf(angle)
        let st = sinf(angle)
        let ci = 1 - ct
        let x = normalizedAxis.x
        let y = normalizedAxis.y
        let z = normalizedAxis.z
        
        let c0 = Float4(ct + x * x * ci, y * x * ci + z * st, z * x * ci - y * st, 0)
        let c1 = Float4(x * y * ci - z * st, ct + y * y * ci, z * y * ci + x * st, 0)
        let c2 = Float4(x * z * ci + y * st, y * z * ci - x * st, ct + z * z * ci, 0)
        let c3 = Float4(0, 0, 0, 1)
        
        return .init(c0, c1, c2, c3)
    }
    
    /// Returns a rotation matrix specified by an angle on the x axis.
    public static func rotationMatrix(rotationX angle: Float) -> Float4x4 {
        let ct = cosf(angle)
        let st = sinf(angle)

        let c0 = Float4(1, 0, 0, 0)
        let c1 = Float4(1, ct, st, 0)
        let c2 = Float4(1, -st, ct, 0)
        let c3 = Float4(0, 0, 0, 1)
     
        return .init(c0, c1, c2, c3)
    }

    /// Returns a rotation matrix specified by an angle on the y axis.
    public static func rotationMatrix(rotationY angle: Float) -> Float4x4 {
        let ct = cosf(angle)
        let st = sinf(angle)

        let c0 = Float4(ct, 0, -st, 0)
        let c1 = Float4(0, 1, 0, 0)
        let c2 = Float4(st, 0, ct, 0)
        let c3 = Float4(0, 0, 0, 1)
     
        return .init(c0, c1, c2, c3)
    }

    /// Returns a rotation matrix specified by an angle on the z axis.
    public static func rotationMatrix(rotationZ angle: Float) -> Float4x4 {
        let ct = cosf(angle)
        let st = sinf(angle)

        let c0 = Float4(ct, st, 0, 0)
        let c1 = Float4(-st, ct, 0, 0)
        let c2 = Float4(0, 0, 1, 0)
        let c3 = Float4(0, 0, 0, 1)
     
        return .init(c0, c1, c2, c3)
    }
    
    public static func rotationMatrix(rotationXYZ angle: Float3) -> Float4x4 {
        let X = Self.rotationMatrix(rotationX: angle.x)
        let Y = Self.rotationMatrix(rotationY: angle.y)
        let Z = Self.rotationMatrix(rotationZ: angle.z)

        return Z * Y * X
    }
    
    public static func rotationMatrix(rotationZXY angle: Float3) -> Float4x4 {
        let X = Self.rotationMatrix(rotationX: angle.x)
        let Y = Self.rotationMatrix(rotationY: angle.y)
        let Z = Self.rotationMatrix(rotationZ: angle.z)

        return Y * X * Z
    }
    
    public static func rotationMatrix(rotationYXZ angle: Float3) -> Float4x4 {
        let X = Self.rotationMatrix(rotationX: angle.x)
        let Y = Self.rotationMatrix(rotationY: angle.y)
        let Z = Self.rotationMatrix(rotationZ: angle.z)

        return Z * X * Y
    }
    
    /// Returns a left-handed matrix which looks from a point (the "eye") at a target point, given the up vector.
    public static func lookAt(
        eye: Float3,
        target: Float3,
        up: Float3
    ) -> Float4x4 {
        let z = normalize(target - eye)
        let x = normalize(cross(up, z))
        let y = cross(z, x)

        let t = Float3(-dot(x, eye), -dot(y, eye), -dot(z, eye))
        
        let c0 = Float4(x.x, y.x, z.x, 0)
        let c1 = Float4(x.y, y.y, z.y, 0)
        let c2 = Float4(x.z, y.z, z.z, 0)
        let c3 = Float4(t.x, t.y, t.z, 1)
        
        return .init(c0, c1, c2, c3)
    }
    
    /// Returns a left-handed orthographic projection
    public static func orthographicProjection(
        left: Float,
        right: Float,
        bottom: Float,
        top: Float,
        near: Float,
        far: Float
    )  -> Float4x4 {
        let c0 = Float4(2 / (right - left), 0, 0, 0)
        let c1 = Float4(0, 2 / (top - bottom), 0, 0)
        let c2 = Float4(0, 0, 1 / (far - near), 0)
        let c3 = Float4(
            (left + right) / (left - right),
            (top + bottom) / (bottom - top),
            near / (near - far),
            1
        )

        return .init(c0, c1, c2, c3)
    }
    
    /// Returns a left-handed perspective projection.
    public static func perspectiveProjection(
        fov: Float, 
        aspectRatio: Float, 
        near: Float, 
        far: Float
    ) -> Float4x4 {
        let y = 1 / tanf(fov * 0.5)
        let x = y / aspectRatio
        let z = far / (far - near)

        let c0 = Float4(x, 0, 0, 0)
        let c1 = Float4(0, y, 0, 0)
        let c2 = Float4(0, 0, z, 1)
        let c3 = Float4(0, 0, -near * z, 0)

        return .init(c0, c1, c2, c3)
    }
    
    /// Returns a 3x3 normal matrix from a 4x4 model matrix
    public static func normalMatrix(from modelMatrix: Float4x4) -> Float3x3 {
        let c0 = modelMatrix.columns.0.xyz
        let c1 = modelMatrix.columns.1.xyz
        let c2 = modelMatrix.columns.2.xyz
        
        return .init(c0, c1, c2)
    }
}
