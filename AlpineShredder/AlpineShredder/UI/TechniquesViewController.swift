import UIKit

/// Guide to real-world snowboarding and skiing techniques
class TechniquesViewController: UIViewController {

    private let segmented = UISegmentedControl(items: ["Snowboard", "Ski"])
    private let tableView = UITableView(frame: .zero, style: .grouped)

    private var snowboardTechniques: [TechniqueSection] = []
    private var skiTechniques: [TechniqueSection] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        buildTechniques()
        setupUI()
    }

    override var prefersStatusBarHidden: Bool { true }

    // MARK: - Technique Data

    private func buildTechniques() {
        snowboardTechniques = [
            TechniqueSection(title: "Beginner", techniques: [
                Technique(
                    name: "Heel-Side Turn",
                    difficulty: "Beginner",
                    description: "Shift your weight to your heels and press your toes up. Your board will turn across the fall line. This is the foundation of snowboard control."
                ),
                Technique(
                    name: "Toe-Side Turn",
                    difficulty: "Beginner",
                    description: "Press your toes down and lift your heels. Lean forward slightly over your front foot to initiate the turn. Keep your knees bent."
                ),
                Technique(
                    name: "Falling Leaf",
                    difficulty: "Beginner",
                    description: "Slide back and forth across the slope on your heel edge without turning. Great for controlling speed on steep terrain while learning."
                ),
                Technique(
                    name: "J-Turn",
                    difficulty: "Beginner",
                    description: "Start pointing downhill, then make a single turn to stop. The path traces a J shape. Practice on both heel and toe side."
                ),
            ]),
            TechniqueSection(title: "Intermediate", techniques: [
                Technique(
                    name: "Linked Turns (S-Turns)",
                    difficulty: "Intermediate",
                    description: "Smoothly connect heel-side and toe-side turns in a flowing S pattern. Shift weight from edge to edge through a flat base transition."
                ),
                Technique(
                    name: "Carving",
                    difficulty: "Intermediate",
                    description: "Tilt the board on edge and let the sidecut radius guide your turn. No skidding — just clean arcs cut into the snow. Requires speed and commitment."
                ),
                Technique(
                    name: "Switch Riding",
                    difficulty: "Intermediate",
                    description: "Ride with your non-dominant foot forward. Essential for freestyle. Start on gentle terrain and practice basic turns in switch stance."
                ),
                Technique(
                    name: "Ollie",
                    difficulty: "Intermediate",
                    description: "Spring off the tail of the board to get air on flat ground. Shift weight to the back foot, then pop up and level out. Foundation of all jump tricks."
                ),
            ]),
            TechniqueSection(title: "Advanced", techniques: [
                Technique(
                    name: "180 Spin",
                    difficulty: "Advanced",
                    description: "Jump and rotate 180 degrees to land switch. Wind up with your shoulders before takeoff and spot your landing. Can be frontside or backside."
                ),
                Technique(
                    name: "360 Spin",
                    difficulty: "Advanced",
                    description: "Full rotation in the air. Requires more height and stronger wind-up. Keep your body compact and spot the landing through the rotation."
                ),
                Technique(
                    name: "Indy Grab",
                    difficulty: "Advanced",
                    description: "While airborne, reach down with your back hand and grab the toe edge between the bindings. A classic grab that looks and feels great."
                ),
                Technique(
                    name: "Method Grab",
                    difficulty: "Advanced",
                    description: "The iconic snowboard move. Grab the heel edge with your front hand while tweaking the board behind you. Requires big air and flexibility."
                ),
                Technique(
                    name: "Butter / Press",
                    difficulty: "Advanced",
                    description: "Balance on the nose or tail of the board while sliding. Requires excellent balance and edge control. Can be combined with spins for style."
                ),
            ]),
        ]

        skiTechniques = [
            TechniqueSection(title: "Beginner", techniques: [
                Technique(
                    name: "Snowplow (Pizza)",
                    difficulty: "Beginner",
                    description: "Point ski tips together and push tails apart to form a wedge. Apply pressure to the inside edges to control speed. The first technique every skier learns."
                ),
                Technique(
                    name: "Snowplow Turn",
                    difficulty: "Beginner",
                    description: "From a snowplow position, shift weight to one ski to turn. Press on the right ski to turn left, and vice versa. Maintain the wedge throughout."
                ),
                Technique(
                    name: "Side-Stepping",
                    difficulty: "Beginner",
                    description: "Walk sideways up the slope by stepping one ski at a time with edges dug in. Essential for getting uphill when there's no lift."
                ),
                Technique(
                    name: "Herringbone",
                    difficulty: "Beginner",
                    description: "Walk uphill with ski tips pointed outward in a V shape, pressing on inside edges. Leaves a herringbone pattern in the snow."
                ),
            ]),
            TechniqueSection(title: "Intermediate", techniques: [
                Technique(
                    name: "Parallel Turns",
                    difficulty: "Intermediate",
                    description: "Keep skis parallel throughout the turn instead of in a wedge. Initiate turns by shifting weight and rolling knees into the turn. The goal of every improving skier."
                ),
                Technique(
                    name: "Pole Planting",
                    difficulty: "Intermediate",
                    description: "Reach downhill and plant your pole at the start of each turn. Creates rhythm and timing. The pole touch triggers weight transfer and turn initiation."
                ),
                Technique(
                    name: "Short Turns",
                    difficulty: "Intermediate",
                    description: "Quick, rhythmic parallel turns with a short radius. Great for controlling speed on steep terrain. Requires quick edge-to-edge transitions."
                ),
                Technique(
                    name: "Hockey Stop",
                    difficulty: "Intermediate",
                    description: "Rapidly turn both skis perpendicular to the fall line while skidding to a stop. Dig edges in hard. The fastest way to stop on skis."
                ),
            ]),
            TechniqueSection(title: "Advanced", techniques: [
                Technique(
                    name: "Carving",
                    difficulty: "Advanced",
                    description: "Pure edge-to-edge skiing with no skidding. Roll the skis onto edge and let the sidecut do the work. Leaves thin, clean tracks in the snow."
                ),
                Technique(
                    name: "Mogul Skiing",
                    difficulty: "Advanced",
                    description: "Navigate bumpy mogul fields by absorbing bumps with your legs, keeping upper body quiet, and making quick turns in the troughs between bumps."
                ),
                Technique(
                    name: "Spread Eagle",
                    difficulty: "Advanced",
                    description: "A classic aerial move. Jump off a natural feature or kicker and spread arms and legs wide like a star. Land with knees bent to absorb impact."
                ),
                Technique(
                    name: "Daffy",
                    difficulty: "Advanced",
                    description: "While airborne, kick one ski forward and one back in a split position. A stylish aerial trick that requires good balance and air awareness."
                ),
                Technique(
                    name: "Powder Skiing",
                    difficulty: "Advanced",
                    description: "Ski through deep, ungroomed snow. Keep weight centered or slightly back, use wider stance, and make smooth, rounded turns. Let the snow support you."
                ),
            ]),
        ]
    }

    // MARK: - UI

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
        titleLabel.text = "TECHNIQUES"
        titleLabel.font = UIFont.systemFont(ofSize: 22, weight: .black)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        // Segmented control
        segmented.selectedSegmentIndex = GameManager.shared.selectedCharacter == .snowboarder ? 0 : 1
        segmented.backgroundColor = UIColor(white: 1.0, alpha: 0.1)
        segmented.selectedSegmentTintColor = UIColor(red: 0.3, green: 0.5, blue: 0.9, alpha: 1.0)
        segmented.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        segmented.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        segmented.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        segmented.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(segmented)

        // Table
        tableView.backgroundColor = .clear
        tableView.separatorColor = UIColor(white: 1.0, alpha: 0.1)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TechniqueCell.self, forCellReuseIdentifier: "TechniqueCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),

            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),

            segmented.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            segmented.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            segmented.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            tableView.topAnchor.constraint(equalTo: segmented.bottomAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private var currentTechniques: [TechniqueSection] {
        return segmented.selectedSegmentIndex == 0 ? snowboardTechniques : skiTechniques
    }

    @objc private func segmentChanged() { tableView.reloadData() }
    @objc private func backTapped() { dismiss(animated: true) }
}

