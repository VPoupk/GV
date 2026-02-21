# Alpine Shredder

A 3D snowboarding and skiing game for iOS built with Swift and SceneKit.

Race down procedurally generated mountain slopes, dodge trees, rocks, and cabins, pull off tricks mid-air, and collect coins to rack up your high score.

## Features

- **3D Procedural Terrain** — Endless snowy mountain slopes generated on the fly with moguls, ski tracks, and side mountain ranges
- **Multiple Obstacles** — Pine trees, boulders, snowmen, cabins, and jump ramps
- **Trick System** — Spins, flips, and grabs for bonus points with score multipliers
- **Collectibles** — Coins, speed boosts, shields, and score multipliers scattered along the run
- **Two Characters** — Switch between snowboarder and skier with different play styles
- **Swipe Controls** — Intuitive swipe-based steering (left/right to steer, up to jump, down to tuck/slam)
- **Score Persistence** — High scores, lifetime stats, and top 10 leaderboard saved locally
- **Particle Effects** — Falling snow, snow spray trails, and collection burst particles
- **Dynamic Difficulty** — Speed and obstacle density increase the further you go

## Requirements

- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+

## Getting Started

See [docs/SETUP.md](docs/SETUP.md) for build instructions.

## Project Structure

```
AlpineShredder/
├── project.yml                        # XcodeGen project definition
├── AlpineShredder/
│   ├── AppDelegate.swift              # App entry point
│   ├── GameViewController.swift       # SceneKit view + input handling
│   ├── LaunchScreen.storyboard        # Launch screen
│   ├── Info.plist                     # App configuration
│   ├── Game/
│   │   ├── GameScene.swift            # Main 3D scene manager
│   │   ├── GameManager.swift          # Game state & scoring
│   │   ├── TerrainGenerator.swift     # Procedural slope generation
│   │   ├── PlayerController.swift     # Player movement & tricks
│   │   ├── ObstacleManager.swift      # Obstacle spawning & lifecycle
│   │   ├── CollectibleManager.swift   # Coins & power-ups
│   │   ├── ScoreManager.swift         # Score persistence
│   │   └── AudioManager.swift         # Music & sound effects
│   ├── UI/
│   │   ├── MenuViewController.swift   # Main menu screen
│   │   ├── HUDOverlay.swift           # In-game HUD
│   │   └── GameOverView.swift         # Game over screen
│   ├── Models/
│   │   ├── Player.swift               # Player data model
│   │   ├── Obstacle.swift             # Obstacle types
│   │   └── Collectible.swift          # Collectible types
│   ├── Utils/
│   │   ├── Constants.swift            # Game tuning parameters
│   │   └── Extensions.swift           # SCNVector3 & Float helpers
│   └── Assets.xcassets/               # App icons & colors
├── AlpineShredderTests/
│   └── GameTests.swift                # Unit tests
└── docs/
    ├── SETUP.md                       # Build & run instructions
    └── GAME_DESIGN.md                 # Game design document
```

## Controls

| Gesture    | Action                    |
|------------|---------------------------|
| Swipe Left | Steer left                |
| Swipe Right| Steer right               |
| Swipe Up   | Jump (tricks while moving)|
| Swipe Down | Tuck (speed) / Slam down  |
| Pause btn  | Pause game                |

## License

This project is provided as-is for educational and personal use.
