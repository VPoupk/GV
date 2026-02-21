import UIKit

/// Resort selection screen showing all available mountains
class ResortSelectionViewController: UIViewController {

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let resorts = ResortCatalog.all
    private var selectedIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        selectedIndex = ResortManager.shared.selectedResortIndex
        setupUI()
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
        titleLabel.text = "RESORTS"
        titleLabel.font = UIFont.systemFont(ofSize: 22, weight: .black)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        // Table
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ResortCell.self, forCellReuseIdentifier: "ResortCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),

            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),

            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    @objc private func backTapped() {
        dismiss(animated: true)
    }
}

extension ResortSelectionViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resorts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResortCell", for: indexPath) as! ResortCell
        let resort = resorts[indexPath.row]
        let best = LeaderboardManager.shared.getBestRun(forResort: resort.id)
        cell.configure(with: resort, bestRun: best, isSelected: indexPath.row == selectedIndex)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        ResortManager.shared.selectedResortIndex = indexPath.row
        tableView.reloadData()
        AudioManager.shared.playSound(.menuSelect)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
}

// MARK: - Resort Cell

class ResortCell: UITableViewCell {
    private let cardView = UIView()
    private let nameLabel = UILabel()
    private let locationLabel = UILabel()
    private let difficultyIcon = UIImageView()
    private let difficultyLabel = UILabel()
    private let descLabel = UILabel()
    private let bestLabel = UILabel()
    private let elevationLabel = UILabel()
    private let checkmark = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupCell() {
        backgroundColor = .clear
        selectionStyle = .none

        cardView.backgroundColor = UIColor(white: 1.0, alpha: 0.08)
        cardView.layer.cornerRadius = 14
        cardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cardView)

        nameLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        nameLabel.textColor = .white
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(nameLabel)

        locationLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        locationLabel.textColor = UIColor(white: 1.0, alpha: 0.5)
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(locationLabel)

        let iconConfig = UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)
        difficultyIcon.preferredSymbolConfiguration = iconConfig
        difficultyIcon.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(difficultyIcon)

        difficultyLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        difficultyLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(difficultyLabel)

        descLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        descLabel.textColor = UIColor(white: 1.0, alpha: 0.4)
        descLabel.numberOfLines = 2
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(descLabel)

        elevationLabel.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        elevationLabel.textColor = UIColor(white: 1.0, alpha: 0.4)
        elevationLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(elevationLabel)

        bestLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 12, weight: .semibold)
        bestLabel.textColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
        bestLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(bestLabel)

        let checkConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
        checkmark.image = UIImage(systemName: "checkmark.circle.fill", withConfiguration: checkConfig)
        checkmark.tintColor = UIColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 1.0)
        checkmark.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(checkmark)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),

            nameLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 14),
            nameLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),

            locationLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            locationLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),

            difficultyIcon.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            difficultyIcon.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 6),

            difficultyLabel.leadingAnchor.constraint(equalTo: difficultyIcon.trailingAnchor, constant: 4),
            difficultyLabel.centerYAnchor.constraint(equalTo: difficultyIcon.centerYAnchor),

            elevationLabel.leadingAnchor.constraint(equalTo: difficultyLabel.trailingAnchor, constant: 12),
            elevationLabel.centerYAnchor.constraint(equalTo: difficultyIcon.centerYAnchor),

            descLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            descLabel.topAnchor.constraint(equalTo: difficultyIcon.bottomAnchor, constant: 6),
            descLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -50),

            bestLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),
            bestLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -14),

            checkmark.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),
            checkmark.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 14),
        ])
    }

    func configure(with resort: Resort, bestRun: LeaderboardManager.RunEntry?, isSelected: Bool) {
        nameLabel.text = resort.name
        locationLabel.text = resort.location
        difficultyIcon.image = UIImage(systemName: resort.difficulty.symbol)
        difficultyIcon.tintColor = resort.difficulty.displayColor
        difficultyLabel.text = resort.difficulty.rawValue
        difficultyLabel.textColor = resort.difficulty.displayColor
        elevationLabel.text = resort.elevation
        descLabel.text = resort.description

        if let best = bestRun {
            bestLabel.text = "Best: \(best.distance)m"
        } else {
            bestLabel.text = "No runs yet"
            bestLabel.textColor = UIColor(white: 1.0, alpha: 0.3)
        }

        checkmark.isHidden = !isSelected
        cardView.layer.borderWidth = isSelected ? 2 : 0
        cardView.layer.borderColor = UIColor(red: 0.3, green: 0.7, blue: 1.0, alpha: 1.0).cgColor
    }
}
