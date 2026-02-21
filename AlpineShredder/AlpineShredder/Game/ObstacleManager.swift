import SceneKit

/// Manages spawning, positioning, and lifecycle of obstacles on the slope
class ObstacleManager {

    private let obstacleRoot: SCNNode
    private(set) var activeObstacles: [Obstacle] = []
    private var nextSpawnZ: Float = GameConstants.obstacleStartZ
    private var difficultyFactor: Float = 1.0
    private let resortObstacleMultiplier: Float

    init(obstacleRoot: SCNNode) {
        self.obstacleRoot = obstacleRoot
        self.resortObstacleMultiplier = ResortManager.shared.currentResort.obstacleMultiplier
    }

    convenience init(obstacleRoot: SCNNode, resort: Resort) {
        self.init(obstacleRoot: obstacleRoot)
    }

    // MARK: - Update

    func update(playerZ: Float, speed: Float, deltaTime: Float) {
        // Increase difficulty over time
        difficultyFactor = min(1.0 + abs(playerZ) / 500.0, 3.0)

        // Spawn new obstacles ahead of player
        while nextSpawnZ > playerZ - GameConstants.obstacleLookAhead {
            spawnObstacleRow(atZ: nextSpawnZ)
            nextSpawnZ -= GameConstants.obstacleSpacing / (difficultyFactor * resortObstacleMultiplier)
        }

        // Remove obstacles behind player
        activeObstacles.removeAll { obstacle in
            if obstacle.node.position.z > playerZ + GameConstants.obstacleCleanupDistance {
                obstacle.node.removeFromParentNode()
                return true
            }
            return false
        }
    }

    // MARK: - Spawning

    private func spawnObstacleRow(atZ z: Float) {
        let obstacleCount = Int.random(in: 1...min(3, Int(difficultyFactor) + 1))

        // Ensure there's always a path through
        var blockedLanes: Set<Int> = []
        let totalLanes = GameConstants.laneCount

        for _ in 0..<obstacleCount {
            guard blockedLanes.count < totalLanes - 1 else { break }

            var lane: Int
            repeat {
                lane = Int.random(in: 0..<totalLanes)
            } while blockedLanes.contains(lane)
            blockedLanes.insert(lane)

            let xPos = laneToX(lane)
            let zVariation = Float.random(in: -2...2)

            let type = randomObstacleType()
            let obstacle = createObstacle(type: type, at: SCNVector3(xPos, 0, z + zVariation))
            obstacleRoot.addChildNode(obstacle.node)
            activeObstacles.append(obstacle)
        }
    }

    private func randomObstacleType() -> ObstacleType {
        let roll = Float.random(in: 0...1)
        if roll < 0.4 {
            return .pineTree
        } else if roll < 0.65 {
            return .rock
        } else if roll < 0.8 {
            return .snowman
        } else if roll < 0.9 {
            return .cabin
        } else {
            return .jumpRamp
        }
    }

    private func laneToX(_ lane: Int) -> Float {
        let laneWidth = GameConstants.terrainWidth / Float(GameConstants.laneCount)
        let startX = -GameConstants.terrainWidth / 2 + laneWidth / 2
        return startX + Float(lane) * laneWidth + Float.random(in: -1...1)
    }

    // MARK: - Obstacle Creation

    private func createObstacle(type: ObstacleType, at position: SCNVector3) -> Obstacle {
        let node = SCNNode()
        var halfExtent = SCNVector3(0.5, 1.0, 0.5)

        switch type {
        case .pineTree:
            let (treeNode, extent) = createPineTree()
            node.addChildNode(treeNode)
            halfExtent = extent

        case .rock:
            let (rockNode, extent) = createRock()
            node.addChildNode(rockNode)
            halfExtent = extent

        case .snowman:
            let (snowmanNode, extent) = createSnowman()
            node.addChildNode(snowmanNode)
            halfExtent = extent

        case .cabin:
            let (cabinNode, extent) = createCabin()
            node.addChildNode(cabinNode)
            halfExtent = extent

        case .jumpRamp:
            let (rampNode, extent) = createJumpRamp()
            node.addChildNode(rampNode)
            halfExtent = extent
        }

        node.position = position

        return Obstacle(
            node: node,
            type: type,
            halfExtent: halfExtent
        )
    }

