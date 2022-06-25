public class Object {

    public var name: String = "Object"
    public var enabled: Bool = true
    
    public let entityID: ECSEntityID
    
    internal weak var scene: Scene!
        
    init(_ scene: Scene,
        name: String = "Object",
        position: Float3 = [0, 0, 0],
        rotation: Float3 = [0, 0, 0],
        scale: Float3 = [1, 1, 1]
    ) {

        self.scene = scene
        self.name = name
        
        entityID = scene.ecs.createEntity()
        
        let tagComponent = TagComponent()
        let transformComponent = TransformComponent()..{
            $0.position = position
            $0.rotation = rotation
            $0.scale = scale
        }
        
        addComponent(tagComponent)
        addComponent(transformComponent)
    }
}

extension Object: Equatable {

    public static func == (lhs: Object, rhs: Object) -> Bool {
        return lhs.entityID == rhs.entityID
    }
}

extension Object: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(entityID)
    }
}

// MARK: - Component Methods

extension Object {

    public func addComponent<T: Component>(_ component: T) {
        scene.ecs.assignComponent(component, to: entityID)
    }
    
    public func addComponent<T: Component>(_ type: T.Type) {
        let component = scene.ecs.createComponent(type, to: entityID)
    }
    
    public func hasComponent<T: Component>(_ type: T.Type) -> Bool {
        return scene.ecs.hasComponent(type, in: entityID)
    }
    
    public func getComponent<T: Component>(_ type: T.Type) -> T {
        return scene.ecs.getComponent(type, from: entityID)
    }
    
    @discardableResult
    public func removeComponent<T: Component>(_ component: T) -> T? {
        guard !(component is TagComponent) || !(component is TransformComponent) else {
            //Console.warn("\(T.self) cannot be removed from a game object!")
            return nil
        }

        return scene.ecs.removeComponent(T.self, from: entityID)
    }
    
    @discardableResult
    public func removeComponent<T: Component>(_ type: T.Type) -> T? {
        guard type != TagComponent.self && type != TransformComponent.self else {
            //Console.warn("\(T.self) cannot be removed from a game object!")
            return nil
        }

        return scene.ecs.removeComponent(T.self, from: entityID)
    }
}
