public typealias ECSEntityID = UInt32

extension ECSEntityID {
    public static let invalid: ECSEntityID = ECSEntityID.max
}

public typealias ECSComponentID = UInt32