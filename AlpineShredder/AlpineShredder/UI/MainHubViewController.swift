import UIKit

/// Central hub screen with access to all game features
class MainHubViewController: UIViewController {

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override var prefersStatusBarHidden: Bool { true }

    // MARK: - UI

    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.1, green: 0.14, blue: 0.28, alpha: 1.0)

        // Header
        let headerView = UIView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)

        let backButton = UIButton(type: .system)
        let backConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
        backButton.setImage(UIImage(systemName: "chevron.left", withConfiguration: backConfig), for: .normal)
        backButton.tintColor = .white
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(backButton)

        let characterLabel = UILabel()
        characterLabel.text = GameManager.shared.selectedCharacter.rawValue.uppercased()
        characterLabel.font = UIFont.systemFont(ofSize: 22, weight: .black)
        characterLabel.textColor = .white
        characterLabel.textAlignment = .center
        characterLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(characterLabel)

        // Scroll view with menu items
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        contentStack.axis = .vertical
        contentStack.spacing = 14
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)

        // GO button at top
        let goButton = createGoButton()
        contentStack.addArrangedSubview(goButton)

        // Menu cards
        contentStack.addArrangedSubview(createMenuCard(
            title: "Character", icon: "person.fill",
            subtitle: "Customize your look",
            color: UIColor(red: 0.6, green: 0.2, blue: 0.8, alpha: 1.0),
            action: #selector(characterTapped)
        ))

        contentStack.addArrangedSubview(createMenuCard(
            title: "Equipment", icon: "snowflake",
            subtitle: GameManager.shared.selectedCharacter == .snowboarder ? "Choose your snowboard" : "Choose your skis",
            color: UIColor(red: 0.2, green: 0.5, blue: 0.9, alpha: 1.0),
            action: #selector(equipmentTapped)
        ))

        contentStack.addArrangedSubview(createMenuCard(
            title: "Resorts", icon: "mountain.2.fill",
            subtitle: "Pick a mountain to ride",
            color: UIColor(red: 0.15, green: 0.65, blue: 0.45, alpha: 1.0),
            action: #selector(resortTapped)
        ))

        contentStack.addArrangedSubview(createMenuCard(
            title: "Tutorial", icon: "book.fill",
            subtitle: "Learn how to play",
            color: UIColor(red: 0.9, green: 0.5, blue: 0.1, alpha: 1.0),
            action: #selector(tutorialTapped)
        ))

        contentStack.addArrangedSubview(createMenuCard(
            title: "Techniques", icon: "figure.snowboarding",
            subtitle: "Real riding techniques",
            color: UIColor(red: 0.2, green: 0.7, blue: 0.8, alpha: 1.0),
            action: #selector(techniquesTapped)
        ))

        contentStack.addArrangedSubview(createMenuCard(
            title: "Leaderboard", icon: "trophy.fill",
            subtitle: "Fastest runs by resort",
            color: UIColor(red: 0.85, green: 0.65, blue: 0.1, alpha: 1.0),
            action: #selector(leaderboardTapped)
        ))

        // Spacer at bottom
        let spacer = UIView()
        spacer.heightAnchor.constraint(equalToConstant: 30).isActive = true
        contentStack.addArrangedSubview(spacer)

        // Layout
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 50),

            backButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            backButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            characterLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            characterLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            scrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 10),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40),
        ])
    }

    private func createGoButton() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let button = UIButton(type: .system)
        button.setTitle("SHRED IT!", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .black)
        button.backgroundColor = UIColor(red: 0.0, green: 0.7, blue: 0.3, alpha: 1.0)
        button.layer.cornerRadius = 16
        button.layer.shadowColor = UIColor(red: 0.0, green: 0.5, blue: 0.2, alpha: 1.0).cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 12
        button.layer.shadowOpacity = 0.5
        button.addTarget(self, action: #selector(playTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(button)

        let resortLabel = UILabel()
        let resort = ResortManager.shared.currentResort
        resortLabel.text = "\(resort.name) - \(resort.difficulty.rawValue)"
        resortLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        resortLabel.textColor = UIColor(white: 1.0, alpha: 0.6)
        resortLabel.textAlignment = .center
        resortLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(resortLabel)

        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: container.topAnchor),
            button.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            button.heightAnchor.constraint(equalToConstant: 60),

            resortLabel.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 6),
            resortLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            resortLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])

        return container
    }

    private func createMenuCard(title: String, icon: String, subtitle: String, color: UIColor, action: Selector) -> UIView {
        let card = UIView()
        card.backgroundColor = UIColor(white: 1.0, alpha: 0.08)
        card.layer.cornerRadius = 14
        card.isUserInteractionEnabled = true
        card.addGestureRecognizer(UITapGestureRecognizer(target: self, action: action))
        card.translatesAutoresizingMaskIntoConstraints = false

        let iconBg = UIView()
        iconBg.backgroundColor = color
        iconBg.layer.cornerRadius = 20
        iconBg.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(iconBg)

        let iconConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        let iconView = UIImageView(image: UIImage(systemName: icon, withConfiguration: iconConfig))
        iconView.tintColor = .white
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconBg.addSubview(iconView)

        let titleLbl = UILabel()
        titleLbl.text = title
        titleLbl.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        titleLbl.textColor = .white
        titleLbl.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(titleLbl)

        let subtitleLbl = UILabel()
        subtitleLbl.text = subtitle
        subtitleLbl.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        subtitleLbl.textColor = UIColor(white: 1.0, alpha: 0.5)
        subtitleLbl.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(subtitleLbl)

        let arrow = UIImageView(image: UIImage(systemName: "chevron.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)))
        arrow.tintColor = UIColor(white: 1.0, alpha: 0.3)
        arrow.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(arrow)

        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(equalToConstant: 64),

            iconBg.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            iconBg.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            iconBg.widthAnchor.constraint(equalToConstant: 40),
            iconBg.heightAnchor.constraint(equalToConstant: 40),

            iconView.centerXAnchor.constraint(equalTo: iconBg.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconBg.centerYAnchor),

            titleLbl.leadingAnchor.constraint(equalTo: iconBg.trailingAnchor, constant: 14),
            titleLbl.topAnchor.constraint(equalTo: card.topAnchor, constant: 13),

            subtitleLbl.leadingAnchor.constraint(equalTo: titleLbl.leadingAnchor),
            subtitleLbl.topAnchor.constraint(equalTo: titleLbl.bottomAnchor, constant: 2),

            arrow.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            arrow.centerYAnchor.constraint(equalTo: card.centerYAnchor),
        ])

        return card
    }

    // MARK: - Actions

    @objc private func backTapped() {
        dismiss(animated: true)
    }

    @objc private func playTapped() {
        AudioManager.shared.playSound(.menuSelect)
        let gameVC = GameViewController()
        gameVC.modalPresentationStyle = .fullScreen
        gameVC.modalTransitionStyle = .crossDissolve
        present(gameVC, animated: true)
    }

    @objc private func characterTapped() {
        AudioManager.shared.playSound(.menuSelect)
        let vc = CharacterCustomizationViewController()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }

    @objc private func equipmentTapped() {
        AudioManager.shared.playSound(.menuSelect)
        let vc = EquipmentSelectionViewController()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }

    @objc private func resortTapped() {
        AudioManager.shared.playSound(.menuSelect)
        let vc = ResortSelectionViewController()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }

    @objc private func tutorialTapped() {
        AudioManager.shared.playSound(.menuSelect)
        let vc = TutorialViewController()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }

    @objc private func techniquesTapped() {
        AudioManager.shared.playSound(.menuSelect)
        let vc = TechniquesViewController()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }

    @objc private func leaderboardTapped() {
        AudioManager.shared.playSound(.menuSelect)
        let vc = LeaderboardViewController()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
}
