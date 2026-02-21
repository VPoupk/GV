import UIKit
import SceneKit

/// Main menu screen with play button, character selection, and settings
class MenuViewController: UIViewController {

    // MARK: - UI Elements

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let playButton = UIButton(type: .system)
    private let characterButton = UIButton(type: .system)
    private let highScoreLabel = UILabel()
    private let settingsButton = UIButton(type: .system)
    private let statsButton = UIButton(type: .system)
    private let backgroundView = SCNView()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupUI()
        updateHighScore()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateHighScore()
    }

    override var prefersStatusBarHidden: Bool { true }

    // MARK: - Setup

    private func setupBackground() {
        backgroundView.frame = view.bounds
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        let scene = SCNScene()
        scene.background.contents = UIColor(red: 0.15, green: 0.2, blue: 0.35, alpha: 1.0)

        // Rotating mountain in background
        let mountainGeometry = SCNPyramid(width: 8, height: 6, length: 8)
        let mountainMaterial = SCNMaterial()
        mountainMaterial.diffuse.contents = UIColor(red: 0.9, green: 0.92, blue: 0.98, alpha: 1.0)
        mountainGeometry.materials = [mountainMaterial]

        let mountainNode = SCNNode(geometry: mountainGeometry)
        mountainNode.position = SCNVector3(0, -2, -8)
        mountainNode.runAction(SCNAction.repeatForever(
            SCNAction.rotateBy(x: 0, y: CGFloat.pi * 2, z: 0, duration: 30)
        ))
        scene.rootNode.addChildNode(mountainNode)

        // Snow particles
        let snowParticle = SCNParticleSystem()
        snowParticle.particleSize = 0.03
        snowParticle.particleColor = .white
        snowParticle.birthRate = 100
        snowParticle.particleLifeSpan = 6
        snowParticle.spreadingAngle = 60
        snowParticle.emitterShape = SCNBox(width: 15, height: 0.1, length: 15, chamferRadius: 0)
        snowParticle.particleVelocity = 1
        snowParticle.acceleration = SCNVector3(0, -0.3, 0)
        snowParticle.blendMode = .additive

        let emitter = SCNNode()
        emitter.position = SCNVector3(0, 8, 0)
        emitter.addParticleSystem(snowParticle)
        scene.rootNode.addChildNode(emitter)

        // Lighting
        let lightNode = SCNNode()
        let light = SCNLight()
        light.type = .directional
        light.intensity = 800
        lightNode.light = light
        lightNode.eulerAngles = SCNVector3(-Float.pi / 4, Float.pi / 4, 0)
        scene.rootNode.addChildNode(lightNode)

        let ambientNode = SCNNode()
        ambientNode.light = SCNLight()
        ambientNode.light?.type = .ambient
        ambientNode.light?.intensity = 300
        scene.rootNode.addChildNode(ambientNode)

        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 2, 6)
        cameraNode.eulerAngles = SCNVector3(-Float.pi / 12, 0, 0)
        scene.rootNode.addChildNode(cameraNode)

        backgroundView.scene = scene
        backgroundView.allowsCameraControl = false
        backgroundView.isUserInteractionEnabled = false
        view.addSubview(backgroundView)
    }

    private func setupUI() {
        // Frost/blur overlay
        let overlay = UIView()
        overlay.backgroundColor = UIColor(white: 0, alpha: 0.3)
        overlay.frame = view.bounds
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(overlay)

        // Title
        titleLabel.text = "ALPINE\nSHREDDER"
        titleLabel.numberOfLines = 2
        titleLabel.font = UIFont.systemFont(ofSize: 52, weight: .black)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.layer.shadowColor = UIColor.black.cgColor
        titleLabel.layer.shadowOffset = CGSize(width: 0, height: 3)
        titleLabel.layer.shadowRadius = 6
        titleLabel.layer.shadowOpacity = 0.5
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        // Subtitle
        subtitleLabel.text = "Snowboard & Ski Adventure"
        subtitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        subtitleLabel.textColor = UIColor(white: 1.0, alpha: 0.8)
        subtitleLabel.textAlignment = .center
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(subtitleLabel)

        // Play button
        configureButton(playButton, title: "SHRED IT!", color: UIColor(red: 0.0, green: 0.7, blue: 0.3, alpha: 1.0), fontSize: 22)
        playButton.addTarget(self, action: #selector(playTapped), for: .touchUpInside)
        view.addSubview(playButton)

        // Character selection button
        configureButton(characterButton, title: "Character: \(GameManager.shared.selectedCharacter.rawValue)", color: UIColor(red: 0.2, green: 0.5, blue: 0.9, alpha: 1.0), fontSize: 16)
        characterButton.addTarget(self, action: #selector(characterTapped), for: .touchUpInside)
        view.addSubview(characterButton)

        // High score label
        highScoreLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        highScoreLabel.textColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
        highScoreLabel.textAlignment = .center
        highScoreLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(highScoreLabel)

        // Settings and stats buttons
        let buttonStack = UIStackView()
        buttonStack.axis = .horizontal
        buttonStack.spacing = 20
        buttonStack.translatesAutoresizingMaskIntoConstraints = false

        configureSmallButton(settingsButton, systemIcon: "gearshape.fill")
        settingsButton.addTarget(self, action: #selector(settingsTapped), for: .touchUpInside)
        buttonStack.addArrangedSubview(settingsButton)

        configureSmallButton(statsButton, systemIcon: "chart.bar.fill")
        statsButton.addTarget(self, action: #selector(statsTapped), for: .touchUpInside)
        buttonStack.addArrangedSubview(statsButton)

        view.addSubview(buttonStack)

        // Layout
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),

            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),

            playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 40),
            playButton.widthAnchor.constraint(equalToConstant: 220),
            playButton.heightAnchor.constraint(equalToConstant: 56),

            characterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            characterButton.topAnchor.constraint(equalTo: playButton.bottomAnchor, constant: 16),
            characterButton.widthAnchor.constraint(equalToConstant: 220),
            characterButton.heightAnchor.constraint(equalToConstant: 44),

            highScoreLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            highScoreLabel.topAnchor.constraint(equalTo: characterButton.bottomAnchor, constant: 24),

            buttonStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
        ])
    }

    private func configureButton(_ button: UIButton, title: String, color: UIColor, fontSize: CGFloat) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: fontSize, weight: .bold)
        button.backgroundColor = color
        button.layer.cornerRadius = 12
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 8
        button.layer.shadowOpacity = 0.3
        button.translatesAutoresizingMaskIntoConstraints = false
    }

    private func configureSmallButton(_ button: UIButton, systemIcon: String) {
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        button.setImage(UIImage(systemName: systemIcon, withConfiguration: config), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
        button.layer.cornerRadius = 22
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 44),
            button.heightAnchor.constraint(equalToConstant: 44),
        ])
    }

    private func updateHighScore() {
        let highScore = ScoreManager.shared.highScore
        if highScore > 0 {
            highScoreLabel.text = "Best: \(highScore.formatted())"
        } else {
            highScoreLabel.text = "No runs yet — hit the slopes!"
        }
    }

    // MARK: - Actions

    @objc private func playTapped() {
        AudioManager.shared.playSound(.menuSelect)

        let gameVC = GameViewController()
        gameVC.modalPresentationStyle = .fullScreen
        gameVC.modalTransitionStyle = .crossDissolve
        present(gameVC, animated: true)
    }

    @objc private func characterTapped() {
        AudioManager.shared.playSound(.menuSelect)

        let types = CharacterType.allCases
        let current = GameManager.shared.selectedCharacter
        if let index = types.firstIndex(of: current) {
            let nextIndex = (index + 1) % types.count
            GameManager.shared.selectedCharacter = types[nextIndex]
            characterButton.setTitle("Character: \(types[nextIndex].rawValue)", for: .normal)
        }
    }

    @objc private func settingsTapped() {
        AudioManager.shared.playSound(.menuSelect)
        let isMuted = AudioManager.shared.toggleMute()

        let alert = UIAlertController(
            title: "Sound",
            message: isMuted ? "Sound is OFF" : "Sound is ON",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @objc private func statsTapped() {
        AudioManager.shared.playSound(.menuSelect)

        let stats = ScoreManager.shared
        let message = """
        Games Played: \(stats.gamesPlayed)
        High Score: \(stats.highScore.formatted())
        Best Distance: \(stats.bestDistance)m
        Total Coins: \(stats.totalCoins)
        Total Distance: \(stats.totalDistance)m
        """

        let alert = UIAlertController(title: "Stats", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
