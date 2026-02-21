import XCTest
@testable import AlpineShredder
import SceneKit

final class GameTests: XCTestCase {

    // MARK: - Score Manager Tests

    func testScoreSubmission() {
        let manager = ScoreManager.shared
        manager.resetAll()

        manager.submitScore(100)
        XCTAssertEqual(manager.highScore, 100)
        XCTAssertEqual(manager.gamesPlayed, 1)
    }

    func testHighScoreTracking() {
        let manager = ScoreManager.shared
        manager.resetAll()

        manager.submitScore(100)
        manager.submitScore(200)
        manager.submitScore(150)

        XCTAssertEqual(manager.highScore, 200)
        XCTAssertTrue(manager.isHighScore(201))
        XCTAssertFalse(manager.isHighScore(200))
        XCTAssertFalse(manager.isHighScore(50))
    }

    func testTopScores() {
        let manager = ScoreManager.shared
        manager.resetAll()

        for score in [100, 200, 50, 300, 150] {
            manager.submitScore(score)
        }

        let topScores = manager.topScores
        XCTAssertEqual(topScores.count, 5)
        XCTAssertEqual(topScores.first?.score, 300)
        XCTAssertEqual(topScores.last?.score, 50)
    }

    func testCoinAccumulation() {
        let manager = ScoreManager.shared
        manager.resetAll()

        manager.addCoins(10)
        XCTAssertEqual(manager.totalCoins, 10)

        manager.addCoins(5)
        XCTAssertEqual(manager.totalCoins, 15)
    }

    func testDistanceTracking() {
        let manager = ScoreManager.shared
        manager.resetAll()

        manager.updateDistance(100)
        XCTAssertEqual(manager.bestDistance, 100)
        XCTAssertEqual(manager.totalDistance, 100)

        manager.updateDistance(50)
        XCTAssertEqual(manager.bestDistance, 100) // Should still be 100
        XCTAssertEqual(manager.totalDistance, 150)

        manager.updateDistance(200)
        XCTAssertEqual(manager.bestDistance, 200)
        XCTAssertEqual(manager.totalDistance, 350)
    }

    func testResetAll() {
        let manager = ScoreManager.shared
        manager.submitScore(500)
        manager.addCoins(99)
        manager.resetAll()

        XCTAssertEqual(manager.highScore, 0)
        XCTAssertEqual(manager.totalCoins, 0)
        XCTAssertEqual(manager.gamesPlayed, 0)
        XCTAssertEqual(manager.bestDistance, 0)
        XCTAssertEqual(manager.totalDistance, 0)
        XCTAssertTrue(manager.topScores.isEmpty)
    }

    // MARK: - Bounding Box Tests

    func testBoundingBoxIntersection() {
        let box1 = BoundingBox(
            center: SCNVector3(0, 0, 0),
            halfExtent: SCNVector3(1, 1, 1)
        )
        let box2 = BoundingBox(
            center: SCNVector3(1.5, 0, 0),
            halfExtent: SCNVector3(1, 1, 1)
        )
        let box3 = BoundingBox(
            center: SCNVector3(3, 0, 0),
            halfExtent: SCNVector3(1, 1, 1)
        )

        XCTAssertTrue(box1.intersects(box2), "Overlapping boxes should intersect")
        XCTAssertFalse(box1.intersects(box3), "Non-overlapping boxes should not intersect")
    }

    func testBoundingBoxNoIntersection() {
        let box1 = BoundingBox(
            center: SCNVector3(0, 0, 0),
            halfExtent: SCNVector3(0.5, 0.5, 0.5)
        )
        let box2 = BoundingBox(
            center: SCNVector3(5, 5, 5),
            halfExtent: SCNVector3(0.5, 0.5, 0.5)
        )

        XCTAssertFalse(box1.intersects(box2))
    }

    // MARK: - Vector Extension Tests

    func testVectorAddition() {
        let v1 = SCNVector3(1, 2, 3)
        let v2 = SCNVector3(4, 5, 6)
        let result = v1 + v2

        XCTAssertEqual(result.x, 5, accuracy: 0.001)
        XCTAssertEqual(result.y, 7, accuracy: 0.001)
        XCTAssertEqual(result.z, 9, accuracy: 0.001)
    }

