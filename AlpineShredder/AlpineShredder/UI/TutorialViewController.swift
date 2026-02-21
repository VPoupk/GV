import UIKit

/// Multi-page tutorial teaching controls and gameplay mechanics
class TutorialViewController: UIViewController {

    private let scrollView = UIScrollView()
    private let pageControl = UIPageControl()
    private var pages: [TutorialPage] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        buildPages()
        setupUI()
    }

    override var prefersStatusBarHidden: Bool { true }

    // MARK: - Tutorial Content

    private func buildPages() {
        pages = [
            TutorialPage(
                title: "WELCOME TO\nALPINE SHREDDER",
                icon: "mountain.2.fill",
                items: [
                    "Race down procedurally generated mountains",
                    "Dodge obstacles, collect coins, and score big",
                    "Choose between snowboarding and skiing",
                    "Customize your character and equipment",
                ]
            ),
            TutorialPage(
                title: "BASIC CONTROLS",
                icon: "hand.draw.fill",
                items: [
                    "SWIPE LEFT  — Steer left across the slope",
                    "SWIPE RIGHT — Steer right across the slope",
                    "SWIPE UP    — Jump over obstacles",
                    "SWIPE DOWN  — Tuck for speed (on ground)",
                    "SWIPE DOWN  — Slam down fast (in air)",
                ]
            ),
            TutorialPage(
                title: "SCORING",
                icon: "star.fill",
                items: [
                    "Distance traveled earns base points",
                    "Gold coins are worth 10 points each",
                    "Tricks in the air earn bonus points",
                    "Collect multiplier power-ups for 2x-5x score",
                    "The further you go, the higher your score",
                ]
            ),
            TutorialPage(
                title: "TRICKS & JUMPS",
                icon: "figure.snowboarding",
                items: [
                    "Swipe UP to jump — you jump higher off ramps",
                    "Move sideways while jumping for grab tricks",
                    "Chain tricks together for combo bonuses",
                    "Swipe DOWN while airborne to slam for style",
                    "Land cleanly to bank your trick points",
                ]
            ),
            TutorialPage(
                title: "COLLECTIBLES",
                icon: "gift.fill",
                items: [
                    "GOLD COINS    — +10 score each",
                    "BLUE ARROWS   — Speed boost",
                    "GREEN SPHERE  — Shield (absorb one hit)",
                    "PINK STAR     — Score multiplier +1",
                    "Items float and glow — hard to miss!",
                ]
            ),
            TutorialPage(
                title: "OBSTACLES",
                icon: "exclamationmark.triangle.fill",
                items: [
                    "PINE TREES  — Tall and common, dodge around them",
                    "ROCKS       — Low profile, easy to miss at speed",
                    "SNOWMEN     — Classic hazard on the slopes",
                    "CABINS      — Large, give them wide berth",
                    "RAMPS       — Ride over these to jump and trick!",
                ]
            ),
            TutorialPage(
                title: "RESORTS",
                icon: "map.fill",
                items: [
                    "Each resort has unique terrain and difficulty",
                    "Green Circle — Wide, gentle slopes for beginners",
                    "Blue Square  — Moderate terrain with more obstacles",
                    "Black Diamond — Steep, narrow, and fast",
                    "Double Black — Extreme conditions, expert only",
                ]
            ),
            TutorialPage(
                title: "TIPS & TRICKS",
                icon: "lightbulb.fill",
                items: [
                    "Start on Alpine Meadows to learn the ropes",
                    "Tuck (swipe down) on straight sections for speed",
                    "Use ramps to fly over clusters of obstacles",
                    "Match your equipment to your play style",
                    "Check the leaderboard to beat your best runs",
                ]
            ),
        ]
    }

    // MARK: - UI

    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.1, green: 0.13, blue: 0.25, alpha: 1.0)

        // Close button
        let closeButton = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
        closeButton.setImage(UIImage(systemName: "xmark", withConfiguration: config), for: .normal)
        closeButton.tintColor = .white
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(closeButton)

        let headerLabel = UILabel()
        headerLabel.text = "HOW TO PLAY"
        headerLabel.font = UIFont.systemFont(ofSize: 22, weight: .black)
        headerLabel.textColor = .white
        headerLabel.textAlignment = .center
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerLabel)

        // Scroll view (horizontal paging)
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        // Page control
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = UIColor(white: 1.0, alpha: 0.3)
        pageControl.currentPageIndicatorTintColor = .white
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageControl)

        NSLayoutConstraint.activate([
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),

            headerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            headerLabel.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor),

            scrollView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: pageControl.topAnchor, constant: -10),

            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
        ])

        // Build page views
        DispatchQueue.main.async { self.layoutPages() }
    }

    private func layoutPages() {
        let pageWidth = scrollView.bounds.width
        let pageHeight = scrollView.bounds.height

        for (index, page) in pages.enumerated() {
            let pageView = createPageView(page: page)
            pageView.frame = CGRect(x: CGFloat(index) * pageWidth, y: 0, width: pageWidth, height: pageHeight)
            scrollView.addSubview(pageView)
        }

        scrollView.contentSize = CGSize(width: pageWidth * CGFloat(pages.count), height: pageHeight)
    }

    private func createPageView(page: TutorialPage) -> UIView {
        let container = UIView()

        let iconConfig = UIImage.SymbolConfiguration(pointSize: 48, weight: .medium)
        let iconView = UIImageView(image: UIImage(systemName: page.icon, withConfiguration: iconConfig))
        iconView.tintColor = UIColor(red: 0.3, green: 0.7, blue: 1.0, alpha: 1.0)
        iconView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(iconView)

        let titleLabel = UILabel()
        titleLabel.text = page.title
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .black)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(titleLabel)

        let itemsStack = UIStackView()
        itemsStack.axis = .vertical
        itemsStack.spacing = 14
        itemsStack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(itemsStack)

        for item in page.items {
            let itemLabel = UILabel()
            itemLabel.text = item
            itemLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
            itemLabel.textColor = UIColor(white: 1.0, alpha: 0.8)
            itemLabel.numberOfLines = 2
            itemsStack.addArrangedSubview(itemLabel)
        }

        NSLayoutConstraint.activate([
            iconView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            iconView.topAnchor.constraint(equalTo: container.topAnchor, constant: 30),

            titleLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 30),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -30),

            itemsStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            itemsStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 35),
            itemsStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -35),
        ])

        return container
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }
}

extension TutorialViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = Int(round(scrollView.contentOffset.x / scrollView.bounds.width))
        pageControl.currentPage = page
    }
}

struct TutorialPage {
    let title: String
    let icon: String
    let items: [String]
}
