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

        // Trunk with realistic bark material
        let trunkGeometry = SCNCylinder(radius: 0.18, height: 1.8)
        trunkGeometry.radialSegmentCount = 16
        let trunkMaterial = SCNMaterial()
        trunkMaterial.diffuse.contents = UIColor(red: 0.35, green: 0.22, blue: 0.12, alpha: 1.0)
        trunkMaterial.roughness.contents = NSNumber(value: 0.9)
        trunkMaterial.metalness.contents = NSNumber(value: 0.0)
        trunkMaterial.lightingModel = .physicallyBased
        trunkGeometry.materials = [trunkMaterial]
        let trunkNode = SCNNode(geometry: trunkGeometry)
        trunkNode.position = SCNVector3(0, 0.9, 0)
        tree.addChildNode(trunkNode)

        // Foliage layers (3 cones) with richer green
        let foliageMaterial = SCNMaterial()
        foliageMaterial.diffuse.contents = UIColor(red: 0.08, green: 0.38, blue: 0.12, alpha: 1.0)
        foliageMaterial.roughness.contents = NSNumber(value: 0.8)
        foliageMaterial.metalness.contents = NSNumber(value: 0.0)
        foliageMaterial.lightingModel = .physicallyBased

        let sizes: [(radius: CGFloat, height: CGFloat, y: Float)] = [
            (1.3, 2.2, 2.2),
            (1.0, 1.8, 3.3),
            (0.65, 1.4, 4.2)
        ]

        for size in sizes {
            let coneGeometry = SCNCone(topRadius: 0, bottomRadius: size.radius, height: size.height)
            coneGeometry.radialSegmentCount = 24
            coneGeometry.heightSegmentCount = 4
            coneGeometry.materials = [foliageMaterial]
            let coneNode = SCNNode(geometry: coneGeometry)
            coneNode.position = SCNVector3(0, size.y, 0)
            tree.addChildNode(coneNode)

            // Snow accumulation on branches
            let snowGeometry = SCNCone(topRadius: 0, bottomRadius: size.radius * 0.88, height: size.height * 0.18)
            snowGeometry.radialSegmentCount = 24
            let snowMaterial = SCNMaterial()
            snowMaterial.diffuse.contents = UIColor(white: 0.97, alpha: 1.0)
            snowMaterial.roughness.contents = NSNumber(value: 0.3)
            snowMaterial.lightingModel = .physicallyBased
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
        rockGeometry.segmentCount = 32
        let rockMaterial = SCNMaterial()
        rockMaterial.diffuse.contents = UIColor(red: 0.42, green: 0.40, blue: 0.38, alpha: 1.0)
        rockMaterial.roughness.contents = NSNumber(value: 0.85)
        rockMaterial.metalness.contents = NSNumber(value: 0.05)
        rockMaterial.lightingModel = .physicallyBased
        rockGeometry.materials = [rockMaterial]

        let rockNode = SCNNode(geometry: rockGeometry)
        rockNode.position = SCNVector3(0, size * 0.5, 0)
        rockNode.scale = SCNVector3(1.0, Float.random(in: 0.5...0.8), Float.random(in: 0.7...1.0))

        // Snow dusting on top
        let snowGeometry = SCNSphere(radius: CGFloat(size * 0.95))
        snowGeometry.segmentCount = 24
        let snowMaterial = SCNMaterial()
        snowMaterial.diffuse.contents = UIColor(white: 0.97, alpha: 1.0)
        snowMaterial.transparency = 0.5
        snowMaterial.roughness.contents = NSNumber(value: 0.3)
        snowMaterial.lightingModel = .physicallyBased
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
        snowMaterial.roughness.contents = NSNumber(value: 0.4)
        snowMaterial.lightingModel = .physicallyBased

        // Bottom sphere
        let bottomGeometry = SCNSphere(radius: 0.5)
        bottomGeometry.segmentCount = 32
        bottomGeometry.materials = [snowMaterial]
        let bottomNode = SCNNode(geometry: bottomGeometry)
        bottomNode.position = SCNVector3(0, 0.5, 0)
        snowman.addChildNode(bottomNode)

        // Middle sphere
        let middleGeometry = SCNSphere(radius: 0.35)
        middleGeometry.segmentCount = 32
        middleGeometry.materials = [snowMaterial]
        let middleNode = SCNNode(geometry: middleGeometry)
        middleNode.position = SCNVector3(0, 1.2, 0)
        snowman.addChildNode(middleNode)

        // Head sphere
        let headGeometry = SCNSphere(radius: 0.25)
        headGeometry.segmentCount = 32
        headGeometry.materials = [snowMaterial]
        let headNode = SCNNode(geometry: headGeometry)
        headNode.position = SCNVector3(0, 1.7, 0)
        snowman.addChildNode(headNode)

        // Carrot nose
        let noseGeometry = SCNCone(topRadius: 0, bottomRadius: 0.04, height: 0.25)
        noseGeometry.radialSegmentCount = 12
        let noseMaterial = SCNMaterial()
        noseMaterial.diffuse.contents = UIColor.orange
        noseMaterial.roughness.contents = NSNumber(value: 0.6)
        noseMaterial.lightingModel = .physicallyBased
        noseGeometry.materials = [noseMaterial]
        let noseNode = SCNNode(geometry: noseGeometry)
        noseNode.position = SCNVector3(0, 1.72, 0.25)
        noseNode.eulerAngles.x = Float.pi / 2
        snowman.addChildNode(noseNode)

        // Coal eyes
        for side in [-0.08, 0.08] as [Float] {
            let eyeGeometry = SCNSphere(radius: 0.03)
            eyeGeometry.segmentCount = 12
            let eyeMaterial = SCNMaterial()
            eyeMaterial.diffuse.contents = UIColor(white: 0.1, alpha: 1.0)
            eyeMaterial.lightingModel = .physicallyBased
            eyeGeometry.materials = [eyeMaterial]
            let eyeNode = SCNNode(geometry: eyeGeometry)
            eyeNode.position = SCNVector3(side, 1.78, 0.2)
            snowman.addChildNode(eyeNode)
        }

        // Stick arms
        for side in [-1.0, 1.0] as [Float] {
            let armGeometry = SCNCylinder(radius: 0.02, height: 0.6)
            armGeometry.radialSegmentCount = 8
            let armMaterial = SCNMaterial()
            armMaterial.diffuse.contents = UIColor(red: 0.35, green: 0.22, blue: 0.12, alpha: 1.0)
            armMaterial.roughness.contents = NSNumber(value: 0.9)
            armMaterial.lightingModel = .physicallyBased
            armGeometry.materials = [armMaterial]
            let armNode = SCNNode(geometry: armGeometry)
            armNode.position = SCNVector3(side * 0.5, 1.15, 0)
            armNode.eulerAngles.z = side * 0.6
            snowman.addChildNode(armNode)
        }

        // Top hat
        let hatBrimGeometry = SCNCylinder(radius: 0.22, height: 0.03)
        hatBrimGeometry.radialSegmentCount = 20
        let hatMaterial = SCNMaterial()
        hatMaterial.diffuse.contents = UIColor(white: 0.1, alpha: 1.0)
        hatMaterial.lightingModel = .physicallyBased
        hatBrimGeometry.materials = [hatMaterial]
        let hatBrimNode = SCNNode(geometry: hatBrimGeometry)
        hatBrimNode.position = SCNVector3(0, 1.93, 0)
        snowman.addChildNode(hatBrimNode)

        let hatTopGeometry = SCNCylinder(radius: 0.14, height: 0.2)
        hatTopGeometry.radialSegmentCount = 20
        hatTopGeometry.materials = [hatMaterial]
        let hatTopNode = SCNNode(geometry: hatTopGeometry)
        hatTopNode.position = SCNVector3(0, 2.05, 0)
        snowman.addChildNode(hatTopNode)

        return (snowman, SCNVector3(0.5, 1.0, 0.5))
    }

    private func createCabin() -> (SCNNode, SCNVector3) {
        let cabin = SCNNode()

        // Cabin body with wood-like material
        let bodyGeometry = SCNBox(width: 3.0, height: 2.5, length: 2.5, chamferRadius: 0)
        let bodyMaterial = SCNMaterial()
        bodyMaterial.diffuse.contents = UIColor(red: 0.5, green: 0.32, blue: 0.18, alpha: 1.0)
        bodyMaterial.roughness.contents = NSNumber(value: 0.85)
        bodyMaterial.metalness.contents = NSNumber(value: 0.0)
        bodyMaterial.lightingModel = .physicallyBased
        bodyGeometry.materials = [bodyMaterial]
        let bodyNode = SCNNode(geometry: bodyGeometry)
        bodyNode.position = SCNVector3(0, 1.25, 0)
        cabin.addChildNode(bodyNode)

        // Roof
        let roofGeometry = SCNPyramid(width: 3.5, height: 1.5, length: 3.0)
        let roofMaterial = SCNMaterial()
        roofMaterial.diffuse.contents = UIColor(red: 0.55, green: 0.12, blue: 0.08, alpha: 1.0)
        roofMaterial.roughness.contents = NSNumber(value: 0.7)
        roofMaterial.lightingModel = .physicallyBased
        roofGeometry.materials = [roofMaterial]
        let roofNode = SCNNode(geometry: roofGeometry)
        roofNode.position = SCNVector3(0, 2.5, 0)
        cabin.addChildNode(roofNode)

        // Snow on roof
        let snowGeometry = SCNBox(width: 3.6, height: 0.2, length: 3.1, chamferRadius: 0.08)
        let snowMaterial = SCNMaterial()
        snowMaterial.diffuse.contents = UIColor(white: 0.97, alpha: 1.0)
        snowMaterial.roughness.contents = NSNumber(value: 0.3)
        snowMaterial.lightingModel = .physicallyBased
        snowGeometry.materials = [snowMaterial]
        let snowNode = SCNNode(geometry: snowGeometry)
        snowNode.position = SCNVector3(0, 2.6, 0)
        cabin.addChildNode(snowNode)

        // Window
        let windowGeometry = SCNPlane(width: 0.6, height: 0.5)
        let windowMaterial = SCNMaterial()
        windowMaterial.diffuse.contents = UIColor(red: 0.9, green: 0.85, blue: 0.5, alpha: 1.0)
        windowMaterial.emission.contents = UIColor(red: 0.8, green: 0.7, blue: 0.3, alpha: 0.4)
        windowMaterial.lightingModel = .physicallyBased
        windowGeometry.materials = [windowMaterial]
        let windowNode = SCNNode(geometry: windowGeometry)
        windowNode.position = SCNVector3(0, 1.5, 1.26)
        cabin.addChildNode(windowNode)

        // Chimney
        let chimneyGeometry = SCNBox(width: 0.4, height: 0.8, length: 0.4, chamferRadius: 0.02)
        let chimneyMaterial = SCNMaterial()
        chimneyMaterial.diffuse.contents = UIColor(red: 0.55, green: 0.3, blue: 0.2, alpha: 1.0)
        chimneyMaterial.roughness.contents = NSNumber(value: 0.8)
        chimneyMaterial.lightingModel = .physicallyBased
        chimneyGeometry.materials = [chimneyMaterial]
        let chimneyNode = SCNNode(geometry: chimneyGeometry)
        chimneyNode.position = SCNVector3(0.8, 3.2, 0)
        cabin.addChildNode(chimneyNode)

        return (cabin, SCNVector3(1.5, 1.5, 1.25))
    }

    private func createJumpRamp() -> (SCNNode, SCNVector3) {
        let ramp = SCNNode()

        let rampGeometry = SCNBox(width: 3.0, height: 0.3, length: 2.0, chamferRadius: 0.08)
        let rampMaterial = SCNMaterial()
        rampMaterial.diffuse.contents = UIColor(red: 0.85, green: 0.9, blue: 0.97, alpha: 1.0)
        rampMaterial.roughness.contents = NSNumber(value: 0.2)
        rampMaterial.metalness.contents = NSNumber(value: 0.02)
        rampMaterial.lightingModel = .physicallyBased
        rampGeometry.materials = [rampMaterial]

        let rampNode = SCNNode(geometry: rampGeometry)
        rampNode.position = SCNVector3(0, 0.3, 0)
        rampNode.eulerAngles.x = -Float.pi / 12
        ramp.addChildNode(rampNode)

        // Marker flags on the sides
        for side in [-1.5, 1.5] as [Float] {
            let poleGeometry = SCNCylinder(radius: 0.035, height: 1.5)
            poleGeometry.radialSegmentCount = 12
            let poleMaterial = SCNMaterial()
            poleMaterial.diffuse.contents = UIColor.red
            poleMaterial.roughness.contents = NSNumber(value: 0.5)
            poleMaterial.lightingModel = .physicallyBased
            poleGeometry.materials = [poleMaterial]
            let poleNode = SCNNode(geometry: poleGeometry)
            poleNode.position = SCNVector3(side, 0.75, 0)
            ramp.addChildNode(poleNode)

            // Small flag at top
            let flagGeometry = SCNPlane(width: 0.3, height: 0.2)
            let flagMaterial = SCNMaterial()
            flagMaterial.diffuse.contents = UIColor.red
            flagMaterial.isDoubleSided = true
            flagMaterial.lightingModel = .physicallyBased
            flagGeometry.materials = [flagMaterial]
            let flagNode = SCNNode(geometry: flagGeometry)
            flagNode.position = SCNVector3(side + (side > 0 ? 0.15 : -0.15), 1.4, 0)
            ramp.addChildNode(flagNode)
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
