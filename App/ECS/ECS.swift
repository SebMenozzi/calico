public class ECS {

    static let maxEntityCount: Int = 1000
    static let maxComponentCount: Int = 32
    
    private var entities: [ECSEntity] = []
    private var freeEntities: [ECSEntityID] = []
    private let componentPool = ECSComponentPool()
    
    public init() {}
    
    public func log() {
        print("Entities:")

        for entity in entities {
            print("- \(entity)")
        }
    }
}

// MARK: - Entity Methods

extension ECS {

    public var entityIDs: [ECSEntityID] {
        entities.filter{ $0.entityID != .invalid }.map { $0.entityID }
    }
    
    public func createEntity() -> ECSEntityID {
        guard entities.count < Self.maxEntityCount else {
            assertionFailure("Cannot create entity any more. Reached the limit: \(Self.maxEntityCount)")
            return .invalid
        }
        
        // Check if there is any freed ID
        if !freeEntities.isEmpty {
            let reusedID: ECSEntityID = freeEntities.removeFirst()
            entities[Int(reusedID)] = ECSEntity(id: reusedID)
            return reusedID
        } else {
            let entity = ECSEntity(id: ECSEntityID(entities.count))
            entities.append(entity)
            return entity.entityID
        }
    }
    
    @discardableResult
    public func removeEntity(entityID: ECSEntityID) -> Bool {
        guard checkEntityID(entityID) else {
            return false
        }
        
        componentPool.removeAllComponents(from: entityID)
        entities[Int(entityID)] = ECSEntity(id: .invalid)
        
        freeEntities.append(entityID)
        return true
    }
}

// MARK: - Single Component Methods

extension ECS {
    @discardableResult
    public func createComponent<T>(_ type: T.Type, to entityID: ECSEntityID) -> T? where T: ECSComponent {
        guard checkEntityID(entityID) && checkComponentPoolSize() else {
            return nil
        }
        
        let componentID = componentPool.getComponentID(T.self)
        entities[Int(entityID)].componentMask.set(componentID)  // Int is large enough
        
        let component: T = componentPool.createComponent(T.self, from: entityID)
        return component
    }

    @discardableResult
    public func assignComponent<T>(_ component: T, to entityID: ECSEntityID) -> Bool where T: ECSComponent {
        guard checkEntityID(entityID) && checkComponentPoolSize() else {
            return false
        }
        
        let componentID = componentPool.getComponentID(T.self)
        entities[Int(entityID)].componentMask.set(componentID)
        
        componentPool.assignComponent(component, to: T.self, from: entityID)
        return true
    }
    
    @discardableResult
    public func removeComponent<T>(_ type: T.Type, from entityID: ECSEntityID) -> T? where T: ECSComponent {
        guard checkEntityID(entityID) && checkComponentPoolSize() else {
            return nil
        }
        
        let componentID = componentPool.getComponentID(T.self)
        entities[Int(entityID)].componentMask.unset(componentID)
        return componentPool.removeComponent(type, from: entityID)
    }
    
    public func removeAllComponents(from entityID: ECSEntityID) {
        guard checkEntityID(entityID) && checkComponentPoolSize() else {
            return
        }
        
        entities[Int(entityID)].componentMask.reset()
        componentPool.removeAllComponents(from: entityID)
    }
    
    @discardableResult
    public func getComponent<T>(_ type: T.Type, from entityID: ECSEntityID) -> T where T: ECSComponent {
        guard checkEntityID(entityID) else {
            fatalError("Cannot get component from invalid entity ID (\(entityID)")
        }
        
        return componentPool.getComponent(type, from: entityID)
    }

    @discardableResult
    public func hasComponent<T>(_ type: T.Type, in entityID: ECSEntityID) -> Bool where T: ECSComponent {
        guard checkEntityID(entityID) else {
            return false
        }
        
        let componentID = componentPool.getComponentID(type)
        return entities[Int(entityID)].componentMask.isComponentOn(componentID)
    }
}

