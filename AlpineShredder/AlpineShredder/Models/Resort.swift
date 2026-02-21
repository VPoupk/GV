import UIKit

/// Defines a ski resort with unique terrain, visuals, and characteristics
struct Resort {
    let id: String
    let name: String
    let location: String
    let difficulty: Difficulty
    let slopeLength: Int          // meters — 0 means endless
    let elevation: String
    let description: String

    // Visual theme
    let skyColor: UIColor
    let snowColor: UIColor
    let mountainColor: UIColor
    let fogColor: UIColor
    let fogStart: Float
    let fogEnd: Float
    let treeFrequency: Float      // 0-1 scale, how many trees
    let rockFrequency: Float
    let cabinFrequency: Float
    let snowIntensity: Float      // particle birth rate multiplier

    // Gameplay modifiers
    let speedMultiplier: Float
    let obstacleMultiplier: Float
    let widthMultiplier: Float    // track width scale

    enum Difficulty: String {
        case green = "Green Circle"
        case blue = "Blue Square"
        case black = "Black Diamond"
        case doubleBlack = "Double Black"

        var displayColor: UIColor {
            switch self {
            case .green: return UIColor(red: 0.2, green: 0.8, blue: 0.2, alpha: 1.0)
            case .blue: return UIColor(red: 0.2, green: 0.4, blue: 0.9, alpha: 1.0)
            case .black: return UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
            case .doubleBlack: return UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
            }
        }

        var symbol: String {
            switch self {
            case .green: return "circle.fill"
            case .blue: return "square.fill"
            case .black: return "diamond.fill"
            case .doubleBlack: return "diamond.fill"
            }
        }
    }
}

