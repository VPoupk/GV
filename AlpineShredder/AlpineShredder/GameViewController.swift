import UIKit
import SceneKit

/// Main game view controller hosting the SceneKit view and HUD
class GameViewController: UIViewController {

    // MARK: - Properties

    private var scnView: SCNView!
    private var gameScene: GameScene!
    private var hudOverlay: HUDOverlay!
    private var pauseOverlay: UIView?

    // Gesture recognizers
    private var swipeLeft: UISwipeGestureRecognizer!
    private var swipeRight: UISwipeGestureRecognizer!
    private var swipeUp: UISwipeGestureRecognizer!
    private var swipeDown: UISwipeGestureRecognizer!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
        setupHUD()
        setupGestures()
        startGame()
    }

    override var prefersStatusBarHidden: Bool { true }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }

    // MARK: - Setup

    private func setupScene() {
        scnView = SCNView(frame: view.bounds)
        scnView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scnView.antialiasingMode = .multisampling4X
        scnView.preferredFramesPerSecond = 60
        view.addSubview(scnView)

        gameScene = GameScene()
        gameScene.setupScene()
        scnView.scene = gameScene
        scnView.delegate = self

        GameManager.shared.configure(with: gameScene)
        GameManager.shared.hudDelegate = self
        GameManager.shared.gameOverDelegate = self
    }

    private func setupHUD() {
        hudOverlay = HUDOverlay(frame: view.bounds)
        hudOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        hudOverlay.onPauseTapped = { [weak self] in
            self?.togglePause()
        }
        view.addSubview(hudOverlay)
    }

    private func setupGestures() {
        swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)

        swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)

        swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeUp.direction = .up
        view.addGestureRecognizer(swipeUp)

        swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
    }

    // MARK: - Game Control

    private func startGame() {
        GameManager.shared.startGame()
    }

    private func togglePause() {
        if GameManager.shared.state == .playing {
            GameManager.shared.pauseGame()
            showPauseOverlay()
        } else if GameManager.shared.state == .paused {
            GameManager.shared.resumeGame()
            hidePauseOverlay()
        }
    }

    private func showPauseOverlay() {
        let overlay = UIView(frame: view.bounds)
        overlay.backgroundColor = UIColor(white: 0, alpha: 0.5)
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        let label = UILabel()
        label.text = "PAUSED"
        label.font = UIFont.systemFont(ofSize: 40, weight: .black)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        overlay.addSubview(label)

        let resumeButton = UIButton(type: .system)
        resumeButton.setTitle("RESUME", for: .normal)
        resumeButton.setTitleColor(.white, for: .normal)
        resumeButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        resumeButton.backgroundColor = UIColor(red: 0.0, green: 0.7, blue: 0.3, alpha: 1.0)
        resumeButton.layer.cornerRadius = 12
        resumeButton.addTarget(self, action: #selector(resumeTapped), for: .touchUpInside)
        resumeButton.translatesAutoresizingMaskIntoConstraints = false
        overlay.addSubview(resumeButton)

        let quitButton = UIButton(type: .system)
        quitButton.setTitle("QUIT", for: .normal)
        quitButton.setTitleColor(.white, for: .normal)
        quitButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        quitButton.backgroundColor = UIColor(white: 1.0, alpha: 0.15)
        quitButton.layer.cornerRadius = 12
        quitButton.addTarget(self, action: #selector(quitTapped), for: .touchUpInside)
        quitButton.translatesAutoresizingMaskIntoConstraints = false
        overlay.addSubview(quitButton)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: overlay.centerYAnchor, constant: -60),

            resumeButton.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            resumeButton.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 30),
            resumeButton.widthAnchor.constraint(equalToConstant: 200),
            resumeButton.heightAnchor.constraint(equalToConstant: 50),

            quitButton.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            quitButton.topAnchor.constraint(equalTo: resumeButton.bottomAnchor, constant: 12),
            quitButton.widthAnchor.constraint(equalToConstant: 200),
            quitButton.heightAnchor.constraint(equalToConstant: 44),
        ])

        view.addSubview(overlay)
        pauseOverlay = overlay
    }

    private func hidePauseOverlay() {
        pauseOverlay?.removeFromSuperview()
        pauseOverlay = nil
    }

    // MARK: - Actions

    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        guard GameManager.shared.state == .playing else { return }

        let direction: SwipeDirection
        switch gesture.direction {
        case .left: direction = .left
        case .right: direction = .right
        case .up: direction = .up
        case .down: direction = .down
        default: direction = .none
        }

        gameScene.playerController?.handleSwipe(direction)
    }

    @objc private func resumeTapped() {
        togglePause()
    }

    @objc private func quitTapped() {
        hidePauseOverlay()
        GameManager.shared.returnToMenu()
        dismiss(animated: true)
    }
}

// MARK: - SCNSceneRendererDelegate

extension GameViewController: SCNSceneRendererDelegate {
    func renderer(_ renderer: any SCNSceneRenderer, updateAtTime time: TimeInterval) {
        GameManager.shared.update(atTime: time)
    }
}

// MARK: - HUDDelegate

extension GameViewController: HUDDelegate {
    func didUpdateScore(_ score: Int) {
        DispatchQueue.main.async { self.hudOverlay.updateScore(score) }
    }

    func didUpdateCoins(_ coins: Int) {
        DispatchQueue.main.async { self.hudOverlay.updateCoins(coins) }
    }

    func didUpdateMultiplier(_ multiplier: Int) {
        DispatchQueue.main.async { self.hudOverlay.updateMultiplier(multiplier) }
    }

    func didUpdateSpeed(_ speed: Float) {
        DispatchQueue.main.async { self.hudOverlay.updateSpeed(speed) }
    }

    func didShowTrickScore(_ points: Int) {
        DispatchQueue.main.async { self.hudOverlay.showTrickScore(points) }
    }
}

// MARK: - GameOverDelegate

extension GameViewController: GameOverDelegate {
    func didGameOver(score: Int, distance: Int, coins: Int, isHighScore: Bool) {
        DispatchQueue.main.async {
            let gameOverView = GameOverView(frame: self.view.bounds)
            gameOverView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            gameOverView.configure(score: score, distance: distance, coins: coins, isHighScore: isHighScore)

            gameOverView.onRetry = { [weak self] in
                self?.startGame()
            }
            gameOverView.onMenu = { [weak self] in
                self?.dismiss(animated: true)
            }

            self.view.addSubview(gameOverView)
        }
    }
}