extension TechniquesViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return currentTechniques.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return currentTechniques[section].title
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textColor = UIColor(red: 0.3, green: 0.7, blue: 1.0, alpha: 1.0)
            header.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentTechniques[section].techniques.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TechniqueCell", for: indexPath) as! TechniqueCell
        let technique = currentTechniques[indexPath.section].techniques[indexPath.row]
        cell.configure(with: technique)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

// MARK: - Data Models

struct TechniqueSection {
    let title: String
    let techniques: [Technique]
}

struct Technique {
    let name: String
    let difficulty: String
    let description: String
}

// MARK: - Technique Cell

class TechniqueCell: UITableViewCell {
    private let nameLabel = UILabel()
    private let diffLabel = UILabel()
    private let descLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none

        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        nameLabel.textColor = .white
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLabel)

        diffLabel.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        diffLabel.textColor = UIColor(white: 1.0, alpha: 0.5)
        diffLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(diffLabel)

        descLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        descLabel.textColor = UIColor(white: 1.0, alpha: 0.6)
        descLabel.numberOfLines = 0
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(descLabel)

        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            diffLabel.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 8),
            diffLabel.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),

            descLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            descLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            descLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            descLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(with technique: Technique) {
        nameLabel.text = technique.name
        diffLabel.text = technique.difficulty
        descLabel.text = technique.description
    }
}