/// All available resorts
enum ResortCatalog {
    static let all: [Resort] = [
        Resort(
            id: "alpine_meadows",
            name: "Alpine Meadows",
            location: "Colorado, USA",
            difficulty: .green,
            slopeLength: 0,
            elevation: "2,800m",
            description: "Gentle wide-open runs with beautiful meadow views. Perfect for warming up and learning the basics.",
            skyColor: UIColor(red: 0.53, green: 0.81, blue: 0.98, alpha: 1.0),
            snowColor: UIColor(red: 0.95, green: 0.96, blue: 1.0, alpha: 1.0),
            mountainColor: UIColor(red: 0.88, green: 0.90, blue: 0.95, alpha: 1.0),
            fogColor: UIColor(white: 0.95, alpha: 1.0),
            fogStart: 100,
            fogEnd: 180,
            treeFrequency: 0.3,
            rockFrequency: 0.1,
            cabinFrequency: 0.05,
            snowIntensity: 0.8,
            speedMultiplier: 0.85,
            obstacleMultiplier: 0.7,
            widthMultiplier: 1.3
        ),
        Resort(
            id: "pine_valley",
            name: "Pine Valley",
            location: "Vermont, USA",
            difficulty: .blue,
            slopeLength: 0,
            elevation: "3,200m",
            description: "Classic New England skiing through dense pine forests. Moderate terrain with plenty of trees to dodge.",
            skyColor: UIColor(red: 0.45, green: 0.65, blue: 0.85, alpha: 1.0),
            snowColor: UIColor(red: 0.93, green: 0.95, blue: 0.98, alpha: 1.0),
            mountainColor: UIColor(red: 0.82, green: 0.85, blue: 0.9, alpha: 1.0),
            fogColor: UIColor(red: 0.85, green: 0.88, blue: 0.92, alpha: 1.0),
            fogStart: 80,
            fogEnd: 150,
            treeFrequency: 0.7,
            rockFrequency: 0.2,
            cabinFrequency: 0.1,
            snowIntensity: 1.0,
            speedMultiplier: 1.0,
            obstacleMultiplier: 1.0,
            widthMultiplier: 1.0
        ),
        Resort(
            id: "summit_peak",
            name: "Summit Peak",
            location: "Whistler, Canada",
            difficulty: .blue,
            slopeLength: 0,
            elevation: "3,600m",
            description: "High-altitude resort with wide groomed runs and stunning mountain panoramas.",
            skyColor: UIColor(red: 0.4, green: 0.6, blue: 0.95, alpha: 1.0),
            snowColor: UIColor(red: 0.94, green: 0.96, blue: 1.0, alpha: 1.0),
            mountainColor: UIColor(red: 0.85, green: 0.87, blue: 0.93, alpha: 1.0),
            fogColor: UIColor(white: 0.9, alpha: 1.0),
            fogStart: 90,
            fogEnd: 170,
            treeFrequency: 0.4,
            rockFrequency: 0.3,
            cabinFrequency: 0.08,
            snowIntensity: 1.2,
            speedMultiplier: 1.05,
            obstacleMultiplier: 1.0,
            widthMultiplier: 1.1
        ),
        Resort(
            id: "thunder_bowl",
            name: "Thunder Bowl",
            location: "Chamonix, France",
            difficulty: .black,
            slopeLength: 0,
            elevation: "4,100m",
            description: "Steep Alpine terrain with narrow chutes and exposed rock faces. Not for the faint of heart.",
            skyColor: UIColor(red: 0.35, green: 0.5, blue: 0.75, alpha: 1.0),
            snowColor: UIColor(red: 0.9, green: 0.92, blue: 0.96, alpha: 1.0),
            mountainColor: UIColor(red: 0.7, green: 0.73, blue: 0.8, alpha: 1.0),
            fogColor: UIColor(red: 0.7, green: 0.75, blue: 0.82, alpha: 1.0),
            fogStart: 60,
            fogEnd: 120,
            treeFrequency: 0.2,
            rockFrequency: 0.6,
            cabinFrequency: 0.02,
            snowIntensity: 1.5,
            speedMultiplier: 1.15,
            obstacleMultiplier: 1.3,
            widthMultiplier: 0.85
        ),
        Resort(
            id: "glacier_extreme",
            name: "Glacier Extreme",
            location: "Zermatt, Switzerland",
            difficulty: .doubleBlack,
            slopeLength: 0,
            elevation: "4,500m",
            description: "The ultimate challenge. Icy glacier runs with whiteout conditions and relentless obstacles.",
            skyColor: UIColor(red: 0.3, green: 0.4, blue: 0.55, alpha: 1.0),
            snowColor: UIColor(red: 0.85, green: 0.88, blue: 0.95, alpha: 1.0),
            mountainColor: UIColor(red: 0.6, green: 0.63, blue: 0.72, alpha: 1.0),
            fogColor: UIColor(red: 0.65, green: 0.68, blue: 0.75, alpha: 1.0),
            fogStart: 40,
            fogEnd: 90,
            treeFrequency: 0.1,
            rockFrequency: 0.7,
            cabinFrequency: 0.0,
            snowIntensity: 2.0,
            speedMultiplier: 1.3,
            obstacleMultiplier: 1.6,
            widthMultiplier: 0.75
        ),
        Resort(
            id: "sakura_slopes",
            name: "Sakura Slopes",
            location: "Niseko, Japan",
            difficulty: .blue,
            slopeLength: 0,
            elevation: "1,300m",
            description: "Famous Japanese powder with gentle tree-lined runs. Light, fluffy snow and serene atmosphere.",
            skyColor: UIColor(red: 0.6, green: 0.7, blue: 0.85, alpha: 1.0),
            snowColor: UIColor(red: 0.97, green: 0.97, blue: 1.0, alpha: 1.0),
            mountainColor: UIColor(red: 0.9, green: 0.91, blue: 0.95, alpha: 1.0),
            fogColor: UIColor(white: 0.92, alpha: 1.0),
            fogStart: 70,
            fogEnd: 140,
            treeFrequency: 0.5,
            rockFrequency: 0.15,
            cabinFrequency: 0.12,
            snowIntensity: 1.8,
            speedMultiplier: 0.95,
            obstacleMultiplier: 0.9,
            widthMultiplier: 1.05
        ),
    ]
}

/// Tracks selected resort
class ResortManager {
    static let shared = ResortManager()
    private let defaults = UserDefaults.standard

    var selectedResortIndex: Int {
        get { defaults.integer(forKey: "resort_selected") }
        set { defaults.set(newValue, forKey: "resort_selected") }
    }

    var currentResort: Resort {
        ResortCatalog.all[selectedResortIndex % ResortCatalog.all.count]
    }
}
