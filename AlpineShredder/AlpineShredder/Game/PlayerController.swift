import SceneKit
import UIKit

/// Handles player movement, physics, animations, and input processing
class PlayerController {

    private let playerNode: SCNNode
    private weak var scene: GameScene?

    // Player visual components
    private let boardNode = SCNNode()
    private let bodyNode = SCNNode()
    private let trailNode = SCNNode()

    // Movement state
    private var targetLaneX: Float = 0
    private var currentLaneX: Float = 0
    private var horizontalVelocity: Float = 0
    private var isJumping = false
    private var jumpVelocity: Float = 0
    private var currentY: Float = 0
    private var tiltAngle: Float = 0

    // Trick system
    private(set) var isPerformingTrick = false
    private var trickRotation: Float = 0
    private var trickType: TrickType = .none

    // Input
    private var swipeDirection: SwipeDirection = .none
    private var isTouching = false

    init(playerNode: SCNNode, scene: GameScene) {
        self.playerNode = playerNode
        self.scene = scene
        setupPlayerModel()
        setupTrail()
    }

    // MARK: - Setup

    private func setupPlayerModel() {
        // Snowboard
        let boardGeometry = SCNBox(width: 0.3, height: 0.05, length: 1.4, chamferRadius: 0.02)
        let boardMaterial = SCNMaterial()
        boardMaterial.diffuse.contents = UIColor(red: 0.15, green: 0.15, blue: 0.8, alpha: 1.0)
        boardMaterial.specular.contents = UIColor.white
        boardMaterial.roughness.contents = NSNumber(value: 0.2)
        boardGeometry.materials = [boardMaterial]
        boardNode.geometry = boardGeometry
        boardNode.position = SCNVector3(0, 0.05, 0)
        playerNode.addChildNode(boardNode)

        // Rider body (simplified humanoid)
        let torsoGeometry = SCNCapsule(capRadius: 0.15, height: 0.6)
        let torsoMaterial = SCNMaterial()
        torsoMaterial.diffuse.contents = UIColor(red: 0.9, green: 0.2, blue: 0.1, alpha: 1.0)
        torsoGeometry.materials = [torsoMaterial]

        let torsoNode = SCNNode(geometry: torsoGeometry)
        torsoNode.position = SCNVector3(0, 0.55, 0)
        bodyNode.addChildNode(torsoNode)

        // Head
        let headGeometry = SCNSphere(radius: 0.12)
        let headMaterial = SCNMaterial()
        headMaterial.diffuse.contents = UIColor(red: 0.96, green: 0.8, blue: 0.7, alpha: 1.0)
        headGeometry.materials = [headMaterial]

        let headNode = SCNNode(geometry: headGeometry)
        headNode.position = SCNVector3(0, 1.0, 0)
        bodyNode.addChildNode(headNode)

        // Goggles
        let goggleGeometry = SCNBox(width: 0.22, height: 0.08, length: 0.1, chamferRadius: 0.03)
        let goggleMaterial = SCNMaterial()
        goggleMaterial.diffuse.contents = UIColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 1.0)
        goggleMaterial.specular.contents = UIColor.white
        goggleGeometry.materials = [goggleMaterial]

        let goggleNode = SCNNode(geometry: goggleGeometry)
        goggleNode.position = SCNVector3(0, 1.02, 0.08)
        bodyNode.addChildNode(goggleNode)

        // Legs
        for side in [-1.0, 1.0] as [Float] {
            let legGeometry = SCNCapsule(capRadius: 0.07, height: 0.4)
            let legMaterial = SCNMaterial()
            legMaterial.diffuse.contents = UIColor(red: 0.2, green: 0.2, blue: 0.3, alpha: 1.0)
            legGeometry.materials = [legMaterial]

            let legNode = SCNNode(geometry: legGeometry)
            legNode.position = SCNVector3(side * 0.1, 0.25, 0)
            bodyNode.addChildNode(legNode)
        }

