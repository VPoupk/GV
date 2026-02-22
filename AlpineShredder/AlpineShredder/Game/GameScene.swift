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
    private(set) var weatherSystem: WeatherSystem!

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
        setupWeather()
    }

    private func setupEnvironment() {
        let resort = ResortManager.shared.currentResort

        background.contents = resort.skyColor

        fogStartDistance = CGFloat(resort.fogStart)
        fogEndDistance = CGFloat(resort.fogEnd)
        fogColor = resort.fogColor
        fogDensityExponent = 1.5

        rootNode.addChildNode(terrainRoot)
        rootNode.addChildNode(obstacleRoot)
        rootNode.addChildNode(collectibleRoot)
        rootNode.addChildNode(lightRoot)
        rootNode.addChildNode(particleRoot)
    }

    private func setupCamera() {
        let camera = SCNCamera()
        camera.fieldOfView = 60
        camera.zNear = 0.1
        camera.zFar = 250
        camera.wantsHDR = true
        camera.bloomIntensity = 0.4
        camera.bloomThreshold = 0.6
        camera.wantsExposureAdaptation = true
        camera.exposureOffset = -0.3
        camera.minimumExposure = -2
        camera.maximumExposure = 3

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
        // Primary directional sun light
        let sunNode = SCNNode()
        let sunLight = SCNLight()
        sunLight.type = .directional
        sunLight.color = UIColor(red: 1.0, green: 0.97, blue: 0.92, alpha: 1.0)
        sunLight.intensity = 1400
        sunLight.castsShadow = true
        sunLight.shadowMode = .deferred
        sunLight.shadowSampleCount = 16
        sunLight.shadowRadius = 4.0
        sunLight.shadowMapSize = CGSize(width: 4096, height: 4096)
        sunNode.light = sunLight
        sunNode.eulerAngles = SCNVector3(-Float.pi / 3, Float.pi / 6, 0)
        lightRoot.addChildNode(sunNode)

        // Secondary fill light (simulates sky bounce)
        let fillNode = SCNNode()
        let fillLight = SCNLight()
        fillLight.type = .directional
        fillLight.color = UIColor(red: 0.7, green: 0.8, blue: 1.0, alpha: 1.0)
        fillLight.intensity = 300
        fillLight.castsShadow = false
        fillNode.light = fillLight
        fillNode.eulerAngles = SCNVector3(-Float.pi / 6, -Float.pi / 4, 0)
        lightRoot.addChildNode(fillNode)

        // Ambient fill light
        let ambientNode = SCNNode()
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.color = UIColor(red: 0.65, green: 0.72, blue: 0.88, alpha: 1.0)
        ambientLight.intensity = 500
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
        let resort = ResortManager.shared.currentResort

        // Snow particle system falling from sky — intensity varies by resort
        let snowParticle = SCNParticleSystem()
        snowParticle.particleSize = 0.04
        snowParticle.particleSizeVariation = 0.03
        snowParticle.particleColor = UIColor(white: 1.0, alpha: 0.9)
        snowParticle.birthRate = CGFloat(250 * resort.snowIntensity)
        snowParticle.particleLifeSpan = 10.0
        snowParticle.particleLifeSpanVariation = 3.0
        snowParticle.spreadingAngle = 40
        snowParticle.emissionDuration = CGFloat.greatestFiniteMagnitude
        snowParticle.emitterShape = SCNBox(width: 80, height: 0.1, length: 80, chamferRadius: 0)
        snowParticle.particleVelocity = 1.5
        snowParticle.particleVelocityVariation = 1.0
        snowParticle.acceleration = SCNVector3(0, -0.3, 0)
        snowParticle.blendMode = .alpha
        snowParticle.particleAngularVelocity = 1.0
        snowParticle.particleAngularVelocityVariation = 2.0

        let snowEmitter = SCNNode()
        snowEmitter.position = SCNVector3(0, 30, 0)
        snowEmitter.addParticleSystem(snowParticle)
        particleRoot.addChildNode(snowEmitter)
    }

    private func setupWeather() {
        let resort = ResortManager.shared.currentResort
        weatherSystem = WeatherSystem(scene: self)
        weatherSystem.applyResortWeather(snowIntensity: resort.snowIntensity)
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
        weatherSystem.update(deltaTime: dt)

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
