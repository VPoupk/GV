import UIKit

/// In-game heads-up display showing score, coins, speed, and multiplier
class HUDOverlay: UIView {

    // MARK: - UI Elements

    private let scoreLabel = UILabel()
    private let coinLabel = UILabel()
    private let speedLabel = UILabel()
    private let multiplierLabel = UILabel()
    private let distanceLabel = UILabel()
    private let pauseButton = UIButton(type: .system)
    private let trickScoreLabel = UILabel()

    // MARK: - Callbacks

    var onPauseTapped: (() -> Void)?

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
        isUserInteractionEnabled = true
        backgroundColor = .clear

        // Score (top center)
        scoreLabel.text = "0"
        scoreLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 36, weight: .bold)
        scoreLabel.textColor = .white
        scoreLabel.textAlignment = .center
        scoreLabel.layer.shadowColor = UIColor.black.cgColor
        scoreLabel.layer.shadowOffset = CGSize(width: 0, height: 2)
        scoreLabel.layer.shadowRadius = 4
        scoreLabel.layer.shadowOpacity = 0.5
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scoreLabel)

        // Coin count (top left)
        coinLabel.text = "0"
        coinLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 18, weight: .semibold)
        coinLabel.textColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
        coinLabel.layer.shadowColor = UIColor.black.cgColor
        coinLabel.layer.shadowOffset = CGSize(width: 0, height: 1)
        coinLabel.layer.shadowRadius = 2
        coinLabel.layer.shadowOpacity = 0.5
        coinLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(coinLabel)

        // Speed (bottom left)
        speedLabel.text = "0 km/h"
        speedLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 16, weight: .medium)
        speedLabel.textColor = UIColor(white: 1.0, alpha: 0.8)
        speedLabel.layer.shadowColor = UIColor.black.cgColor
        speedLabel.layer.shadowOffset = CGSize(width: 0, height: 1)
        speedLabel.layer.shadowRadius = 2
        speedLabel.layer.shadowOpacity = 0.5
        speedLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(speedLabel)

        // Multiplier (top right)
        multiplierLabel.text = "x1"
        multiplierLabel.font = UIFont.systemFont(ofSize: 22, weight: .heavy)
        multiplierLabel.textColor = UIColor(red: 0.4, green: 1.0, blue: 0.4, alpha: 1.0)
        multiplierLabel.textAlignment = .right
        multiplierLabel.layer.shadowColor = UIColor.black.cgColor
        multiplierLabel.layer.shadowOffset = CGSize(width: 0, height: 1)
        multiplierLabel.layer.shadowRadius = 2
        multiplierLabel.layer.shadowOpacity = 0.5
        multiplierLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(multiplierLabel)

        // Pause button (top right corner)
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .bold)
        pauseButton.setImage(UIImage(systemName: "pause.fill", withConfiguration: config), for: .normal)
        pauseButton.tintColor = .white
        pauseButton.backgroundColor = UIColor(white: 0, alpha: 0.3)
        pauseButton.layer.cornerRadius = 18
        pauseButton.addTarget(self, action: #selector(pauseTapped), for: .touchUpInside)
        pauseButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(pauseButton)

        // Trick score popup (center)
        trickScoreLabel.text = ""
        trickScoreLabel.font = UIFont.systemFont(ofSize: 28, weight: .black)
        trickScoreLabel.textColor = UIColor(red: 1.0, green: 0.4, blue: 0.0, alpha: 1.0)
        trickScoreLabel.textAlignment = .center
        trickScoreLabel.alpha = 0
        trickScoreLabel.layer.shadowColor = UIColor.black.cgColor
        trickScoreLabel.layer.shadowOffset = CGSize(width: 0, height: 2)
        trickScoreLabel.layer.shadowRadius = 4
        trickScoreLabel.layer.shadowOpacity = 0.6
        trickScoreLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(trickScoreLabel)

        // Layout
        NSLayoutConstraint.activate([
            scoreLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            scoreLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 8),

            coinLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            coinLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),

            multiplierLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -60),
            multiplierLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),

            pauseButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            pauseButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 12),
            pauseButton.widthAnchor.constraint(equalToConstant: 36),
            pauseButton.heightAnchor.constraint(equalToConstant: 36),

            speedLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            speedLabel.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20),

            trickScoreLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            trickScoreLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -40),
        ])
    }

    // MARK: - Actions

    @objc private func pauseTapped() {
        onPauseTapped?()
    }

    // MARK: - Updates

    func updateScore(_ score: Int) {
        scoreLabel.text = score.formatted()
    }

    func updateCoins(_ coins: Int) {
        coinLabel.text = "\(coins)"
    }

    func updateMultiplier(_ multiplier: Int) {
        multiplierLabel.text = "x\(multiplier)"

        if multiplier > 1 {
            multiplierLabel.textColor = UIColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 1.0)

            UIView.animate(withDuration: 0.15, animations: {
                self.multiplierLabel.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            }) { _ in
                UIView.animate(withDuration: 0.15) {
                    self.multiplierLabel.transform = .identity
                }
            }
        } else {
            multiplierLabel.textColor = UIColor(red: 0.4, green: 1.0, blue: 0.4, alpha: 1.0)
        }
    }

    func updateSpeed(_ speed: Float) {
        let kmh = Int(speed * 3.6) // Convert m/s to km/h for display
        speedLabel.text = "\(kmh) km/h"
    }

    func showTrickScore(_ points: Int) {
        trickScoreLabel.text = "+\(points)"
        trickScoreLabel.alpha = 1
        trickScoreLabel.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)

        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8) {
            self.trickScoreLabel.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }

        UIView.animate(withDuration: 0.5, delay: 0.8, options: .curveEaseIn) {
            self.trickScoreLabel.alpha = 0
            self.trickScoreLabel.transform = CGAffineTransform(translationX: 0, y: -30)
        }
    }
}
