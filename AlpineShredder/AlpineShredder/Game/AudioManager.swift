import AVFoundation

/// Manages all game audio — music and sound effects
class AudioManager {

    static let shared = AudioManager()

    private var musicPlayer: AVAudioPlayer?
    private var soundPlayers: [SoundEffect: AVAudioPlayer] = [:]
    private var isMuted = false

    private init() {
        configureAudioSession()
    }

    // MARK: - Configuration

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session configuration failed: \(error)")
        }
    }

    // MARK: - Music

    func playMusic(_ track: MusicTrack) {
        guard !isMuted else { return }

        guard let url = Bundle.main.url(forResource: track.filename, withExtension: "mp3") else {
            print("Music file not found: \(track.filename)")
            return
        }

        do {
            musicPlayer = try AVAudioPlayer(contentsOf: url)
            musicPlayer?.numberOfLoops = -1 // Loop forever
            musicPlayer?.volume = track.volume
            musicPlayer?.play()
        } catch {
            print("Failed to play music: \(error)")
        }
    }

    func stopMusic() {
        musicPlayer?.stop()
        musicPlayer = nil
    }

    func pauseMusic() {
        musicPlayer?.pause()
    }

    func resumeMusic() {
        guard !isMuted else { return }
        musicPlayer?.play()
    }

    // MARK: - Sound Effects

    func playSound(_ effect: SoundEffect) {
        guard !isMuted else { return }

        guard let url = Bundle.main.url(forResource: effect.filename, withExtension: "wav") else {
            // Sound file not found — silently skip in development
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = effect.volume
            player.play()
            soundPlayers[effect] = player
        } catch {
            print("Failed to play sound: \(error)")
        }
    }

    // MARK: - Controls

    func toggleMute() -> Bool {
        isMuted.toggle()
        if isMuted {
            musicPlayer?.pause()
        } else {
            musicPlayer?.play()
        }
        return isMuted
    }

    var muted: Bool {
        return isMuted
    }
}

// MARK: - Music Tracks

enum MusicTrack {
    case menu
    case gameplay

    var filename: String {
        switch self {
        case .menu: return "menu_music"
        case .gameplay: return "gameplay_music"
        }
    }

    var volume: Float {
        switch self {
        case .menu: return 0.4
        case .gameplay: return 0.3
        }
    }
}

// MARK: - Sound Effects

enum SoundEffect: Hashable {
    case coinCollect
    case powerUp
    case crash
    case jump
    case trickLand
    case menuSelect
    case swoosh

    var filename: String {
        switch self {
        case .coinCollect: return "coin_collect"
        case .powerUp: return "power_up"
        case .crash: return "crash"
        case .jump: return "jump"
        case .trickLand: return "trick_land"
        case .menuSelect: return "menu_select"
        case .swoosh: return "swoosh"
        }
    }

    var volume: Float {
        switch self {
        case .coinCollect: return 0.6
        case .powerUp: return 0.7
        case .crash: return 0.8
        case .jump: return 0.5
        case .trickLand: return 0.6
        case .menuSelect: return 0.5
        case .swoosh: return 0.4
        }
    }
}