    private func createPineTree() -> (SCNNode, SCNVector3) {
        let tree = SCNNode()

        // Trunk
        let trunkGeometry = SCNCylinder(radius: 0.15, height: 1.5)
        let trunkMaterial = SCNMaterial()
        trunkMaterial.diffuse.contents = UIColor(red: 0.4, green: 0.25, blue: 0.15, alpha: 1.0)
        trunkGeometry.materials = [trunkMaterial]
        let trunkNode = SCNNode(geometry: trunkGeometry)
        trunkNode.position = SCNVector3(0, 0.75, 0)
        tree.addChildNode(trunkNode)

        // Foliage layers (3 cones)
        let foliageMaterial = SCNMaterial()
        foliageMaterial.diffuse.contents = UIColor(red: 0.1, green: 0.45, blue: 0.15, alpha: 1.0)

        let sizes: [(radius: CGFloat, height: CGFloat, y: Float)] = [
            (1.2, 2.0, 2.2),
            (0.9, 1.6, 3.2),
            (0.6, 1.3, 4.0)
        ]

        for size in sizes {
            let coneGeometry = SCNCone(topRadius: 0, bottomRadius: size.radius, height: size.height)
            coneGeometry.materials = [foliageMaterial]
            let coneNode = SCNNode(geometry: coneGeometry)
            coneNode.position = SCNVector3(0, size.y, 0)
            tree.addChildNode(coneNode)

            // Snow on top
            let snowGeometry = SCNCone(topRadius: 0, bottomRadius: size.radius * 0.85, height: size.height * 0.15)
            let snowMaterial = SCNMaterial()
            snowMaterial.diffuse.contents = UIColor.white
            snowGeometry.materials = [snowMaterial]
            let snowNode = SCNNode(geometry: snowGeometry)
            snowNode.position = SCNVector3(0, size.y + Float(size.height) * 0.35, 0)
            tree.addChildNode(snowNode)
        }

        let scale = Float.random(in: 0.7...1.3)
        tree.scale = SCNVector3(scale, scale, scale)

        return (tree, SCNVector3(0.8 * scale, 2.5 * scale, 0.8 * scale))
    }

    private func createRock() -> (SCNNode, SCNVector3) {
        let rock = SCNNode()
        let size = Float.random(in: 0.5...1.5)

        let rockGeometry = SCNSphere(radius: CGFloat(size))
        let rockMaterial = SCNMaterial()
        rockMaterial.diffuse.contents = UIColor(red: 0.45, green: 0.43, blue: 0.42, alpha: 1.0)
        rockMaterial.roughness.contents = NSNumber(value: 0.9)
        rockGeometry.materials = [rockMaterial]

        let rockNode = SCNNode(geometry: rockGeometry)
        rockNode.position = SCNVector3(0, size * 0.5, 0)
        rockNode.scale = SCNVector3(1.0, Float.random(in: 0.5...0.8), Float.random(in: 0.7...1.0))

        // Snow dusting on top
        let snowGeometry = SCNSphere(radius: CGFloat(size * 0.95))
        let snowMaterial = SCNMaterial()
        snowMaterial.diffuse.contents = UIColor.white
        snowMaterial.transparency = 0.5
        snowGeometry.materials = [snowMaterial]
        let snowNode = SCNNode(geometry: snowGeometry)
        snowNode.position = SCNVector3(0, size * 0.65, 0)
        snowNode.scale = SCNVector3(0.8, 0.3, 0.8)

        rock.addChildNode(rockNode)
        rock.addChildNode(snowNode)

        return (rock, SCNVector3(size * 0.8, size * 0.5, size * 0.8))
    }

