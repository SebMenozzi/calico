public struct ECSComponentMask {
    private var mask: UInt32 = 0
    
    public init() {}
    
    public init(indices: [ECSComponentID]) {
        for index in indices {
            set(index)
        }
    }
    
    public mutating func set(_ index: ECSComponentID) {
        mask |= (1 << index)
    }
    
    public mutating func unset(_ index: ECSComponentID) {
        mask &= ~(1 << index)
    }
    
    public mutating func reset() {
        mask = 0
    }
    
    public func isComponentOn(_ index: ECSComponentID) -> Bool {
        let result = (mask >> index) & 1

        return result != 0
    }
    
    public func contains(_ otherMask: ECSComponentMask) -> Bool {
        return otherMask.mask == (otherMask.mask & mask)
    }
}

extension ECSComponentMask: Equatable {

    public static func == (lhs: ECSComponentMask, rhs: ECSComponentMask) -> Bool {
        return lhs.mask == rhs.mask
    }
}

extension ECSComponentMask: CustomStringConvertible {

    public var description: String {
        let str = String(mask, radix: 2).pad(
            with: "0",
            toLength: ECS.maxComponentCount
        )

        return "ECSComponentMask: [\(String(str.reversed()))]"
    }
}

extension String {
    
    fileprivate func pad(with padding: Character, toLength length: Int) -> String {
        let paddingWidth = length - self.count
        guard 0 < paddingWidth else { return self }

        return String(repeating: padding, count: paddingWidth) + self
    }
}
