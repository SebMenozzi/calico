public struct ECSEntity {

    public let entityID: ECSEntityID
    public var componentMask = ECSComponentMask()
    
    public init(id: ECSEntityID) {
        entityID = id
    }
}

extension ECSEntity: CustomStringConvertible {

    public var description: String {
        "ECSEntity: id=\(entityID), \(componentMask)"
    }
}
