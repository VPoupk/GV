import SceneKit
import UIKit

/// Central game state manager coordinating all game systems
class GameManager {

    // MARK: - Singleton

    static let shared = GameManager()

    // MARK: - State

    enum GameState {
        case menu
        case playing
        case paused
        case gameOver
    }

    private(set) var state: GameState = .menu
    private(set) var gameScene: GameScene?
    private(set) var score: Int = 0
    private(set) var coinsCollected: Int = 0
    private(set) var trickScore: Int = 0
    private(set) var multiplier: Int = 1
    private(set) var consecutiveTricks: Int = 0

    // Character selection
    var selectedCharacter: CharacterType = .snowboarder

    // Delegates
    weak var hudDelegate: HUDDelegate?
    weak var gameOverDelegate: GameOverDelegate?

    // MARK: - Initialization

    private init() {}

    func configure(with scene: GameScene) {
        self.gameScene = scene
    }

    // MARK: - Game Flow

    func startGame() {
        guard let scene = gameScene else { return }

        state = .playing
        score = 0
        coinsCollected = 0
        trickScore = 0
        multiplier = 1
        consecutiveTricks = 0

        scene.resetScene()
        scene.startGame()

        hudDelegate?.didUpdateScore(score)
        hudDelegate?.didUpdateCoins(coinsCollected)
        hudDelegate?.didUpdateMultiplier(multiplier)

        AudioManager.shared.playMusic(.gameplay)
    }

    func pauseGame() {
        guard state == .playing else { return }
        state = .paused
        gameScene?.stopGame()
        AudioManager.shared.pauseMusic()
    }

    func resumeGame() {
        guard state == .paused else { return }
        state = .playing
        gameScene?.isGameActive = true
        AudioManager.shared.resumeMusic()
    }

    func endGame() {
        state = .gameOver
        gameScene?.stopGame()

        let finalScore = calculateFinalScore()
        ScoreManager.shared.submitScore(finalScore)

        AudioManager.shared.stopMusic()
        AudioManager.shared.playSound(.crash)

        gameOverDelegate?.didGameOver(
            score: finalScore,
            distance: Int(gameScene?.distanceTraveled ?? 0),
            coins: coinsCollected,
            isHighScore: ScoreManager.shared.isHighScore(finalScore)
        )
    }

    func returnToMenu() {
        state = .menu
        gameScene?.stopGame()
        AudioManager.shared.playMusic(.menu)
    }

    // MARK: - Game Update

    func update(atTime time: TimeInterval) {
        guard state == .playing, let scene = gameScene else { return }

        scene.update(atTime: time)

        // Check collisions
        let collision = scene.checkCollisions()
        handleCollision(collision)

        // Update distance-based score
        let distanceScore = Int(scene.distanceTraveled * 0.5)
        let newScore = distanceScore + trickScore + (coinsCollected * GameConstants.coinValue)
        if newScore != score {
            score = newScore
            hudDelegate?.didUpdateScore(score * multiplier)
        }

        // Update speed display
        hudDelegate?.didUpdateSpeed(scene.currentSpeed)

        // Check for trick completions
        if let playerController = scene.playerController {
            updateTrickSystem(playerController)
        }
    }

    // MARK: - Collision Handling

    private func handleCollision(_ result: CollisionResult) {
        switch result {
        case .obstacle:
            endGame()

        case .collectible(let collectible):
            switch collectible.type {
            case .coin:
                coinsCollected += 1
                AudioManager.shared.playSound(.coinCollect)
                hudDelegate?.didUpdateCoins(coinsCollected)

            case .speedBoost:
                gameScene?.currentSpeed += GameConstants.speedBoostAmount
                AudioManager.shared.playSound(.powerUp)

            case .shield:
                // Future: implement shield mechanic
                AudioManager.shared.playSound(.powerUp)

            case .scoreMultiplier:
                multiplier = min(multiplier + 1, GameConstants.maxMultiplier)
                hudDelegate?.didUpdateMultiplier(multiplier)
                AudioManager.shared.playSound(.powerUp)
            }

        case .none:
            break
        }
    }

    // MARK: - Trick System

    private func updateTrickSystem(_ controller: PlayerController) {
        if controller.isPerformingTrick {
            // Trick in progress
        } else if consecutiveTricks > 0 {
            // Trick just ended — award points
            let trickPoints = GameConstants.baseTrickScore * consecutiveTricks * multiplier
            trickScore += trickPoints
            hudDelegate?.didShowTrickScore(trickPoints)
            consecutiveTricks = 0
        }
    }

    func registerTrickLanded() {
        consecutiveTricks += 1
        AudioManager.shared.playSound(.trickLand)
    }

    // MARK: - Score

    private func calculateFinalScore() -> Int {
        return score * multiplier
    }
}

// MARK: - Character Type

enum CharacterType: String, CaseIterable {
    case snowboarder = "Snowboarder"
    case skier = "Skier"

    var description: String {
        switch self {
        case .snowboarder: return "Ride the mountain on a snowboard with flip tricks"
        case .skier: return "Carve down the slopes on skis with speed bonuses"
        }
    }
}

// MARK: - Protocols

protocol HUDDelegate: AnyObject {
    func didUpdateScore(_ score: Int)
    func didUpdateCoins(_ coins: Int)
    func didUpdateMultiplier(_ multiplier: Int)
    func didUpdateSpeed(_ speed: Float)
    func didShowTrickScore(_ points: Int)
}

protocol GameOverDelegate: AnyObject {
    func didGameOver(score: Int, distance: Int, coins: Int, isHighScore: Bool)
}
