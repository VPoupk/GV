import UIKit

/// Snowboard and ski equipment definitions
struct Equipment: Equatable {
    let id: String
    let name: String
    let brand: String
    let color: UIColor
    let accentColor: UIColor
    let speedBonus: Float    // multiplier, e.g. 1.0 = no bonus
    let turnBonus: Float     // multiplier for lateral speed
    let trickBonus: Float    // multiplier for trick score
    let description: String

    static func == (lhs: Equipment, rhs: Equipment) -> Bool {
        return lhs.id == rhs.id
    }
}

/// All available snowboards
enum SnowboardCatalog {
    static let all: [Equipment] = [
        Equipment(
            id: "board_rookie",
            name: "Rookie Rider",
            brand: "Alpine Co.",
            color: UIColor(red: 0.15, green: 0.15, blue: 0.8, alpha: 1.0),
            accentColor: UIColor(red: 0.0, green: 0.8, blue: 1.0, alpha: 1.0),
            speedBonus: 1.0,
            turnBonus: 1.1,
            trickBonus: 1.0,
            description: "A forgiving all-mountain board perfect for beginners. Great turn response."
        ),
        Equipment(
            id: "board_velocity",
            name: "Velocity Pro",
            brand: "ShredTech",
            color: UIColor(red: 0.9, green: 0.1, blue: 0.1, alpha: 1.0),
            accentColor: UIColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0),
            speedBonus: 1.15,
            turnBonus: 0.95,
            trickBonus: 1.0,
            description: "Built for speed. Stiff flex and aggressive camber for maximum velocity."
        ),
        Equipment(
            id: "board_trickster",
            name: "Trickster 360",
            brand: "FreeStyle Labs",
            color: UIColor(red: 0.2, green: 0.8, blue: 0.3, alpha: 1.0),
            accentColor: UIColor(red: 1.0, green: 0.0, blue: 0.5, alpha: 1.0),
            speedBonus: 0.95,
            turnBonus: 1.05,
            trickBonus: 1.25,
            description: "Twin-tip freestyle board. Soft flex makes tricks easier and score higher."
        ),
        Equipment(
            id: "board_stealth",
            name: "Stealth Carbon",
            brand: "Apex",
            color: UIColor(red: 0.12, green: 0.12, blue: 0.14, alpha: 1.0),
            accentColor: UIColor(red: 0.6, green: 0.0, blue: 0.9, alpha: 1.0),
            speedBonus: 1.1,
            turnBonus: 1.1,
            trickBonus: 1.05,
            description: "Carbon fiber construction. Lightweight and responsive in all conditions."
        ),
        Equipment(
            id: "board_retro",
            name: "Retro Cruiser",
            brand: "OldSchool",
            color: UIColor(red: 0.8, green: 0.5, blue: 0.1, alpha: 1.0),
            accentColor: UIColor(red: 0.4, green: 0.2, blue: 0.1, alpha: 1.0),
            speedBonus: 1.0,
            turnBonus: 1.0,
            trickBonus: 1.1,
            description: "Classic wooden deck with modern flex. Smooth ride with vintage style."
        ),
        Equipment(
            id: "board_powder",
            name: "Powder Surfer",
            brand: "DeepSnow",
            color: UIColor(red: 0.0, green: 0.6, blue: 0.9, alpha: 1.0),
            accentColor: UIColor.white,
            speedBonus: 1.05,
            turnBonus: 1.15,
            trickBonus: 1.0,
            description: "Wide nose and setback stance. Floats through powder like a dream."
        ),
    ]
}

/// All available skis
enum SkiCatalog {
    static let all: [Equipment] = [
        Equipment(
            id: "ski_allround",
            name: "All-Mountain 88",
            brand: "Alpine Co.",
            color: UIColor(red: 0.2, green: 0.4, blue: 0.85, alpha: 1.0),
            accentColor: UIColor.white,
            speedBonus: 1.0,
            turnBonus: 1.1,
            trickBonus: 1.0,
            description: "Versatile all-mountain ski. 88mm waist handles everything on the hill."
        ),
        Equipment(
            id: "ski_racer",
            name: "GS Racer",
            brand: "SpeedLine",
            color: UIColor(red: 1.0, green: 0.2, blue: 0.0, alpha: 1.0),
            accentColor: UIColor(red: 1.0, green: 0.9, blue: 0.0, alpha: 1.0),
            speedBonus: 1.2,
            turnBonus: 0.9,
            trickBonus: 0.9,
            description: "Giant slalom race ski. Maximum edge grip and speed on groomed runs."
        ),
        Equipment(
            id: "ski_park",
            name: "Park Twin",
            brand: "FreeStyle Labs",
            color: UIColor(red: 0.0, green: 0.85, blue: 0.4, alpha: 1.0),
            accentColor: UIColor(red: 0.9, green: 0.0, blue: 0.9, alpha: 1.0),
            speedBonus: 0.95,
            turnBonus: 1.05,
            trickBonus: 1.3,
            description: "Twin-tip park ski. Buttery soft for jibbing and earns big trick bonuses."
        ),
        Equipment(
            id: "ski_backcountry",
            name: "Backcountry 110",
            brand: "WildPeak",
            color: UIColor(red: 0.35, green: 0.5, blue: 0.25, alpha: 1.0),
            accentColor: UIColor(red: 0.85, green: 0.6, blue: 0.2, alpha: 1.0),
            speedBonus: 1.05,
            turnBonus: 1.15,
            trickBonus: 1.0,
            description: "Wide backcountry ski with rocker profile. Handles variable terrain easily."
        ),
        Equipment(
            id: "ski_slalom",
            name: "Slalom SL",
            brand: "SpeedLine",
            color: UIColor(red: 0.0, green: 0.2, blue: 0.6, alpha: 1.0),
            accentColor: UIColor(red: 0.9, green: 0.1, blue: 0.1, alpha: 1.0),
            speedBonus: 1.05,
            turnBonus: 1.25,
            trickBonus: 0.95,
            description: "Short-turn specialist. Quick edge-to-edge transitions for tight carving."
        ),
        Equipment(
            id: "ski_powder",
            name: "Fat Boy 120",
            brand: "DeepSnow",
            color: UIColor(red: 0.0, green: 0.7, blue: 0.85, alpha: 1.0),
            accentColor: UIColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0),
            speedBonus: 1.0,
            turnBonus: 1.0,
            trickBonus: 1.1,
            description: "120mm underfoot powder monster. Surfs through deep snow effortlessly."
        ),
    ]
}

/// Tracks equipment selection
class EquipmentManager {
    static let shared = EquipmentManager()
    private let defaults = UserDefaults.standard

    var selectedBoardIndex: Int {
        get { defaults.integer(forKey: "equip_board") }
        set { defaults.set(newValue, forKey: "equip_board") }
    }

    var selectedSkiIndex: Int {
        get { defaults.integer(forKey: "equip_ski") }
        set { defaults.set(newValue, forKey: "equip_ski") }
    }

    var currentBoard: Equipment {
        SnowboardCatalog.all[selectedBoardIndex % SnowboardCatalog.all.count]
    }

    var currentSki: Equipment {
        SkiCatalog.all[selectedSkiIndex % SkiCatalog.all.count]
    }

    func currentEquipment(for character: CharacterType) -> Equipment {
        switch character {
        case .snowboarder: return currentBoard
        case .skier: return currentSki
        }
    }
}
