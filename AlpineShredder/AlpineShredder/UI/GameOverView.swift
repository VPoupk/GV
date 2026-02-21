import UIKit

/// Game over screen showing final score, stats, and replay options
class GameOverView: UIView {

    // MARK: - UI Elements

    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let scoreLabel = UILabel()
    private let highScoreBadge = UILabel()
    private let statsStack = UIStackView()
    private let retryButton = UIButton(type: .system)
    private let menuButton = UIButton(type: .system)

    // MARK: - Callbacks

    var onRetry: (() -> Void)?
    var onMenu: (() -> Void)?

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    // MARK: - Setup

    private func setupUI() {
        backgroundColor = UIColor(white: 0, alpha: 0.6)

        // Container card
        containerView.backgroundColor = UIColor(red: 0.12, green: 0.14, blue: 0.22, alpha: 0.95)
        containerView.layer.cornerRadius = 20
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 8)
        containerView.layer.shadowRadius = 20
        containerView.layer.shadowOpacity = 0.5
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)

        // Title
        titleLabel.text = "WIPEOUT!"
        titleLabel.font = UIFont.systemFont(ofSize: 36, weight: .black)
        titleLabel.textColor = UIColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 1.0)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)

        // Score
        scoreLabel.text = "0"
        scoreLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 48, weight: .bold)
        scoreLabel.textColor = .white
        scoreLabel.textAlignment = .center
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(scoreLabel)

        // High score badge
        highScoreBadge.text = "NEW HIGH SCORE!"
        highScoreBadge.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        highScoreBadge.textColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
        highScoreBadge.textAlignment = .center
        highScoreBadge.isHidden = true
        highScoreBadge.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(highScoreBadge)

        // Stats stack
        statsStack.axis = .horizontal
        statsStack.distribution = .fillEqually
        statsStack.spacing = 16
        statsStack.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(statsStack)

        // Retry button
        retryButton.setTitle("TRY AGAIN", for: .normal)
        retryButton.setTitleColor(.white, for: .normal)
        retryButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        retryButton.backgroundColor = UIColor(red: 0.0, green: 0.7, blue: 0.3, alpha: 1.0)
        retryButton.layer.cornerRadius = 12
        retryButton.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)
        retryButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(retryButton)

        // Menu button
        menuButton.setTitle("MAIN MENU", for: .normal)
        menuButton.setTitleColor(.white, for: .normal)
        menuButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        menuButton.backgroundColor = UIColor(white: 1.0, alpha: 0.15)
        menuButton.layer.cornerRadius = 12
        menuButton.addTarget(self, action: #selector(menuTapped), for: .touchUpInside)
        menuButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(menuButton)

        // Layout
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 300),

            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),

            scoreLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            scoreLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            scoreLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),

            highScoreBadge.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 4),
            highScoreBadge.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),

            statsStack.topAnchor.constraint(equalTo: highScoreBadge.bottomAnchor, constant: 20),
            statsStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            statsStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),

            retryButton.topAnchor.constraint(equalTo: statsStack.bottomAnchor, constant: 24),
            retryButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            retryButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            retryButton.heightAnchor.constraint(equalToConstant: 50),

            menuButton.topAnchor.constraint(equalTo: retryButton.bottomAnchor, constant: 10),
            menuButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            menuButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            menuButton.heightAnchor.constraint(equalToConstant: 44),
            menuButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -24),
        ])
    }

    // MARK: - Configuration

    func configure(score: Int, distance: Int, coins: Int, isHighScore: Bool) {
        scoreLabel.text = score.formatted()
        highScoreBadge.isHidden = !isHighScore

        // Clear and rebuild stats
        statsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        addStat(title: "Distance", value: "\(distance)m")
        addStat(title: "Coins", value: "\(coins)")

        // Animate entrance
        containerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        containerView.alpha = 0
        alpha = 0

        UIView.animate(withDuration: 0.4, delay: 0.2, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) {
            self.alpha = 1
            self.containerView.alpha = 1
            self.containerView.transform = .identity
        }

        if isHighScore {
            animateHighScoreBadge()
        }
    }

    private func addStat(title: String, value: String) {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 4

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = UIColor(white: 1.0, alpha: 0.6)
        stack.addArrangedSubview(titleLabel)

        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 22, weight: .bold)
        valueLabel.textColor = .white
        stack.addArrangedSubview(valueLabel)

        statsStack.addArrangedSubview(stack)
    }

    private func animateHighScoreBadge() {
        UIView.animate(withDuration: 0.6, delay: 0.5, options: [.autoreverse, .repeat]) {
            self.highScoreBadge.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }
    }

    // MARK: - Actions

    @objc private func retryTapped() {
        UIView.animate(withDuration: 0.2) {
            self.alpha = 0
        } completion: { _ in
            self.onRetry?()
            self.removeFromSuperview()
        }
    }

    @objc private func menuTapped() {
        UIView.animate(withDuration: 0.2) {
            self.alpha = 0
        } completion: { _ in
            self.onMenu?()
            self.removeFromSuperview()
        }
    }
}
