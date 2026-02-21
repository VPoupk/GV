import SceneKit

/// All game constants and tuning parameters in one place
enum GameConstants {

    // MARK: - Player

    static let playerStartPosition = SCNVector3(0, 0.3, 0)
    static let playerHalfExtent = SCNVector3(0.3, 0.6, 0.5)
    static let lateralSpeed: Float = 8.0
    static let laneWidth: Float = 3.0
    static let maxLaneOffset: Float = 8.0
    static let tiltSensitivity: Float = 15.0

    // MARK: - Movement

    static let initialSpeed: Float = 8.0
    static let maxSpeed: Float = 35.0
    static let acceleration: Float = 0.3
    static let gravity: Float = 25.0
    static let jumpForce: Float = 10.0
    static let slamDownSpeed: Float = 15.0
    static let speedBoostAmount: Float = 5.0

    // MARK: - Camera

    static let cameraOffset = SCNVector3(0, 8, 12)
    static let cameraSmoothing: Float = 5.0

    // MARK: - Terrain

    static let terrainWidth: Float = 20.0
    static let terrainChunkLength: Float = 30.0
    static let terrainStartZ: Float = 10.0
    static let terrainLookAhead: Float = 120.0
    static let terrainCleanupDistance: Float = 30.0
    static let initialChunkCount = 8
    static let baseSlopeAngle: Float = 0.15

    // MARK: - Obstacles

    static let obstacleStartZ: Float = -30.0
    static let obstacleLookAhead: Float = 100.0
    static let obstacleCleanupDistance: Float = 20.0
    static let obstacleSpacing: Float = 12.0
    static let laneCount = 5

    // MARK: - Collectibles

    static let collectibleStartZ: Float = -20.0
    static let collectibleLookAhead: Float = 80.0
    static let collectibleCleanupDistance: Float = 15.0
    static let collectibleSpacing: Float = 15.0
    static let collectibleHalfExtent = SCNVector3(0.4, 0.4, 0.4)
    static let collectibleRotateSpeed: Float = 3.0
    static let coinHeight: Float = 1.0
    static let powerUpHeight: Float = 1.5

    // MARK: - Scoring

    static let coinValue = 10
    static let baseTrickScore = 50
    static let maxMultiplier = 5

    // MARK: - Tricks

    static let trickSpinSpeed: Float = 8.0
}
