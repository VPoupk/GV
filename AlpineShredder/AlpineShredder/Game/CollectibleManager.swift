import SceneKit

/// Manages spawning and lifecycle of collectible items (coins, power-ups)
class CollectibleManager {

    private let collectibleRoot: SCNNode
    private(set) var activeCollectibles: [Collectible] = []
    private var nextSpawnZ: Float = GameConstants.collectibleStartZ

    init(collectibleRoot: SCNNode) {
        self.collectibleRoot = collectibleRoot
    }

    // MARK: - Update

    func update(playerZ: Float, speed: Float, deltaTime: Float) {
        // Spawn collectibles ahead of player
        while nextSpawnZ > playerZ - GameConstants.collectibleLookAhead {
            spawnCollectibles(atZ: nextSpawnZ)
            nextSpawnZ -= GameConstants.collectibleSpacing
        }

        // Animate active collectibles
        for collectible in activeCollectibles {
            animateCollectible(collectible, deltaTime: deltaTime)
        }

        // Remove collectibles behind player
        activeCollectibles.removeAll { collectible in
            if collectible.node.position.z > playerZ + GameConstants.collectibleCleanupDistance {
                collectible.node.removeFromParentNode()
                return true
            }
            return false
        }
    }

    // MARK: - Spawning

    private func spawnCollectibles(atZ z: Float) {
        // Coin line or cluster
        if Float.random(in: 0...1) < 0.7 {
            spawnCoinLine(atZ: z)
        } else {
            spawnPowerUp(atZ: z)
        }
    }

    private func spawnCoinLine(atZ z: Float) {
        let coinCount = Int.random(in: 3...7)
        let startX = Float.random(in: -GameConstants.maxLaneOffset...GameConstants.maxLaneOffset)
        let spacing: Float = 1.5

        for i in 0..<coinCount {
            let position = SCNVector3(
                startX,
                GameConstants.coinHeight,
                z - Float(i) * spacing
            )
            let collectible = createCollectible(type: .coin, at: position)
            collectibleRoot.addChildNode(collectible.node)
            activeCollectibles.append(collectible)
        }
    }

    private func spawnPowerUp(atZ z: Float) {
        let type: CollectibleType
        let roll = Float.random(in: 0...1)
        if roll < 0.5 {
            type = .speedBoost
        } else if roll < 0.8 {
            type = .scoreMultiplier
        } else {
            type = .shield
        }

        let position = SCNVector3(
            Float.random(in: -GameConstants.maxLaneOffset...GameConstants.maxLaneOffset),
            GameConstants.powerUpHeight,
            z
        )
        let collectible = createCollectible(type: type, at: position)
        collectibleRoot.addChildNode(collectible.node)
        activeCollectibles.append(collectible)
    }

    // MARK: - Creation

