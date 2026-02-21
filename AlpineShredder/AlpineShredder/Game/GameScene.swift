import SceneKit
import UIKit

/// Main SceneKit scene that manages the 3D snowboarding game world
class GameScene: SCNScene {

    // MARK: - Nodes

    let cameraNode = SCNNode()
    let playerNode = SCNNode()
    let terrainRoot = SCNNode()
    let obstacleRoot = SCNNode()
    let collectibleRoot = SCNNode()
    let lightRoot = SCNNode()
    let particleRoot = SCNNode()

    // MARK: - Managers

    private(set) var terrainGenerator: TerrainGenerator!
    private(set) var playerController: PlayerController!
    private(set) var obstacleManager: ObstacleManager!
    private(set) var collectibleManager: CollectibleManager!

    // MARK: - State

    private var lastUpdateTime: TimeInterval = 0
    var currentSpeed: Float = GameConstants.initialSpeed
    var distanceTraveled: Float = 0
    var isGameActive = false

    // MARK: - Setup

    func setupScene() {
        setupEnvironment()
        setupCamera()
        setupLighting()
        setupPlayer()
        setupTerrain()
        setupManagers()
        setupParticles()
    }

    private func setupEnvironment() {
        background.contents = UIColor(red: 0.53, green: 0.81, blue: 0.98, alpha: 1.0)

        fogStartDistance = 80
        fogEndDistance = 150
        fogColor = UIColor(white: 0.95, alpha: 1.0)
        fogDensityExponent = 1.5

        rootNode.addChildNode(terrainRoot)
        rootNode.addChildNode(obstacleRoot)
        rootNode.addChildNode(collectibleRoot)
        rootNode.addChildNode(lightRoot)
        rootNode.addChildNode(particleRoot)
    }

    private func setupCamera() {
        let camera = SCNCamera()
        camera.fieldOfView = 65
        camera.zNear = 0.1
        camera.zFar = 200
        camera.wantsHDR = true
        camera.bloomIntensity = 0.3
        camera.bloomThreshold = 0.8

        cameraNode.camera = camera
        cameraNode.position = GameConstants.cameraOffset
        cameraNode.eulerAngles = SCNVector3(
            -Float.pi / 8,
            0,
            0
        )
        rootNode.addChildNode(cameraNode)
    }

    private func setupLighting() {
        // Directional sun light
        let sunNode = SCNNode()
        let sunLight = SCNLight()
        sunLight.type = .directional
        sunLight.color = UIColor(white: 1.0, alpha: 1.0)
        sunLight.intensity = 1200
        sunLight.castsShadow = true
        sunLight.shadowMode = .deferred
        sunLight.shadowSampleCount = 8
        sunLight.shadowRadius = 3.0
        sunLight.shadowMapSize = CGSize(width: 2048, height: 2048)
        sunNode.light = sunLight
        sunNode.eulerAngles = SCNVector3(-Float.pi / 3, Float.pi / 6, 0)
        lightRoot.addChildNode(sunNode)

        // Ambient fill light
        let ambientNode = SCNNode()
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.color = UIColor(red: 0.7, green: 0.75, blue: 0.9, alpha: 1.0)
        ambientLight.intensity = 400
        ambientNode.light = ambientLight
        lightRoot.addChildNode(ambientNode)
    }

    private func setupPlayer() {
        playerNode.position = GameConstants.playerStartPosition
        rootNode.addChildNode(playerNode)
    }

    private func setupTerrain() {
        terrainGenerator = TerrainGenerator(terrainRoot: terrainRoot)
        terrainGenerator.generateInitialTerrain()
    }

    private func setupManagers() {
        playerController = PlayerController(playerNode: playerNode, scene: self)
        obstacleManager = ObstacleManager(obstacleRoot: obstacleRoot)
        collectibleManager = CollectibleManager(collectibleRoot: collectibleRoot)
    }

    private func setupParticles() {
        // Snow particle system falling from sky
        let snowParticle = SCNParticleSystem()
        snowParticle.particleSize = 0.05
        snowParticle.particleColor = .white
        snowParticle.birthRate = 200
        snowParticle.particleLifeSpan = 8.0
        snowParticle.spreadingAngle = 30
        snowParticle.emissionDuration = CGFloat.greatestFiniteMagnitude
        snowParticle.emitterShape = SCNBox(width: 60, height: 0.1, length: 60, chamferRadius: 0)
        snowParticle.particleVelocity = 2
        snowParticle.particleVelocityVariation = 1
        snowParticle.acceleration = SCNVector3(0, -0.5, 0)
        snowParticle.blendMode = .additive

        let snowEmitter = SCNNode()
        snowEmitter.position = SCNVector3(0, 25, 0)
        snowEmitter.addParticleSystem(snowParticle)
        particleRoot.addChildNode(snowEmitter)
    }

