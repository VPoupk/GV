# Setup & Build Instructions

## Prerequisites

- **macOS** with Xcode 15.0 or later
- **iOS 16.0+** device or simulator
- **XcodeGen** (recommended for generating the `.xcodeproj`)

## Quick Start

### Option 1: Using XcodeGen (Recommended)

1. Install XcodeGen if you haven't already:
   ```bash
   brew install xcodegen
   ```

2. Generate the Xcode project:
   ```bash
   cd AlpineShredder
   xcodegen generate
   ```

3. Open the generated project:
   ```bash
   open AlpineShredder.xcodeproj
   ```

4. Select your target device/simulator and press **Cmd+R** to build and run.

### Option 2: Manual Xcode Project

1. Open Xcode and select **File > New > Project**
2. Choose **iOS > App** and name it `AlpineShredder`
3. Set the language to **Swift** and interface to **Storyboard**
4. Delete the auto-generated files and copy the `AlpineShredder/` source folder into the project
5. Add all `.swift` files to the target
6. Build and run

## Adding Audio Assets

The game references audio files that you'll need to provide:

### Music (`.mp3` files)
- `menu_music.mp3` — Ambient menu background music
- `gameplay_music.mp3` — Upbeat gameplay music

### Sound Effects (`.wav` files)
- `coin_collect.wav` — Coin pickup sound
- `power_up.wav` — Power-up collection sound
- `crash.wav` — Collision/crash sound
- `jump.wav` — Jump sound
- `trick_land.wav` — Trick landing sound
- `menu_select.wav` — Menu button tap sound
- `swoosh.wav` — Swoosh/movement sound

Add these files to the Xcode project and ensure they are included in the **Copy Bundle Resources** build phase. The game will run without them (sounds will silently fail), but adding them enhances the experience.

## Adding an App Icon

1. Create a 1024x1024px app icon image
2. Open `Assets.xcassets` in Xcode
3. Drag your icon into the `AppIcon` image set

## Running on a Physical Device

1. Set your **Team** in the project's Signing & Capabilities
2. Connect your iOS device
3. Select it as the build target
4. Press **Cmd+R**

## Running Tests

```bash
# Via Xcode
Cmd+U

# Via command line (after generating the project)
xcodebuild test \
  -scheme AlpineShredder \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Troubleshooting

- **Build errors about missing modules**: Ensure all `.swift` files are added to the `AlpineShredder` target
- **Black screen on launch**: Check that `LaunchScreen.storyboard` is set in the target's General settings
- **No sound**: Audio files are optional; the game runs silently without them
