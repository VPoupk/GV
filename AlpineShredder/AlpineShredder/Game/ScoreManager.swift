import Foundation

/// Manages score persistence, high scores, and statistics
class ScoreManager {

    static let shared = ScoreManager()

    private let defaults = UserDefaults.standard

    private enum Keys {
        static let highScore = "alpine_highScore"
        static let highScores = "alpine_highScores"
        static let totalCoins = "alpine_totalCoins"
        static let totalDistance = "alpine_totalDistance"
        static let gamesPlayed = "alpine_gamesPlayed"
        static let bestDistance = "alpine_bestDistance"
    }

    // MARK: - Properties

    var highScore: Int {
        return defaults.integer(forKey: Keys.highScore)
    }

    var topScores: [ScoreEntry] {
        guard let data = defaults.data(forKey: Keys.highScores),
              let scores = try? JSONDecoder().decode([ScoreEntry].self, from: data) else {
            return []
        }
        return scores
    }

    var totalCoins: Int {
        return defaults.integer(forKey: Keys.totalCoins)
    }

    var totalDistance: Int {
        return defaults.integer(forKey: Keys.totalDistance)
    }

    var gamesPlayed: Int {
        return defaults.integer(forKey: Keys.gamesPlayed)
    }

    var bestDistance: Int {
        return defaults.integer(forKey: Keys.bestDistance)
    }

    // MARK: - Score Submission

    func submitScore(_ score: Int) {
        defaults.set(defaults.integer(forKey: Keys.gamesPlayed) + 1, forKey: Keys.gamesPlayed)

        if score > highScore {
            defaults.set(score, forKey: Keys.highScore)
        }

        var scores = topScores
        let entry = ScoreEntry(score: score, date: Date())
        scores.append(entry)
        scores.sort { $0.score > $1.score }
        if scores.count > 10 {
            scores = Array(scores.prefix(10))
        }

        if let data = try? JSONEncoder().encode(scores) {
            defaults.set(data, forKey: Keys.highScores)
        }
    }

    func addCoins(_ count: Int) {
        defaults.set(totalCoins + count, forKey: Keys.totalCoins)
    }

    func updateDistance(_ distance: Int) {
        defaults.set(totalDistance + distance, forKey: Keys.totalDistance)
        if distance > bestDistance {
            defaults.set(distance, forKey: Keys.bestDistance)
        }
    }

    func isHighScore(_ score: Int) -> Bool {
        return score > highScore
    }

    // MARK: - Reset

    func resetAll() {
        defaults.removeObject(forKey: Keys.highScore)
        defaults.removeObject(forKey: Keys.highScores)
        defaults.removeObject(forKey: Keys.totalCoins)
        defaults.removeObject(forKey: Keys.totalDistance)
        defaults.removeObject(forKey: Keys.gamesPlayed)
        defaults.removeObject(forKey: Keys.bestDistance)
    }
}

// MARK: - Score Entry

struct ScoreEntry: Codable {
    let score: Int
    let date: Date

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
