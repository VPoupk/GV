import UIKit

/// Per-resort leaderboard showing fastest/best runs
class LeaderboardViewController: UIViewController {

    private let segmented = UISegmentedControl()
    private let tableView = UITableView(frame: .zero, style: .plain)
    private var currentRuns: [LeaderboardManager.RunEntry] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadRuns(forResortIndex: 0)
    }

    override var prefersStatusBarHidden: Bool { true }

    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.1, green: 0.13, blue: 0.25, alpha: 1.0)

        // Header
        let backButton = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
        backButton.setImage(UIImage(systemName: "chevron.left", withConfiguration: config), for: .normal)
        backButton.tintColor = .white
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backButton)

        let titleLabel = UILabel()
        titleLabel.text = "LEADERBOARD"
        titleLabel.font = UIFont.systemFont(ofSize: 22, weight: .black)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        // Resort segmented control
        let resortNames = ResortCatalog.all.map { $0.name }
        let seg = UISegmentedControl(items: resortNames)
        seg.selectedSegmentIndex = 0
        seg.backgroundColor = UIColor(white: 1.0, alpha: 0.1)
        seg.selectedSegmentTintColor = UIColor(red: 0.3, green: 0.5, blue: 0.9, alpha: 1.0)
        seg.setTitleTextAttributes([
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 10, weight: .medium)
        ], for: .normal)
        seg.setTitleTextAttributes([
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 10, weight: .bold)
        ], for: .selected)
        seg.addTarget(self, action: #selector(resortChanged(_:)), for: .valueChanged)
        seg.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(seg)

        // Column headers
        let headerStack = UIStackView()
        headerStack.axis = .horizontal
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerStack)

        let headers = [("#", 30), ("Distance", 80), ("Score", 70), ("Time", 70), ("Type", 50), ("Date", 60)]
        for (text, width) in headers {
            let lbl = UILabel()
            lbl.text = text
            lbl.font = UIFont.systemFont(ofSize: 11, weight: .bold)
            lbl.textColor = UIColor(white: 1.0, alpha: 0.4)
            lbl.textAlignment = text == "#" ? .center : .left
            lbl.translatesAutoresizingMaskIntoConstraints = false
            lbl.widthAnchor.constraint(equalToConstant: CGFloat(width)).isActive = true
            headerStack.addArrangedSubview(lbl)
        }

        // Table
        tableView.backgroundColor = .clear
        tableView.separatorColor = UIColor(white: 1.0, alpha: 0.08)
        tableView.dataSource = self
        tableView.register(LeaderboardCell.self, forCellReuseIdentifier: "LeaderboardCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        // Empty state label
        let emptyLabel = UILabel()
        emptyLabel.text = "No runs recorded yet.\nHit the slopes!"
        emptyLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        emptyLabel.textColor = UIColor(white: 1.0, alpha: 0.4)
        emptyLabel.textAlignment = .center
        emptyLabel.numberOfLines = 2
        emptyLabel.tag = 200
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyLabel)

        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),

            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),

            seg.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            seg.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            seg.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),

            headerStack.topAnchor.constraint(equalTo: seg.bottomAnchor, constant: 16),
            headerStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            headerStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            tableView.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 6),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: tableView.centerYAnchor),
        ])
    }

    private func loadRuns(forResortIndex index: Int) {
        let resortId = ResortCatalog.all[index].id
        currentRuns = LeaderboardManager.shared.getTopRuns(forResort: resortId)
        tableView.reloadData()

        if let emptyLabel = view.viewWithTag(200) {
            emptyLabel.isHidden = !currentRuns.isEmpty
        }
    }

    @objc private func resortChanged(_ sender: UISegmentedControl) {
        loadRuns(forResortIndex: sender.selectedSegmentIndex)
    }

    @objc private func backTapped() { dismiss(animated: true) }
}

extension LeaderboardViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentRuns.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LeaderboardCell", for: indexPath) as! LeaderboardCell
        cell.configure(rank: indexPath.row + 1, entry: currentRuns[indexPath.row])
        return cell
    }
}

// MARK: - Leaderboard Cell

class LeaderboardCell: UITableViewCell {
    private let rankLabel = UILabel()
    private let distanceLabel = UILabel()
    private let scoreLabel = UILabel()
    private let timeLabel = UILabel()
    private let typeLabel = UILabel()
    private let dateLabel = UILabel()
    private let rowStack = UIStackView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none

        rowStack.axis = .horizontal
        rowStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(rowStack)

        let labels: [(UILabel, Int)] = [
            (rankLabel, 30), (distanceLabel, 80), (scoreLabel, 70),
            (timeLabel, 70), (typeLabel, 50), (dateLabel, 60)
        ]

        for (label, width) in labels {
            label.font = UIFont.monospacedDigitSystemFont(ofSize: 13, weight: .medium)
            label.textColor = UIColor(white: 1.0, alpha: 0.8)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.widthAnchor.constraint(equalToConstant: CGFloat(width)).isActive = true
            rowStack.addArrangedSubview(label)
        }

        rankLabel.textAlignment = .center
        rankLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)

        NSLayoutConstraint.activate([
            rowStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            rowStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            rowStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            rowStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(rank: Int, entry: LeaderboardManager.RunEntry) {
        rankLabel.text = "\(rank)"
        distanceLabel.text = "\(entry.distance)m"
        scoreLabel.text = "\(entry.score)"
        timeLabel.text = entry.formattedTime
        typeLabel.text = entry.characterType == "Snowboarder" ? "SB" : "Ski"
        dateLabel.text = entry.formattedDate

        // Gold/silver/bronze colors for top 3
        switch rank {
        case 1: rankLabel.textColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
        case 2: rankLabel.textColor = UIColor(red: 0.75, green: 0.78, blue: 0.82, alpha: 1.0)
        case 3: rankLabel.textColor = UIColor(red: 0.8, green: 0.5, blue: 0.2, alpha: 1.0)
        default: rankLabel.textColor = UIColor(white: 1.0, alpha: 0.6)
        }
    }
}