// MARK: - Component View Methods
extension ECS {

    public func view<T>(_ type: T.Type) -> [ECSEntityID] where T: ECSComponent {
        let componentID = componentPool.getComponentID(type)
        let mask = ECSComponentMask(indices: [componentID])
        return entities.filter{ $0.componentMask.contains(mask) }.map{ $0.entityID }
    }
    
    public func view<T1, T2>(_ type1: T1.Type, _ type2: T2.Type) -> [ECSEntityID] where T1: ECSComponent, T2: ECSComponent {
        let componentID1 = componentPool.getComponentID(type1)
        let componentID2 = componentPool.getComponentID(type2)
        let mask = ECSComponentMask(indices: [componentID1, componentID2])
        return entities.filter{ $0.componentMask.contains(mask) }.map{ $0.entityID }
    }
    
    public func view<T1, T2, T3>(_ type1: T1.Type, _ type2: T2.Type, _ type3: T3.Type) -> [ECSEntityID] where T1: ECSComponent, T2: ECSComponent, T3: ECSComponent {
        let componentID1 = componentPool.getComponentID(type1)
        let componentID2 = componentPool.getComponentID(type2)
        let componentID3 = componentPool.getComponentID(type3)

        let mask = ECSComponentMask(indices: [componentID1, componentID2, componentID3])
        return entities.filter{ $0.componentMask.contains(mask) }.map{ $0.entityID }
    }
    
    // With Exceptions
    public func view<T>(excepts type: T.Type) -> [ECSEntityID] where T: ECSComponent {
        let componentID = componentPool.getComponentID(type)
        let mask = ECSComponentMask(indices: [componentID])

        return entities.filter{ !$0.componentMask.contains(mask) }.map{ $0.entityID }
    }
    
    public func view<T1, T2>(_ type: T1.Type, excepts exceptType: T2.Type) -> [ECSEntityID] where T1: ECSComponent, T2: ECSComponent {
        let componentID = componentPool.getComponentID(type)
        let exceptComponentID = componentPool.getComponentID(exceptType)
        let mask = ECSComponentMask(indices: [componentID])
        let exceptMask = ECSComponentMask(indices: [exceptComponentID])

        return entities.filter{ $0.componentMask.contains(mask) && !$0.componentMask.contains(exceptMask) }.map{ $0.entityID }
    }
    
    public func view<T1, T2, T3>(_ type1: T1.Type, _ type2: T2.Type, excepts exceptType: T3.Type) -> [ECSEntityID] where T1: ECSComponent, T2: ECSComponent, T3: ECSComponent {
        let componentID1 = componentPool.getComponentID(type1)
        let componentID2 = componentPool.getComponentID(type2)
        let exceptComponentID = componentPool.getComponentID(exceptType)
        let mask = ECSComponentMask(indices: [componentID1, componentID2])
        let exceptMask = ECSComponentMask(indices: [exceptComponentID])

        return entities.filter{ $0.componentMask.contains(mask) && !$0.componentMask.contains(exceptMask) }.map{ $0.entityID }
    }
    
    /// Might be slow, use view()
    public func list<T>(_ type: T.Type) -> [T] where T: ECSComponent {
        return componentPool.getComponentList(type)
    }
}

// MARK: - Check Helper Functions

extension ECS {

    private func checkEntityID(_ entityID: ECSEntityID) -> Bool {

        guard entityID < entities.count else {
            assertionFailure("Cannot assign component to invalid entity ID (\(entityID)!")
            return false
        }
        
        guard entities[Int(entityID)].entityID != .invalid else {
            assertionFailure("The entity (\(entityID) has been removed!")
            return false
        }
        
        return true
    }
    
    private func checkComponentPoolSize() -> Bool {
        guard componentPool.componentTypeCount < Self.maxComponentCount else {
            assertionFailure("Cannot create component. Currently only supports \(Self.maxComponentCount) components!")
            return false
        }
        return true
    }
}
