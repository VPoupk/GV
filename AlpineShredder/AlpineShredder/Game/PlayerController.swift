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
        let appearance = CharacterAppearance.shared
        let equipment = EquipmentManager.shared.currentEquipment(for: GameManager.shared.selectedCharacter)
        let isSkier = GameManager.shared.selectedCharacter == .skier

        if isSkier {
            // Two skis side by side
            for side in [-0.08, 0.08] as [Float] {
                let skiGeometry = SCNBox(width: 0.1, height: 0.04, length: 1.5, chamferRadius: 0.02)
                let skiMaterial = SCNMaterial()
                skiMaterial.diffuse.contents = equipment.color
                skiMaterial.specular.contents = UIColor.white
                skiMaterial.roughness.contents = NSNumber(value: 0.2)
                skiGeometry.materials = [skiMaterial]
                let skiNode = SCNNode(geometry: skiGeometry)
                skiNode.position = SCNVector3(side, 0.04, 0)
                boardNode.addChildNode(skiNode)

                // Accent tip
                let tipGeometry = SCNBox(width: 0.09, height: 0.045, length: 0.15, chamferRadius: 0.01)
                let tipMaterial = SCNMaterial()
                tipMaterial.diffuse.contents = equipment.accentColor
                tipGeometry.materials = [tipMaterial]
                let tipNode = SCNNode(geometry: tipGeometry)
                tipNode.position = SCNVector3(side, 0.04, -0.6)
                boardNode.addChildNode(tipNode)
            }
        } else {
            // Snowboard — colored with equipment selection
            let boardGeometry = SCNBox(width: 0.3, height: 0.05, length: 1.4, chamferRadius: 0.02)
            let boardMaterial = SCNMaterial()
            boardMaterial.diffuse.contents = equipment.color
            boardMaterial.specular.contents = UIColor.white
            boardMaterial.roughness.contents = NSNumber(value: 0.2)
            boardGeometry.materials = [boardMaterial]
            let mainBoard = SCNNode(geometry: boardGeometry)
            boardNode.addChildNode(mainBoard)

            // Accent stripe on board
            let stripeGeometry = SCNBox(width: 0.27, height: 0.055, length: 0.12, chamferRadius: 0.01)
            let stripeMaterial = SCNMaterial()
            stripeMaterial.diffuse.contents = equipment.accentColor
            stripeGeometry.materials = [stripeMaterial]
            let stripeNode = SCNNode(geometry: stripeGeometry)
            stripeNode.position = SCNVector3(0, 0, 0.3)
            boardNode.addChildNode(stripeNode)
        }

        boardNode.position = SCNVector3(0, 0.05, 0)
        playerNode.addChildNode(boardNode)

        // Rider body — uses CharacterAppearance colors
        let bodyScale = appearance.gender.bodyScale

        // Helmet
        let helmetGeometry = SCNSphere(radius: 0.15)
        let helmetMaterial = SCNMaterial()
        helmetMaterial.diffuse.contents = appearance.helmetColor
        helmetMaterial.specular.contents = UIColor.white
        helmetGeometry.materials = [helmetMaterial]
        let helmetNode = SCNNode(geometry: helmetGeometry)
        helmetNode.position = SCNVector3(0, 1.06, 0)
        helmetNode.scale = SCNVector3(1, 0.85, 1)
        bodyNode.addChildNode(helmetNode)

        // Head
        let headGeometry = SCNSphere(radius: CGFloat(0.12 * appearance.gender.headScale))
        let headMaterial = SCNMaterial()
        headMaterial.diffuse.contents = UIColor(red: 0.96, green: 0.8, blue: 0.7, alpha: 1.0)
        headGeometry.materials = [headMaterial]
        let headNode = SCNNode(geometry: headGeometry)
        headNode.position = SCNVector3(0, 1.0, 0.04)
        bodyNode.addChildNode(headNode)

        // Goggles — custom color
        let goggleGeometry = SCNBox(width: 0.22, height: 0.08, length: 0.1, chamferRadius: 0.03)
        let goggleMaterial = SCNMaterial()
        goggleMaterial.diffuse.contents = appearance.goggleColor
        goggleMaterial.specular.contents = UIColor.white
        goggleGeometry.materials = [goggleMaterial]
        let goggleNode = SCNNode(geometry: goggleGeometry)
        goggleNode.position = SCNVector3(0, 1.02, 0.08)
        bodyNode.addChildNode(goggleNode)

        // Torso (jacket color)
        let torsoGeometry = SCNCapsule(capRadius: CGFloat(0.15 * bodyScale.width), height: CGFloat(0.6 * bodyScale.height))
        let torsoMaterial = SCNMaterial()
        torsoMaterial.diffuse.contents = appearance.jacketColor
        torsoGeometry.materials = [torsoMaterial]
        let torsoNode = SCNNode(geometry: torsoGeometry)
        torsoNode.position = SCNVector3(0, 0.55, 0)
        bodyNode.addChildNode(torsoNode)

        // Arms and gloves
        for side in [-1.0, 1.0] as [Float] {
            let armGeometry = SCNCapsule(capRadius: 0.055, height: 0.35)
            let armMaterial = SCNMaterial()
            armMaterial.diffuse.contents = appearance.jacketColor
            armGeometry.materials = [armMaterial]
            let armNode = SCNNode(geometry: armGeometry)
            armNode.position = SCNVector3(side * 0.22, 0.5, 0)
            armNode.eulerAngles.z = side * 0.25
            bodyNode.addChildNode(armNode)

            // Glove
            let gloveGeometry = SCNSphere(radius: 0.055)
            let gloveMaterial = SCNMaterial()
            gloveMaterial.diffuse.contents = appearance.gloveColor
            gloveGeometry.materials = [gloveMaterial]
            let gloveNode = SCNNode(geometry: gloveGeometry)
            gloveNode.position = SCNVector3(side * 0.26, 0.3, 0)
            bodyNode.addChildNode(gloveNode)
        }

        // Legs (pants color)
        for side in [-1.0, 1.0] as [Float] {
            let legGeometry = SCNCapsule(capRadius: 0.07, height: 0.4)
            let legMaterial = SCNMaterial()
            legMaterial.diffuse.contents = appearance.pantsColor
            legGeometry.materials = [legMaterial]
            let legNode = SCNNode(geometry: legGeometry)
            legNode.position = SCNVector3(side * 0.1, 0.25, 0)
            bodyNode.addChildNode(legNode)

            // Boots
            let bootGeometry = SCNBox(width: 0.1, height: 0.08, length: 0.16, chamferRadius: 0.02)
            let bootMaterial = SCNMaterial()
            bootMaterial.diffuse.contents = appearance.bootColor
            bootGeometry.materials = [bootMaterial]
            let bootNode = SCNNode(geometry: bootGeometry)
            bootNode.position = SCNVector3(side * 0.1, 0.04, 0.02)
            bodyNode.addChildNode(bootNode)
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

        // Apply equipment turn bonus to lateral movement
        let turnBonus = EquipmentManager.shared.currentEquipment(for: GameManager.shared.selectedCharacter).turnBonus

        switch direction {
        case .left:
            let moveAmount = GameConstants.laneWidth * turnBonus
            targetLaneX = max(targetLaneX - moveAmount, -GameConstants.maxLaneOffset)
        case .right:
            let moveAmount = GameConstants.laneWidth * turnBonus
            targetLaneX = min(targetLaneX + moveAmount, GameConstants.maxLaneOffset)
        case .up:
            if !isJumping {
                jump()
            }
        case .down:
            if isJumping {
                jumpVelocity = -GameConstants.slamDownSpeed
            } else {
                tuck()
            }
        case .none:
            break
        }
    }

    func handleTilt(_ tiltX: Float) {
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

        if abs(horizontalVelocity) > 2.0 {
            startTrick(.grab)
        }
    }

    private func tuck() {
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
            bodyNode.eulerAngles.x = sin(trickRotation) * 0.4
            trickRotation += 4.0 * dt
        case .none:
            break
        }
    }

    private func updateVisuals(speed: Float) {
        let wobbleAmount = min(speed / GameConstants.maxSpeed, 1.0) * 0.02
        boardNode.eulerAngles.y = sin(Float(CACurrentMediaTime()) * 8) * wobbleAmount
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
