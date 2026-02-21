import SceneKit

/// Player character data model
struct Player {
    let characterType: CharacterType
    var position: SCNVector3
    var velocity: SCNVector3
    var isAlive: Bool
    var shielded: Bool

    init(characterType: CharacterType = .snowboarder) {
        self.characterType = characterType
        self.position = GameConstants.playerStartPosition
        self.velocity = SCNVector3Zero
        self.isAlive = true
        self.shielded = false
    }
}