    // MARK: - Game Loop

    func startGame() {
        isGameActive = true
        currentSpeed = GameConstants.initialSpeed
        distanceTraveled = 0
        lastUpdateTime = 0
    }

    func stopGame() {
        isGameActive = false
    }

    func update(atTime time: TimeInterval) {
        guard isGameActive else { return }

        let deltaTime: TimeInterval
        if lastUpdateTime == 0 {
            deltaTime = 1.0 / 60.0
        } else {
            deltaTime = min(time - lastUpdateTime, 1.0 / 30.0)
        }
        lastUpdateTime = time

        let dt = Float(deltaTime)

        // Accelerate over time
        currentSpeed = min(currentSpeed + GameConstants.acceleration * dt, GameConstants.maxSpeed)
        distanceTraveled += currentSpeed * dt

        // Update subsystems
        playerController.update(deltaTime: dt, speed: currentSpeed)
        terrainGenerator.update(playerZ: playerNode.position.z)
        obstacleManager.update(playerZ: playerNode.position.z, speed: currentSpeed, deltaTime: dt)
        collectibleManager.update(playerZ: playerNode.position.z, speed: currentSpeed, deltaTime: dt)

        // Camera follows player smoothly
        updateCamera(deltaTime: dt)
    }

    private func updateCamera(deltaTime: Float) {
        let targetPosition = SCNVector3(
            playerNode.position.x * 0.5,
            playerNode.position.y + GameConstants.cameraOffset.y,
            playerNode.position.z + GameConstants.cameraOffset.z
        )
        let lerpFactor = min(1.0, GameConstants.cameraSmoothing * deltaTime)
        cameraNode.position = SCNVector3(
            cameraNode.position.x + (targetPosition.x - cameraNode.position.x) * lerpFactor,
            cameraNode.position.y + (targetPosition.y - cameraNode.position.y) * lerpFactor,
            cameraNode.position.z + (targetPosition.z - cameraNode.position.z) * lerpFactor
        )
    }

    // MARK: - Collision Checking

    func checkCollisions() -> CollisionResult {
        let playerBounds = BoundingBox(
            center: playerNode.position,
            halfExtent: GameConstants.playerHalfExtent
        )

        // Check obstacle collisions
        for obstacle in obstacleManager.activeObstacles {
            let obstacleBounds = BoundingBox(
                center: obstacle.node.position,
                halfExtent: obstacle.halfExtent
            )
            if playerBounds.intersects(obstacleBounds) {
                return .obstacle(obstacle)
            }
        }

        // Check collectible collisions
        for collectible in collectibleManager.activeCollectibles {
            let collectibleBounds = BoundingBox(
                center: collectible.node.position,
                halfExtent: GameConstants.collectibleHalfExtent
            )
            if playerBounds.intersects(collectibleBounds) {
                collectibleManager.collect(collectible)
                return .collectible(collectible)
            }
        }

        return .none
    }

    // MARK: - Cleanup

    func resetScene() {
        obstacleManager.removeAll()
        collectibleManager.removeAll()
        terrainGenerator.reset()
        playerNode.position = GameConstants.playerStartPosition
        playerController.reset()
        cameraNode.position = GameConstants.cameraOffset
        currentSpeed = GameConstants.initialSpeed
        distanceTraveled = 0
        lastUpdateTime = 0
    }
}

// MARK: - Collision Types

enum CollisionResult {
    case none
    case obstacle(Obstacle)
    case collectible(Collectible)
}

struct BoundingBox {
    let center: SCNVector3
    let halfExtent: SCNVector3

    func intersects(_ other: BoundingBox) -> Bool {
        return abs(center.x - other.center.x) < (halfExtent.x + other.halfExtent.x) &&
               abs(center.y - other.center.y) < (halfExtent.y + other.halfExtent.y) &&
               abs(center.z - other.center.z) < (halfExtent.z + other.halfExtent.z)
    }
}
