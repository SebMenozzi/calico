public protocol ECSComponent: AnyObject {
    init()
}

public final class ECSComponentPool {

    // Identifiers
    private var componentIdentifierMap: [Int: ECSComponentID] = [:]  // hash -> ID
    private var componentIDCounter: ECSComponentID = 0
    
    // Pool: ID -> [ECSComponent]
    private var typePools: [ContiguousArray<ECSComponent?>] = []
    
    var componentTypeCount: Int { get {
        return Int(componentIDCounter)
    }}
    
    public init() {}
    
    public func getComponentID<T>(_ type: T.Type) -> ECSComponentID where T: ECSComponent {

        // Each component type has its own type hash value
        let typeHashValue: Int = ObjectIdentifier(type.self).hashValue
        
        if let id = componentIdentifierMap[typeHashValue] {
            return id
        } else {
            // register new component ID
            let newID: ECSComponentID = componentIDCounter
            componentIdentifierMap[typeHashValue] = newID
            // create component pool
            typePools.append(ContiguousArray<ECSComponent?>(repeating: nil, count: ECS.maxEntityCount))
            // update
            componentIDCounter += 1
            return newID
        }
    }
    
    public func getComponent<T>(_ type: T.Type, from entityID: ECSEntityID) -> T where T: ECSComponent {
        guard let component: T = typePools[Int(getComponentID(type))][Int(entityID)] as? T else {
            fatalError("Please use hasComponent() to check component existence before calling getComponent()")
        }
        
        return component
    }
    
    public func getComponentList<T>(_ type: T.Type) -> [T] where T: ECSComponent {
        let list = typePools[Int(getComponentID(type))]

        return list.compactMap({ $0 as? T })
    }
    
    public func createComponent<T>(_ type: T.Type, from entityID: ECSEntityID) -> T where T: ECSComponent {
        let t = T()
        typePools[Int(getComponentID(type))][Int(entityID)] = t
        return t
    }
    
    public func assignComponent<T>(_ component: T, to type: T.Type, from entityID: ECSEntityID) where T: ECSComponent {
        typePools[Int(getComponentID(type))][Int(entityID)] = component
    }
    
    public func removeComponent<T>(_ type: T.Type, from entityID: ECSEntityID) -> T? where T: ECSComponent {
        let componentID = getComponentID(type)
        let component = typePools[Int(componentID)][Int(entityID)]
        typePools[Int(componentID)][Int(entityID)] = nil

        return component as? T
    }
    
    public func removeAllComponents(from entityID: ECSEntityID) {
        for componentID in componentIdentifierMap.values {
            typePools[Int(componentID)][Int(entityID)] = nil
        }
    }
}

extension ECSComponentPool: CustomStringConvertible {

    public var description: String {
        "ComponentPool: count=\(componentTypeCount), IDs=\(componentIdentifierMap.values)"
    }
}
