import Foundation

/// Manages per-resort leaderboard with fastest run times and high scores
class LeaderboardManager {

    static let shared = LeaderboardManager()
    private let defaults = UserDefaults.standard

    // MARK: - Data Structures

    struct RunEntry: Codable {
        let resortId: String
        let characterType: String
        let distance: Int
        let score: Int
        let runTime: TimeInterval
        let date: Date

        var formattedTime: String {
            let minutes = Int(runTime) / 60
            let seconds = Int(runTime) % 60
            let millis = Int((runTime.truncatingRemainder(dividingBy: 1)) * 100)
            return String(format: "%d:%02d.%02d", minutes, seconds, millis)
        }

        var formattedDate: String {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            return formatter.string(from: date)
        }
    }

    // MARK: - Submit Run

    func submitRun(resortId: String, characterType: String, distance: Int, score: Int, runTime: TimeInterval) {
        let entry = RunEntry(
            resortId: resortId,
            characterType: characterType,
            distance: distance,
            score: score,
            runTime: runTime,
            date: Date()
        )

        var runs = getRuns(forResort: resortId)
        runs.append(entry)

        // Sort by longest distance (best runs at top)
        runs.sort { $0.distance > $1.distance }

        // Keep top 20
        if runs.count > 20 {
            runs = Array(runs.prefix(20))
        }

        saveRuns(runs, forResort: resortId)
    }

    // MARK: - Query

    func getRuns(forResort resortId: String) -> [RunEntry] {
        let key = "leaderboard_\(resortId)"
        guard let data = defaults.data(forKey: key),
              let runs = try? JSONDecoder().decode([RunEntry].self, from: data) else {
            return []
        }
        return runs
    }

    func getTopRuns(forResort resortId: String, limit: Int = 10) -> [RunEntry] {
        return Array(getRuns(forResort: resortId).prefix(limit))
    }

    func getBestRun(forResort resortId: String) -> RunEntry? {
        return getRuns(forResort: resortId).first
    }

    func getAllResortBests() -> [String: RunEntry] {
        var bests: [String: RunEntry] = [:]
        for resort in ResortCatalog.all {
            if let best = getBestRun(forResort: resort.id) {
                bests[resort.id] = best
            }
        }
        return bests
    }

    // MARK: - Persistence

    private func saveRuns(_ runs: [RunEntry], forResort resortId: String) {
        let key = "leaderboard_\(resortId)"
        if let data = try? JSONEncoder().encode(runs) {
            defaults.set(data, forKey: key)
        }
    }

    func clearLeaderboard(forResort resortId: String) {
        defaults.removeObject(forKey: "leaderboard_\(resortId)")
    }

    func clearAll() {
        for resort in ResortCatalog.all {
            clearLeaderboard(forResort: resort.id)
        }
    }
}