    func testVectorSubtraction() {
        let v1 = SCNVector3(4, 5, 6)
        let v2 = SCNVector3(1, 2, 3)
        let result = v1 - v2

        XCTAssertEqual(result.x, 3, accuracy: 0.001)
        XCTAssertEqual(result.y, 3, accuracy: 0.001)
        XCTAssertEqual(result.z, 3, accuracy: 0.001)
    }

    func testVectorScalarMultiplication() {
        let v = SCNVector3(1, 2, 3)
        let result = v * 2

        XCTAssertEqual(result.x, 2, accuracy: 0.001)
        XCTAssertEqual(result.y, 4, accuracy: 0.001)
        XCTAssertEqual(result.z, 6, accuracy: 0.001)
    }

    func testVectorLength() {
        let v = SCNVector3(3, 4, 0)
        XCTAssertEqual(v.length, 5, accuracy: 0.001)
    }

    func testVectorNormalized() {
        let v = SCNVector3(3, 0, 0)
        let n = v.normalized
        XCTAssertEqual(n.x, 1, accuracy: 0.001)
        XCTAssertEqual(n.y, 0, accuracy: 0.001)
        XCTAssertEqual(n.z, 0, accuracy: 0.001)
    }

    func testVectorDistance() {
        let v1 = SCNVector3(0, 0, 0)
        let v2 = SCNVector3(3, 4, 0)
        XCTAssertEqual(v1.distance(to: v2), 5, accuracy: 0.001)
    }

    // MARK: - Float Extension Tests

    func testFloatLerp() {
        let result = Float(0).lerp(to: 10, amount: 0.5)
        XCTAssertEqual(result, 5, accuracy: 0.001)
    }

    func testFloatClamped() {
        XCTAssertEqual(Float(5).clamped(min: 0, max: 10), 5, accuracy: 0.001)
        XCTAssertEqual(Float(-5).clamped(min: 0, max: 10), 0, accuracy: 0.001)
        XCTAssertEqual(Float(15).clamped(min: 0, max: 10), 10, accuracy: 0.001)
    }

    // MARK: - Game Constants Validity

    func testConstantsAreReasonable() {
        XCTAssertGreaterThan(GameConstants.maxSpeed, GameConstants.initialSpeed)
        XCTAssertGreaterThan(GameConstants.gravity, 0)
        XCTAssertGreaterThan(GameConstants.jumpForce, 0)
        XCTAssertGreaterThan(GameConstants.terrainWidth, 0)
        XCTAssertGreaterThan(GameConstants.maxLaneOffset, 0)
        XCTAssertGreaterThanOrEqual(GameConstants.maxMultiplier, 1)
    }

    // MARK: - Model Tests

    func testObstacleTypes() {
        XCTAssertTrue(ObstacleType.jumpRamp.isJumpable)
        XCTAssertFalse(ObstacleType.pineTree.isJumpable)
        XCTAssertFalse(ObstacleType.rock.isJumpable)
        XCTAssertFalse(ObstacleType.snowman.isJumpable)
        XCTAssertFalse(ObstacleType.cabin.isJumpable)
    }

    func testCollectibleTypeNames() {
        XCTAssertEqual(CollectibleType.coin.displayName, "Coin")
        XCTAssertEqual(CollectibleType.speedBoost.displayName, "Speed Boost")
        XCTAssertEqual(CollectibleType.shield.displayName, "Shield")
        XCTAssertEqual(CollectibleType.scoreMultiplier.displayName, "Score Multiplier")
    }

    func testCharacterTypes() {
        let allTypes = CharacterType.allCases
        XCTAssertEqual(allTypes.count, 2)
        XCTAssertTrue(allTypes.contains(.snowboarder))
        XCTAssertTrue(allTypes.contains(.skier))
    }

    func testPlayerInit() {
        let player = Player()
        XCTAssertTrue(player.isAlive)
        XCTAssertFalse(player.shielded)
        XCTAssertEqual(player.characterType, .snowboarder)
    }

    // MARK: - Int Formatting

    func testIntFormatting() {
        XCTAssertEqual(1000.formatted(), "1,000")
        XCTAssertEqual(0.formatted(), "0")
        XCTAssertEqual(999999.formatted(), "999,999")
    }
}
