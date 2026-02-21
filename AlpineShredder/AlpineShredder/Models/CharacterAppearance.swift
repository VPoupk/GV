import UIKit

/// Stores all character customization options
class CharacterAppearance {

    static let shared = CharacterAppearance()

    // MARK: - Gender

    enum Gender: String, CaseIterable, Codable {
        case boy = "Boy"
        case girl = "Girl"

        var bodyScale: (width: Float, height: Float) {
            switch self {
            case .boy: return (1.0, 1.0)
            case .girl: return (0.9, 0.95)
            }
        }

        var headScale: Float {
            switch self {
            case .boy: return 1.0
            case .girl: return 0.95
            }
        }
    }

    // MARK: - Color Presets

    struct ColorOption: Equatable {
        let name: String
        let color: UIColor

        static func == (lhs: ColorOption, rhs: ColorOption) -> Bool {
            return lhs.name == rhs.name
        }
    }

    static let jacketColors: [ColorOption] = [
        ColorOption(name: "Red", color: UIColor(red: 0.9, green: 0.2, blue: 0.1, alpha: 1.0)),
        ColorOption(name: "Blue", color: UIColor(red: 0.15, green: 0.4, blue: 0.9, alpha: 1.0)),
        ColorOption(name: "Green", color: UIColor(red: 0.1, green: 0.7, blue: 0.3, alpha: 1.0)),
        ColorOption(name: "Orange", color: UIColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0)),
        ColorOption(name: "Purple", color: UIColor(red: 0.6, green: 0.2, blue: 0.8, alpha: 1.0)),
        ColorOption(name: "Black", color: UIColor(red: 0.15, green: 0.15, blue: 0.18, alpha: 1.0)),
        ColorOption(name: "White", color: UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0)),
        ColorOption(name: "Pink", color: UIColor(red: 1.0, green: 0.4, blue: 0.6, alpha: 1.0)),
        ColorOption(name: "Yellow", color: UIColor(red: 1.0, green: 0.85, blue: 0.1, alpha: 1.0)),
        ColorOption(name: "Teal", color: UIColor(red: 0.0, green: 0.7, blue: 0.7, alpha: 1.0)),
    ]

    static let pantsColors: [ColorOption] = [
        ColorOption(name: "Black", color: UIColor(red: 0.15, green: 0.15, blue: 0.18, alpha: 1.0)),
        ColorOption(name: "Navy", color: UIColor(red: 0.1, green: 0.1, blue: 0.35, alpha: 1.0)),
        ColorOption(name: "Gray", color: UIColor(red: 0.4, green: 0.4, blue: 0.42, alpha: 1.0)),
        ColorOption(name: "White", color: UIColor(red: 0.92, green: 0.92, blue: 0.95, alpha: 1.0)),
        ColorOption(name: "Red", color: UIColor(red: 0.7, green: 0.15, blue: 0.1, alpha: 1.0)),
        ColorOption(name: "Olive", color: UIColor(red: 0.35, green: 0.4, blue: 0.2, alpha: 1.0)),
        ColorOption(name: "Brown", color: UIColor(red: 0.4, green: 0.28, blue: 0.15, alpha: 1.0)),
        ColorOption(name: "Blue", color: UIColor(red: 0.2, green: 0.3, blue: 0.7, alpha: 1.0)),
    ]

    static let bootColors: [ColorOption] = [
        ColorOption(name: "Black", color: UIColor(red: 0.12, green: 0.12, blue: 0.14, alpha: 1.0)),
        ColorOption(name: "White", color: UIColor(red: 0.9, green: 0.9, blue: 0.92, alpha: 1.0)),
        ColorOption(name: "Red", color: UIColor(red: 0.8, green: 0.15, blue: 0.1, alpha: 1.0)),
        ColorOption(name: "Blue", color: UIColor(red: 0.1, green: 0.2, blue: 0.7, alpha: 1.0)),
        ColorOption(name: "Green", color: UIColor(red: 0.1, green: 0.5, blue: 0.2, alpha: 1.0)),
        ColorOption(name: "Orange", color: UIColor(red: 0.9, green: 0.45, blue: 0.0, alpha: 1.0)),
    ]

    static let helmetColors: [ColorOption] = [
        ColorOption(name: "Black", color: UIColor(red: 0.1, green: 0.1, blue: 0.12, alpha: 1.0)),
        ColorOption(name: "White", color: UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0)),
        ColorOption(name: "Red", color: UIColor(red: 0.85, green: 0.15, blue: 0.1, alpha: 1.0)),
        ColorOption(name: "Blue", color: UIColor(red: 0.15, green: 0.3, blue: 0.85, alpha: 1.0)),
        ColorOption(name: "Neon Green", color: UIColor(red: 0.3, green: 1.0, blue: 0.2, alpha: 1.0)),
        ColorOption(name: "Matte Gray", color: UIColor(red: 0.35, green: 0.35, blue: 0.38, alpha: 1.0)),
        ColorOption(name: "Pink", color: UIColor(red: 1.0, green: 0.35, blue: 0.55, alpha: 1.0)),
        ColorOption(name: "Gold", color: UIColor(red: 0.85, green: 0.7, blue: 0.2, alpha: 1.0)),
    ]

    static let gloveColors: [ColorOption] = [
        ColorOption(name: "Black", color: UIColor(red: 0.1, green: 0.1, blue: 0.12, alpha: 1.0)),
        ColorOption(name: "Gray", color: UIColor(red: 0.45, green: 0.45, blue: 0.48, alpha: 1.0)),
        ColorOption(name: "Red", color: UIColor(red: 0.75, green: 0.15, blue: 0.1, alpha: 1.0)),
        ColorOption(name: "Blue", color: UIColor(red: 0.1, green: 0.25, blue: 0.7, alpha: 1.0)),
        ColorOption(name: "White", color: UIColor(red: 0.9, green: 0.9, blue: 0.92, alpha: 1.0)),
        ColorOption(name: "Orange", color: UIColor(red: 0.9, green: 0.4, blue: 0.0, alpha: 1.0)),
    ]

    static let goggleColors: [ColorOption] = [
        ColorOption(name: "Orange", color: UIColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 1.0)),
        ColorOption(name: "Blue Mirror", color: UIColor(red: 0.2, green: 0.5, blue: 1.0, alpha: 1.0)),
        ColorOption(name: "Gold", color: UIColor(red: 0.85, green: 0.7, blue: 0.15, alpha: 1.0)),
        ColorOption(name: "Green", color: UIColor(red: 0.2, green: 0.8, blue: 0.3, alpha: 1.0)),
        ColorOption(name: "Rose", color: UIColor(red: 0.9, green: 0.3, blue: 0.5, alpha: 1.0)),
        ColorOption(name: "Silver", color: UIColor(red: 0.75, green: 0.78, blue: 0.82, alpha: 1.0)),
    ]

    // MARK: - Current Selections (persisted)

    private let defaults = UserDefaults.standard
    private enum Keys {
        static let gender = "char_gender"
        static let jacketIndex = "char_jacket"
        static let pantsIndex = "char_pants"
        static let bootIndex = "char_boots"
        static let helmetIndex = "char_helmet"
        static let gloveIndex = "char_gloves"
        static let goggleIndex = "char_goggles"
    }

    var gender: Gender {
        get {
            guard let raw = defaults.string(forKey: Keys.gender),
                  let g = Gender(rawValue: raw) else { return .boy }
            return g
        }
        set { defaults.set(newValue.rawValue, forKey: Keys.gender) }
    }

    var jacketColorIndex: Int {
        get { defaults.integer(forKey: Keys.jacketIndex) }
        set { defaults.set(newValue, forKey: Keys.jacketIndex) }
    }

    var pantsColorIndex: Int {
        get { defaults.integer(forKey: Keys.pantsIndex) }
        set { defaults.set(newValue, forKey: Keys.pantsIndex) }
    }

    var bootColorIndex: Int {
        get { defaults.integer(forKey: Keys.bootIndex) }
        set { defaults.set(newValue, forKey: Keys.bootIndex) }
    }

    var helmetColorIndex: Int {
        get { defaults.integer(forKey: Keys.helmetIndex) }
        set { defaults.set(newValue, forKey: Keys.helmetIndex) }
    }

    var gloveColorIndex: Int {
        get { defaults.integer(forKey: Keys.gloveIndex) }
        set { defaults.set(newValue, forKey: Keys.gloveIndex) }
    }

    var goggleColorIndex: Int {
        get { defaults.integer(forKey: Keys.goggleIndex) }
        set { defaults.set(newValue, forKey: Keys.goggleIndex) }
    }

    // MARK: - Convenience Accessors

    var jacketColor: UIColor { Self.jacketColors[jacketColorIndex % Self.jacketColors.count].color }
    var pantsColor: UIColor { Self.pantsColors[pantsColorIndex % Self.pantsColors.count].color }
    var bootColor: UIColor { Self.bootColors[bootColorIndex % Self.bootColors.count].color }
    var helmetColor: UIColor { Self.helmetColors[helmetColorIndex % Self.helmetColors.count].color }
    var gloveColor: UIColor { Self.gloveColors[gloveColorIndex % Self.gloveColors.count].color }
    var goggleColor: UIColor { Self.goggleColors[goggleColorIndex % Self.goggleColors.count].color }
}
