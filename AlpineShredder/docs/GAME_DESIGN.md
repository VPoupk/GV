# Alpine Shredder — Game Design Document

## Overview

**Alpine Shredder** is an endless-runner style 3D snowboarding/skiing game for iOS. The player races downhill on a procedurally generated mountain, avoiding obstacles and collecting items while performing tricks for bonus points.

## Core Gameplay Loop

1. Player starts at the top of a slope
2. Player automatically moves downhill with increasing speed
3. Player steers left/right and jumps to avoid obstacles
4. Coins and power-ups are collected along the run
5. Tricks can be performed mid-air for score bonuses
6. Game ends when the player hits an obstacle
7. Final score is displayed with option to retry

## Controls

- **Swipe Left/Right**: Move the player laterally across the slope
- **Swipe Up**: Jump (triggers trick if moving horizontally)
- **Swipe Down**: Tuck for a speed burst, or slam down if airborne
- **Tilt** (optional): Accelerometer-based fine steering

## Characters

### Snowboarder
- Default character
- Can perform flip tricks (grabs, spins)
- Slightly wider stance for stable landings

### Skier
- Alternate character
- Speed bonus on straightaways
- Different visual model

## Obstacles

| Type      | Description                        | Collision |
|-----------|------------------------------------|-----------|
| Pine Tree | Snow-covered evergreen tree        | Fatal     |
| Rock      | Boulder with snow dusting          | Fatal     |
| Snowman   | Classic three-ball snowman         | Fatal     |
| Cabin     | Log cabin with snowy roof          | Fatal     |
| Jump Ramp | Angled snow ramp with flag markers | Launches  |

## Collectibles

| Type             | Effect                              |
|------------------|-------------------------------------|
| Coin             | +10 points each                     |
| Speed Boost      | Temporary speed increase            |
| Shield           | Survive one obstacle hit (planned)  |
| Score Multiplier | Increases score multiplier by 1     |

## Scoring

- **Distance**: 0.5 points per meter traveled
- **Coins**: 10 points each
- **Tricks**: 50 base points x consecutive trick count x multiplier
- **Multiplier**: Starts at x1, increases with Score Multiplier pickups (max x5)
- **Final Score**: All points combined

## Difficulty Progression

- Speed increases gradually from 8 m/s up to 35 m/s
- Obstacle density increases with distance traveled
- More obstacle types appear at higher distances
- Gaps between obstacles narrow over time

## Visual Design

- **Snow-covered mountain environment** with fog for draw distance
- **Dynamic lighting** with directional sun and ambient fill
- **Particle effects**: falling snow, snow spray behind player
- **Color palette**: White/blue for snow, green for trees, warm tones for cabins

## Technical Architecture

- **SceneKit** for 3D rendering and scene management
- **Procedural generation** for infinite terrain chunks
- **AABB collision detection** for obstacle/collectible interactions
- **UserDefaults** for score persistence
- **AVFoundation** for audio playback

## Future Enhancements

- Online leaderboards via Game Center
- Additional characters and skins
- Night mode / weather variations
- Slalom race mode with gates
- Shield power-up implementation
- Haptic feedback on collisions and collections
