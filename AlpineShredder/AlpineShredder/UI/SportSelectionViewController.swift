import UIKit
import SceneKit

/// Lets the player choose between snowboarding and skiing
class SportSelectionViewController: UIViewController {

    private let titleLabel = UILabel()
    private let boardCard = UIView()
    private let skiCard = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateCards()
    }

    override var prefersStatusBarHidden: Bool { true }

    // MARK: - UI

    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.1, green: 0.14, blue: 0.28, alpha: 1.0)

        // Snow particles on the background
        let snowView = SCNView(frame: view.bounds)
        snowView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        snowView.isUserInteractionEnabled = false
        snowView.backgroundColor = .clear
        let bgScene = SCNScene()
        bgScene.background.contents = UIColor.clear

        let snowParticle = SCNParticleSystem()
        snowParticle.particleSize = 0.03
        snowParticle.particleColor = UIColor(white: 1.0, alpha: 0.6)
        snowParticle.birthRate = 150
        snowParticle.particleLifeSpan = 8
        snowParticle.spreadingAngle = 40
        snowParticle.emitterShape = SCNBox(width: 20, height: 0.1, length: 20, chamferRadius: 0)
        snowParticle.particleVelocity = 1.5
        snowParticle.acceleration = SCNVector3(0.2, -0.3, 0)
        snowParticle.blendMode = .additive
        let emitter = SCNNode()
        emitter.position = SCNVector3(0, 10, 0)
        emitter.addParticleSystem(snowParticle)
        bgScene.rootNode.addChildNode(emitter)
        let cam = SCNNode()
        cam.camera = SCNCamera()
        cam.position = SCNVector3(0, 0, 5)
        bgScene.rootNode.addChildNode(cam)
        snowView.scene = bgScene
        view.addSubview(snowView)

        // Title
        titleLabel.text = "CHOOSE YOUR RIDE"
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .black)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        // Snowboard card
        configureCard(
            boardCard,
            title: "SNOWBOARD",
            subtitle: "Ride sideways down the mountain.\nFlip tricks, grabs, and spins.",
            iconName: "figure.snowboarding",
            color: UIColor(red: 0.15, green: 0.4, blue: 0.9, alpha: 1.0)
        )
        boardCard.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(snowboardTapped)))
        view.addSubview(boardCard)

        // Ski card
        configureCard(
            skiCard,
            title: "SKI",
            subtitle: "Carve the slopes on two planks.\nSpeed bonuses and tight turns.",
            iconName: "figure.skiing.downhill",
            color: UIColor(red: 0.9, green: 0.25, blue: 0.15, alpha: 1.0)
        )
        skiCard.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(skiTapped)))
        view.addSubview(skiCard)

        // Back button
        let backButton = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
        backButton.setImage(UIImage(systemName: "chevron.left", withConfiguration: config), for: .normal)
        backButton.tintColor = .white
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backButton)

        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),

            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),

            boardCard.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            boardCard.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            boardCard.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            boardCard.heightAnchor.constraint(equalToConstant: 180),

            skiCard.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            skiCard.topAnchor.constraint(equalTo: boardCard.bottomAnchor, constant: 24),
            skiCard.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            skiCard.heightAnchor.constraint(equalToConstant: 180),
        ])
    }

    private func configureCard(_ card: UIView, title: String, subtitle: String, iconName: String, color: UIColor) {
        card.backgroundColor = color
        card.layer.cornerRadius = 20
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOffset = CGSize(width: 0, height: 6)
        card.layer.shadowRadius = 15
        card.layer.shadowOpacity = 0.4
        card.alpha = 0
        card.transform = CGAffineTransform(translationX: 0, y: 40)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.isUserInteractionEnabled = true

        let iconConfig = UIImage.SymbolConfiguration(pointSize: 50, weight: .medium)
        let iconView = UIImageView(image: UIImage(systemName: iconName, withConfiguration: iconConfig))
        iconView.tintColor = UIColor(white: 1.0, alpha: 0.9)
        iconView.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(iconView)

        let titleLbl = UILabel()
        titleLbl.text = title
        titleLbl.font = UIFont.systemFont(ofSize: 26, weight: .black)
        titleLbl.textColor = .white
        titleLbl.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(titleLbl)

        let subtitleLbl = UILabel()
        subtitleLbl.text = subtitle
        subtitleLbl.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        subtitleLbl.textColor = UIColor(white: 1.0, alpha: 0.8)
        subtitleLbl.numberOfLines = 2
        subtitleLbl.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(subtitleLbl)

        let arrow = UIImageView(image: UIImage(systemName: "chevron.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .bold)))
        arrow.tintColor = UIColor(white: 1.0, alpha: 0.6)
        arrow.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(arrow)

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            iconView.centerYAnchor.constraint(equalTo: card.centerYAnchor),

            titleLbl.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 18),
            titleLbl.topAnchor.constraint(equalTo: card.topAnchor, constant: 35),

            subtitleLbl.leadingAnchor.constraint(equalTo: titleLbl.leadingAnchor),
            subtitleLbl.topAnchor.constraint(equalTo: titleLbl.bottomAnchor, constant: 8),
            subtitleLbl.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -40),

            arrow.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            arrow.centerYAnchor.constraint(equalTo: card.centerYAnchor),
        ])
    }

    // MARK: - Animations

    private func animateCards() {
        UIView.animate(withDuration: 0.5, delay: 0.1, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
            self.boardCard.alpha = 1
            self.boardCard.transform = .identity
        }
        UIView.animate(withDuration: 0.5, delay: 0.25, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
            self.skiCard.alpha = 1
            self.skiCard.transform = .identity
        }
    }

    // MARK: - Actions

    @objc private func snowboardTapped() {
        AudioManager.shared.playSound(.menuSelect)
        GameManager.shared.selectedCharacter = .snowboarder
        navigateToHub()
    }

    @objc private func skiTapped() {
        AudioManager.shared.playSound(.menuSelect)
        GameManager.shared.selectedCharacter = .skier
        navigateToHub()
    }

    @objc private func backTapped() {
        dismiss(animated: true)
    }

    private func navigateToHub() {
        let hubVC = MainHubViewController()
        hubVC.modalPresentationStyle = .fullScreen
        hubVC.modalTransitionStyle = .crossDissolve
        present(hubVC, animated: true)
    }
}
