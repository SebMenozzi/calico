public typealias ECSEntityID = UInt32
public typealias ECSComponentID = UInt32

extension ECSEntityID {

    public static let invalid: ECSEntityID = ECSEntityID.max
}
