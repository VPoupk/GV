import SceneKit

/// Represents a collectible item on the slope
class Collectible {
    let node: SCNNode
    let type: CollectibleType
    var isCollected = false

    init(node: SCNNode, type: CollectibleType) {
        self.node = node
        self.type = type
    }
}

enum CollectibleType {
    case coin
    case speedBoost
    case shield
    case scoreMultiplier

    var displayName: String {
        switch self {
        case .coin: return "Coin"
        case .speedBoost: return "Speed Boost"
        case .shield: return "Shield"
        case .scoreMultiplier: return "Score Multiplier"
        }
    }
}