        bodyNode.position = SCNVector3(0, 0.05, 0)
        playerNode.addChildNode(bodyNode)
    }

    private func setupTrail() {
        // Snow spray trail behind the player
        let trailParticle = SCNParticleSystem()
        trailParticle.particleSize = 0.08
        trailParticle.particleSizeVariation = 0.04
        trailParticle.particleColor = UIColor(white: 1.0, alpha: 0.8)
        trailParticle.birthRate = 60
        trailParticle.particleLifeSpan = 0.6
        trailParticle.particleVelocity = 1.5
        trailParticle.particleVelocityVariation = 0.5
        trailParticle.spreadingAngle = 25
        trailParticle.emissionDuration = CGFloat.greatestFiniteMagnitude
        trailParticle.blendMode = .additive
        trailParticle.acceleration = SCNVector3(0, -2, 0)

        trailNode.position = SCNVector3(0, 0, 0.7)
        trailNode.addParticleSystem(trailParticle)
        playerNode.addChildNode(trailNode)
    }

    // MARK: - Input Handling

    func handleSwipe(_ direction: SwipeDirection) {
        swipeDirection = direction

        switch direction {
        case .left:
            targetLaneX = max(targetLaneX - GameConstants.laneWidth, -GameConstants.maxLaneOffset)
        case .right:
            targetLaneX = min(targetLaneX + GameConstants.laneWidth, GameConstants.maxLaneOffset)
        case .up:
            if !isJumping {
                jump()
            }
        case .down:
            if isJumping {
                // Slam down for style points
                jumpVelocity = -GameConstants.slamDownSpeed
            } else {
                // Tuck for speed
                tuck()
            }
        case .none:
            break
        }
    }

    func handleTilt(_ tiltX: Float) {
        // Accelerometer-based steering
        let deadzone: Float = 0.05
        if abs(tiltX) > deadzone {
            let steerAmount = tiltX * GameConstants.tiltSensitivity
            targetLaneX = max(-GameConstants.maxLaneOffset,
                            min(GameConstants.maxLaneOffset, currentLaneX + steerAmount))
        }
    }

    // MARK: - Actions

    private func jump() {
        isJumping = true
        jumpVelocity = GameConstants.jumpForce
        currentY = playerNode.position.y

        // Check if we should do a trick
        if abs(horizontalVelocity) > 2.0 {
            startTrick(.grab)
        }
    }

    private func tuck() {
        // Lower body position for speed boost
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.2
        bodyNode.position.y = -0.1
        bodyNode.scale = SCNVector3(1, 0.7, 1)
        SCNTransaction.commit()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.3
            self?.bodyNode.position.y = 0.05
            self?.bodyNode.scale = SCNVector3(1, 1, 1)
            SCNTransaction.commit()
        }
    }

    private func startTrick(_ type: TrickType) {
        guard !isPerformingTrick else { return }
        isPerformingTrick = true
        trickType = type
        trickRotation = 0
    }

    // MARK: - Update

    func update(deltaTime dt: Float, speed: Float) {
        updateHorizontalMovement(deltaTime: dt)
        updateVerticalMovement(deltaTime: dt)
        updateTricks(deltaTime: dt)
        updateVisuals(speed: speed)
    }

    private func updateHorizontalMovement(deltaTime dt: Float) {
        let diff = targetLaneX - currentLaneX
        horizontalVelocity = diff * GameConstants.lateralSpeed
        currentLaneX += horizontalVelocity * dt

        playerNode.position.x = currentLaneX

        // Lean into turns
        let targetTilt = -horizontalVelocity * 0.05
        tiltAngle += (targetTilt - tiltAngle) * min(1.0, 8.0 * dt)
        boardNode.eulerAngles.z = tiltAngle
        bodyNode.eulerAngles.z = tiltAngle * 0.7
    }

    private func updateVerticalMovement(deltaTime dt: Float) {
        if isJumping {
            jumpVelocity -= GameConstants.gravity * dt
            currentY += jumpVelocity * dt

            if currentY <= GameConstants.playerStartPosition.y {
                currentY = GameConstants.playerStartPosition.y
                isJumping = false
                jumpVelocity = 0

                if isPerformingTrick {
                    isPerformingTrick = false
                    trickType = .none
                }
            }

            playerNode.position.y = currentY
        }
    }

    private func updateTricks(deltaTime dt: Float) {
        guard isPerformingTrick else { return }

        switch trickType {
        case .spin:
            trickRotation += GameConstants.trickSpinSpeed * dt
            bodyNode.eulerAngles.y = trickRotation
        case .flip:
            trickRotation += GameConstants.trickSpinSpeed * dt
            bodyNode.eulerAngles.x = trickRotation
        case .grab:
            // Board grab animation — tilt forward
            bodyNode.eulerAngles.x = sin(trickRotation) * 0.4
            trickRotation += 4.0 * dt
        case .none:
            break
        }
    }

    private func updateVisuals(speed: Float) {
        // Board wobble at high speed
        let wobbleAmount = min(speed / GameConstants.maxSpeed, 1.0) * 0.02
        boardNode.eulerAngles.y = sin(Float(CACurrentMediaTime()) * 8) * wobbleAmount

        // Forward movement animation (player moves downhill in -Z)
        playerNode.position.z -= speed * (1.0 / 60.0)
    }

    // MARK: - Reset

    func reset() {
        targetLaneX = 0
        currentLaneX = 0
        horizontalVelocity = 0
        isJumping = false
        jumpVelocity = 0
        currentY = 0
        tiltAngle = 0
        isPerformingTrick = false
        trickRotation = 0
        trickType = .none
        bodyNode.eulerAngles = SCNVector3Zero
        bodyNode.position.y = 0.05
        bodyNode.scale = SCNVector3(1, 1, 1)
        boardNode.eulerAngles = SCNVector3Zero
    }
}

// MARK: - Types

enum SwipeDirection {
    case none, left, right, up, down
}

enum TrickType {
    case none, spin, flip, grab
}
