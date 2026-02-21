import SceneKit

/// Represents an obstacle on the slope
class Obstacle {
    let node: SCNNode
    let type: ObstacleType
    let halfExtent: SCNVector3

    init(node: SCNNode, type: ObstacleType, halfExtent: SCNVector3) {
        self.node = node
        self.type = type
        self.halfExtent = halfExtent
    }
}

enum ObstacleType {
    case pineTree
    case rock
    case snowman
    case cabin
    case jumpRamp

    var isJumpable: Bool {
        return self == .jumpRamp
    }
}
