import SceneKit
import UIKit

/// Dynamic weather system that changes conditions during gameplay
class WeatherSystem {

    enum WeatherCondition: CaseIterable {
        case clear
        case lightSnow
        case heavySnow
        case blizzard
        case windy

        var snowBirthRate: CGFloat {
            switch self {
            case .clear: return 50
            case .lightSnow: return 200
            case .heavySnow: return 500
            case .blizzard: return 1000
            case .windy: return 300
            }
        }

        var windForce: SCNVector3 {
            switch self {
            case .clear: return SCNVector3(0, 0, 0)
            case .lightSnow: return SCNVector3(0.2, 0, 0)
            case .heavySnow: return SCNVector3(0.3, 0, -0.1)
            case .blizzard: return SCNVector3(1.0, 0, -0.3)
            case .windy: return SCNVector3(1.5, 0, 0.5)
            }
        }

        var fogMultiplier: Float {
            switch self {
            case .clear: return 1.5
            case .lightSnow: return 1.2
            case .heavySnow: return 0.8
            case .blizzard: return 0.4
            case .windy: return 1.0
            }
        }

        var visibilityLabel: String {
            switch self {
            case .clear: return "Clear"
            case .lightSnow: return "Light Snow"
            case .heavySnow: return "Heavy Snow"
            case .blizzard: return "Blizzard"
            case .windy: return "Windy"
            }
        }
    }

    private weak var scene: GameScene?
    private var snowEmitter: SCNNode?
    private var currentWeather: WeatherCondition = .lightSnow
    private var weatherTimer: Float = 0
    private var nextWeatherChange: Float = 30 // seconds until weather changes

    init(scene: GameScene) {
        self.scene = scene
    }

    /// Apply initial weather based on resort snow intensity
    func applyResortWeather(snowIntensity: Float) {
        if snowIntensity >= 1.8 {
            currentWeather = .heavySnow
        } else if snowIntensity >= 1.2 {
            currentWeather = .lightSnow
        } else {
            currentWeather = .clear
        }
        applyWeather()
    }

    /// Update weather system each frame
    func update(deltaTime: Float) {
        weatherTimer += deltaTime
        if weatherTimer >= nextWeatherChange {
            weatherTimer = 0
            nextWeatherChange = Float.random(in: 20...60)
            transitionToRandomWeather()
        }
    }

    private func transitionToRandomWeather() {
        let newWeather = WeatherCondition.allCases.randomElement() ?? .lightSnow
        guard newWeather != currentWeather else { return }
        currentWeather = newWeather
        applyWeather()
    }

    private func applyWeather() {
        guard let scene = scene else { return }

        // Update fog based on weather
        let resort = ResortManager.shared.currentResort
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 3.0
        scene.fogStartDistance = CGFloat(resort.fogStart * currentWeather.fogMultiplier)
        scene.fogEndDistance = CGFloat(resort.fogEnd * currentWeather.fogMultiplier)
        SCNTransaction.commit()

        // Update snow particle system
        if let emitter = snowEmitter {
            if let particleSystem = emitter.particleSystems?.first {
                particleSystem.birthRate = currentWeather.snowBirthRate
                particleSystem.acceleration = SCNVector3(
                    currentWeather.windForce.x,
                    particleSystem.acceleration.y,
                    currentWeather.windForce.z
                )
            }
        }
    }

    func setSnowEmitter(_ emitter: SCNNode) {
        self.snowEmitter = emitter
    }
}