    private func createCollectible(type: CollectibleType, at position: SCNVector3) -> Collectible {
        let node = SCNNode()

        switch type {
        case .coin:
            let coinGeometry = SCNCylinder(radius: 0.3, height: 0.06)
            let coinMaterial = SCNMaterial()
            coinMaterial.diffuse.contents = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
            coinMaterial.specular.contents = UIColor.white
            coinMaterial.metalness.contents = NSNumber(value: 0.8)
            coinGeometry.materials = [coinMaterial]

            let coinNode = SCNNode(geometry: coinGeometry)
            coinNode.eulerAngles.x = Float.pi / 2
            node.addChildNode(coinNode)

            // Glow effect
            let glowGeometry = SCNSphere(radius: 0.35)
            let glowMaterial = SCNMaterial()
            glowMaterial.diffuse.contents = UIColor(red: 1.0, green: 0.9, blue: 0.3, alpha: 0.2)
            glowMaterial.emission.contents = UIColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 0.3)
            glowMaterial.isDoubleSided = true
            glowGeometry.materials = [glowMaterial]
            let glowNode = SCNNode(geometry: glowGeometry)
            node.addChildNode(glowNode)

        case .speedBoost:
            let arrowGeometry = SCNPyramid(width: 0.5, height: 0.6, length: 0.5)
            let arrowMaterial = SCNMaterial()
            arrowMaterial.diffuse.contents = UIColor(red: 0.0, green: 0.8, blue: 1.0, alpha: 1.0)
            arrowMaterial.emission.contents = UIColor(red: 0.0, green: 0.5, blue: 0.8, alpha: 0.5)
            arrowGeometry.materials = [arrowMaterial]

            let arrowNode = SCNNode(geometry: arrowGeometry)
            arrowNode.eulerAngles.x = -Float.pi
            node.addChildNode(arrowNode)

        case .shield:
            let shieldGeometry = SCNSphere(radius: 0.35)
            let shieldMaterial = SCNMaterial()
            shieldMaterial.diffuse.contents = UIColor(red: 0.2, green: 0.8, blue: 0.2, alpha: 0.7)
            shieldMaterial.emission.contents = UIColor(red: 0.1, green: 0.6, blue: 0.1, alpha: 0.4)
            shieldMaterial.isDoubleSided = true
            shieldGeometry.materials = [shieldMaterial]

            let shieldNode = SCNNode(geometry: shieldGeometry)
            node.addChildNode(shieldNode)

        case .scoreMultiplier:
            let starGeometry = SCNBox(width: 0.5, height: 0.5, length: 0.1, chamferRadius: 0)
            let starMaterial = SCNMaterial()
            starMaterial.diffuse.contents = UIColor(red: 1.0, green: 0.2, blue: 0.8, alpha: 1.0)
            starMaterial.emission.contents = UIColor(red: 0.8, green: 0.1, blue: 0.5, alpha: 0.5)
            starGeometry.materials = [starMaterial]

            let starNode = SCNNode(geometry: starGeometry)
            starNode.eulerAngles.z = Float.pi / 4
            node.addChildNode(starNode)

            // Second rotated box to make star shape
            let star2Node = SCNNode(geometry: starGeometry)
            node.addChildNode(star2Node)
        }

        node.position = position

        return Collectible(node: node, type: type)
    }

    // MARK: - Animation

    private func animateCollectible(_ collectible: Collectible, deltaTime: Float) {
        // Rotate
        collectible.node.eulerAngles.y += GameConstants.collectibleRotateSpeed * deltaTime

        // Bob up and down
        let bobOffset = sin(Float(CACurrentMediaTime()) * 3.0 + collectible.node.position.z) * 0.15
        switch collectible.type {
        case .coin:
            collectible.node.position.y = GameConstants.coinHeight + bobOffset
        default:
            collectible.node.position.y = GameConstants.powerUpHeight + bobOffset
        }
    }

    // MARK: - Collection

    func collect(_ collectible: Collectible) {
        // Burst particle effect
        let burstParticle = SCNParticleSystem()
        burstParticle.particleSize = 0.1
        burstParticle.birthRate = 100
        burstParticle.particleLifeSpan = 0.5
        burstParticle.emissionDuration = 0.1
        burstParticle.spreadingAngle = 180
        burstParticle.particleVelocity = 3
        burstParticle.blendMode = .additive

        switch collectible.type {
        case .coin:
            burstParticle.particleColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
        case .speedBoost:
            burstParticle.particleColor = UIColor(red: 0.0, green: 0.8, blue: 1.0, alpha: 1.0)
        case .shield:
            burstParticle.particleColor = UIColor(red: 0.2, green: 0.8, blue: 0.2, alpha: 1.0)
        case .scoreMultiplier:
            burstParticle.particleColor = UIColor(red: 1.0, green: 0.2, blue: 0.8, alpha: 1.0)
        }

        let burstNode = SCNNode()
        burstNode.position = collectible.node.position
        burstNode.addParticleSystem(burstParticle)
        collectibleRoot.addChildNode(burstNode)

        // Remove after particle effect
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            burstNode.removeFromParentNode()
        }

        collectible.node.removeFromParentNode()

        if let index = activeCollectibles.firstIndex(where: { $0 === collectible }) {
            activeCollectibles.remove(at: index)
        }
    }

    // MARK: - Cleanup

    func removeAll() {
        for collectible in activeCollectibles {
            collectible.node.removeFromParentNode()
        }
        activeCollectibles.removeAll()
        nextSpawnZ = GameConstants.collectibleStartZ
    }
}