    private func createSnowman() -> (SCNNode, SCNVector3) {
        let snowman = SCNNode()
        let snowMaterial = SCNMaterial()
        snowMaterial.diffuse.contents = UIColor(white: 0.97, alpha: 1.0)

        // Bottom sphere
        let bottomGeometry = SCNSphere(radius: 0.5)
        bottomGeometry.materials = [snowMaterial]
        let bottomNode = SCNNode(geometry: bottomGeometry)
        bottomNode.position = SCNVector3(0, 0.5, 0)
        snowman.addChildNode(bottomNode)

        // Middle sphere
        let middleGeometry = SCNSphere(radius: 0.35)
        middleGeometry.materials = [snowMaterial]
        let middleNode = SCNNode(geometry: middleGeometry)
        middleNode.position = SCNVector3(0, 1.2, 0)
        snowman.addChildNode(middleNode)

        // Head sphere
        let headGeometry = SCNSphere(radius: 0.25)
        headGeometry.materials = [snowMaterial]
        let headNode = SCNNode(geometry: headGeometry)
        headNode.position = SCNVector3(0, 1.7, 0)
        snowman.addChildNode(headNode)

        // Carrot nose
        let noseGeometry = SCNCone(topRadius: 0, bottomRadius: 0.04, height: 0.25)
        let noseMaterial = SCNMaterial()
        noseMaterial.diffuse.contents = UIColor.orange
        noseGeometry.materials = [noseMaterial]
        let noseNode = SCNNode(geometry: noseGeometry)
        noseNode.position = SCNVector3(0, 1.72, 0.25)
        noseNode.eulerAngles.x = Float.pi / 2
        snowman.addChildNode(noseNode)

        return (snowman, SCNVector3(0.5, 1.0, 0.5))
    }

    private func createCabin() -> (SCNNode, SCNVector3) {
        let cabin = SCNNode()

        // Cabin body
        let bodyGeometry = SCNBox(width: 3.0, height: 2.5, length: 2.5, chamferRadius: 0)
        let bodyMaterial = SCNMaterial()
        bodyMaterial.diffuse.contents = UIColor(red: 0.55, green: 0.35, blue: 0.2, alpha: 1.0)
        bodyGeometry.materials = [bodyMaterial]
        let bodyNode = SCNNode(geometry: bodyGeometry)
        bodyNode.position = SCNVector3(0, 1.25, 0)
        cabin.addChildNode(bodyNode)

        // Roof
        let roofGeometry = SCNPyramid(width: 3.5, height: 1.5, length: 3.0)
        let roofMaterial = SCNMaterial()
        roofMaterial.diffuse.contents = UIColor(red: 0.6, green: 0.15, blue: 0.1, alpha: 1.0)
        roofGeometry.materials = [roofMaterial]
        let roofNode = SCNNode(geometry: roofGeometry)
        roofNode.position = SCNVector3(0, 2.5, 0)
        cabin.addChildNode(roofNode)

        // Snow on roof
        let snowGeometry = SCNBox(width: 3.6, height: 0.15, length: 3.1, chamferRadius: 0.05)
        let snowMaterial = SCNMaterial()
        snowMaterial.diffuse.contents = UIColor.white
        snowGeometry.materials = [snowMaterial]
        let snowNode = SCNNode(geometry: snowGeometry)
        snowNode.position = SCNVector3(0, 2.55, 0)
        cabin.addChildNode(snowNode)

        return (cabin, SCNVector3(1.5, 1.5, 1.25))
    }

    private func createJumpRamp() -> (SCNNode, SCNVector3) {
        let ramp = SCNNode()

        let rampGeometry = SCNBox(width: 3.0, height: 0.3, length: 2.0, chamferRadius: 0.05)
        let rampMaterial = SCNMaterial()
        rampMaterial.diffuse.contents = UIColor(red: 0.8, green: 0.85, blue: 0.95, alpha: 1.0)
        rampGeometry.materials = [rampMaterial]

        let rampNode = SCNNode(geometry: rampGeometry)
        rampNode.position = SCNVector3(0, 0.3, 0)
        rampNode.eulerAngles.x = -Float.pi / 12 // Slight upward angle
        ramp.addChildNode(rampNode)

        // Marker flags on the sides
        for side in [-1.5, 1.5] as [Float] {
            let poleGeometry = SCNCylinder(radius: 0.03, height: 1.5)
            let poleMaterial = SCNMaterial()
            poleMaterial.diffuse.contents = UIColor.red
            poleGeometry.materials = [poleMaterial]
            let poleNode = SCNNode(geometry: poleGeometry)
            poleNode.position = SCNVector3(side, 0.75, 0)
            ramp.addChildNode(poleNode)
        }

        return (ramp, SCNVector3(1.5, 0.4, 1.0))
    }

    // MARK: - Cleanup

    func removeAll() {
        for obstacle in activeObstacles {
            obstacle.node.removeFromParentNode()
        }
        activeObstacles.removeAll()
        nextSpawnZ = GameConstants.obstacleStartZ
        difficultyFactor = 1.0
    }
}
