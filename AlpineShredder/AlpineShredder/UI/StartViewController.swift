import UIKit
import SceneKit

/// Entry screen with animated snowy mountain background and a big PLAY button
class StartViewController: UIViewController {

    private let backgroundView = SCNView()
    private let titleLabel = UILabel()
    private let playButton = UIButton(type: .system)
    private let versionLabel = UILabel()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateEntrance()
    }

    override var prefersStatusBarHidden: Bool { true }

    // MARK: - Snowy Background

    private func setupBackground() {
        backgroundView.frame = view.bounds
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundView.isUserInteractionEnabled = false
        backgroundView.allowsCameraControl = false

        let scene = SCNScene()

        // Dark alpine sky gradient
        scene.background.contents = UIColor(red: 0.08, green: 0.12, blue: 0.25, alpha: 1.0)

        // Multiple mountain layers for depth
        addMountainRange(to: scene, yOffset: -4, zOffset: -20, count: 5,
                         color: UIColor(red: 0.2, green: 0.25, blue: 0.4, alpha: 1.0), scale: 1.5)
        addMountainRange(to: scene, yOffset: -3, zOffset: -14, count: 4,
                         color: UIColor(red: 0.35, green: 0.4, blue: 0.55, alpha: 1.0), scale: 1.2)
        addMountainRange(to: scene, yOffset: -2.5, zOffset: -9, count: 3,
                         color: UIColor(red: 0.7, green: 0.75, blue: 0.85, alpha: 1.0), scale: 1.0)

        // Snow-covered ground plane
        let groundGeometry = SCNPlane(width: 60, height: 40)
        let groundMaterial = SCNMaterial()
        groundMaterial.diffuse.contents = UIColor(red: 0.85, green: 0.88, blue: 0.95, alpha: 1.0)
        groundGeometry.materials = [groundMaterial]
        let groundNode = SCNNode(geometry: groundGeometry)
        groundNode.eulerAngles.x = -Float.pi / 2
        groundNode.position = SCNVector3(0, -3.5, -5)
        scene.rootNode.addChildNode(groundNode)

        // Heavy snow particle effect
        let snowParticle = SCNParticleSystem()
        snowParticle.particleSize = 0.04
        snowParticle.particleSizeVariation = 0.02
        snowParticle.particleColor = .white
        snowParticle.birthRate = 400
        snowParticle.particleLifeSpan = 10
        snowParticle.spreadingAngle = 40
        snowParticle.emitterShape = SCNBox(width: 25, height: 0.1, length: 25, chamferRadius: 0)
        snowParticle.particleVelocity = 1.5
        snowParticle.particleVelocityVariation = 0.8
        snowParticle.acceleration = SCNVector3(0.3, -0.4, 0)
        snowParticle.blendMode = .additive

        let emitterNode = SCNNode()
        emitterNode.position = SCNVector3(0, 12, 0)
        emitterNode.addParticleSystem(snowParticle)
        scene.rootNode.addChildNode(emitterNode)

        // Lighting
        let lightNode = SCNNode()
        let light = SCNLight()
        light.type = .directional
        light.intensity = 600
        light.color = UIColor(red: 0.7, green: 0.75, blue: 0.9, alpha: 1.0)
        lightNode.light = light
        lightNode.eulerAngles = SCNVector3(-Float.pi / 4, Float.pi / 6, 0)
        scene.rootNode.addChildNode(lightNode)

        let ambientNode = SCNNode()
        ambientNode.light = SCNLight()
        ambientNode.light?.type = .ambient
        ambientNode.light?.intensity = 250
        ambientNode.light?.color = UIColor(red: 0.5, green: 0.55, blue: 0.7, alpha: 1.0)
        scene.rootNode.addChildNode(ambientNode)

        // Camera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.fieldOfView = 55
        cameraNode.position = SCNVector3(0, 1, 8)
        cameraNode.eulerAngles = SCNVector3(-Float.pi / 20, 0, 0)
        scene.rootNode.addChildNode(cameraNode)

        // Gentle camera sway
        let swayAction = SCNAction.repeatForever(SCNAction.sequence([
            SCNAction.move(by: SCNVector3(0.3, 0.1, 0), duration: 4),
            SCNAction.move(by: SCNVector3(-0.3, -0.1, 0), duration: 4),
        ]))
        cameraNode.runAction(swayAction)

        backgroundView.scene = scene
        view.addSubview(backgroundView)
    }

    private func addMountainRange(to scene: SCNScene, yOffset: Float, zOffset: Float, count: Int, color: UIColor, scale: Float) {
        for i in 0..<count {
            let width = CGFloat(Float.random(in: 5...10) * scale)
            let height = CGFloat(Float.random(in: 4...9) * scale)

            let peakGeometry = SCNPyramid(width: width, height: height, length: width * 0.8)
            let material = SCNMaterial()
            material.diffuse.contents = color
            peakGeometry.materials = [material]

            let peakNode = SCNNode(geometry: peakGeometry)
            let spacing = 25.0 / Float(count)
            peakNode.position = SCNVector3(
                Float(i) * spacing - 12.5 + Float.random(in: -2...2),
                yOffset,
                zOffset + Float.random(in: -2...2)
            )
            scene.rootNode.addChildNode(peakNode)

            // Snow cap
            let capGeometry = SCNPyramid(width: width * 0.6, height: height * 0.2, length: width * 0.5)
            let capMaterial = SCNMaterial()
            capMaterial.diffuse.contents = UIColor.white
            capGeometry.materials = [capMaterial]
            let capNode = SCNNode(geometry: capGeometry)
            capNode.position = SCNVector3(peakNode.position.x, yOffset + Float(height) * 0.7, peakNode.position.z)
            scene.rootNode.addChildNode(capNode)
        }
    }

    // MARK: - UI

    private func setupUI() {
        // Frost overlay
        let overlay = UIView()
        overlay.backgroundColor = UIColor(white: 0, alpha: 0.15)
        overlay.frame = view.bounds
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(overlay)

        // Title
        titleLabel.text = "ALPINE\nSHREDDER"
        titleLabel.numberOfLines = 2
        titleLabel.font = UIFont.systemFont(ofSize: 58, weight: .black)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.layer.shadowColor = UIColor.black.cgColor
        titleLabel.layer.shadowOffset = CGSize(width: 0, height: 4)
        titleLabel.layer.shadowRadius = 10
        titleLabel.layer.shadowOpacity = 0.6
        titleLabel.alpha = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        // Subtitle
        let subtitleLabel = UILabel()
        subtitleLabel.text = "Snowboard & Ski Adventure"
        subtitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        subtitleLabel.textColor = UIColor(white: 1.0, alpha: 0.7)
        subtitleLabel.textAlignment = .center
        subtitleLabel.alpha = 0
        subtitleLabel.tag = 100
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(subtitleLabel)

        // Play button — large and prominent
        playButton.setTitle("PLAY", for: .normal)
        playButton.setTitleColor(.white, for: .normal)
        playButton.titleLabel?.font = UIFont.systemFont(ofSize: 28, weight: .black)
        playButton.backgroundColor = UIColor(red: 0.0, green: 0.65, blue: 0.3, alpha: 1.0)
        playButton.layer.cornerRadius = 35
        playButton.layer.shadowColor = UIColor(red: 0.0, green: 0.4, blue: 0.15, alpha: 1.0).cgColor
        playButton.layer.shadowOffset = CGSize(width: 0, height: 6)
        playButton.layer.shadowRadius = 15
        playButton.layer.shadowOpacity = 0.6
        playButton.alpha = 0
        playButton.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        playButton.addTarget(self, action: #selector(playTapped), for: .touchUpInside)
        playButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(playButton)

        // Version
        versionLabel.text = "v1.0"
        versionLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        versionLabel.textColor = UIColor(white: 1.0, alpha: 0.4)
        versionLabel.textAlignment = .center
        versionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(versionLabel)

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),

            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),

            playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100),
            playButton.widthAnchor.constraint(equalToConstant: 200),
            playButton.heightAnchor.constraint(equalToConstant: 70),

            versionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            versionLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        ])
    }

    // MARK: - Animation

    private func animateEntrance() {
        // Title drops in
        UIView.animate(withDuration: 0.8, delay: 0.3, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) {
            self.titleLabel.alpha = 1
        }

        // Subtitle fades in
        if let subtitle = view.viewWithTag(100) {
            UIView.animate(withDuration: 0.6, delay: 0.8) {
                subtitle.alpha = 1
            }
        }

        // Play button bounces in
        UIView.animate(withDuration: 0.7, delay: 1.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8) {
            self.playButton.alpha = 1
            self.playButton.transform = .identity
        }

        // Pulsing glow on play button
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            UIView.animate(withDuration: 1.2, delay: 0, options: [.autoreverse, .repeat, .allowUserInteraction]) {
                self.playButton.layer.shadowRadius = 25
                self.playButton.layer.shadowOpacity = 0.9
            }
        }
    }

    // MARK: - Action

    @objc private func playTapped() {
        AudioManager.shared.playSound(.menuSelect)

        UIView.animate(withDuration: 0.15, animations: {
            self.playButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.15) {
                self.playButton.transform = .identity
            } completion: { _ in
                let sportVC = SportSelectionViewController()
                sportVC.modalPresentationStyle = .fullScreen
                sportVC.modalTransitionStyle = .crossDissolve
                self.present(sportVC, animated: true)
            }
        }
    }
}
