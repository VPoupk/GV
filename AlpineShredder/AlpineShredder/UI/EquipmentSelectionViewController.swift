import UIKit
import SceneKit

/// Equipment selection screen for choosing snowboards or skis
class EquipmentSelectionViewController: UIViewController {

    private let previewView = SCNView()
    private let tableView = UITableView(frame: .zero, style: .plain)
    private var equipment: [Equipment] = []
    private var selectedIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        let isSnowboarder = GameManager.shared.selectedCharacter == .snowboarder
        equipment = isSnowboarder ? SnowboardCatalog.all : SkiCatalog.all
        selectedIndex = isSnowboarder ? EquipmentManager.shared.selectedBoardIndex : EquipmentManager.shared.selectedSkiIndex

        setupUI()
        setupPreview()
        updatePreview(for: equipment[selectedIndex % equipment.count])
    }

    override var prefersStatusBarHidden: Bool { true }

    // MARK: - UI

    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.1, green: 0.13, blue: 0.25, alpha: 1.0)

        let isSnowboarder = GameManager.shared.selectedCharacter == .snowboarder

        // Header
        let backButton = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
        backButton.setImage(UIImage(systemName: "chevron.left", withConfiguration: config), for: .normal)
        backButton.tintColor = .white
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backButton)

        let titleLabel = UILabel()
        titleLabel.text = isSnowboarder ? "SNOWBOARDS" : "SKIS"
        titleLabel.font = UIFont.systemFont(ofSize: 22, weight: .black)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        // 3D Preview
        previewView.backgroundColor = .clear
        previewView.allowsCameraControl = false
        previewView.isUserInteractionEnabled = false
        previewView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(previewView)

        // Table
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(EquipmentCell.self, forCellReuseIdentifier: "EquipmentCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),

            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),

            previewView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            previewView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            previewView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            previewView.heightAnchor.constraint(equalToConstant: 180),

            tableView.topAnchor.constraint(equalTo: previewView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    // MARK: - 3D Preview

    private func setupPreview() {
        let scene = SCNScene()
        scene.background.contents = UIColor(red: 0.12, green: 0.15, blue: 0.28, alpha: 1.0)

        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .directional
        lightNode.light?.intensity = 1000
        lightNode.eulerAngles = SCNVector3(-Float.pi / 4, Float.pi / 6, 0)
        scene.rootNode.addChildNode(lightNode)

        let ambientNode = SCNNode()
        ambientNode.light = SCNLight()
        ambientNode.light?.type = .ambient
        ambientNode.light?.intensity = 400
        scene.rootNode.addChildNode(ambientNode)

        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 0.3, 2)
        scene.rootNode.addChildNode(cameraNode)

        previewView.scene = scene
    }

    private func updatePreview(for equip: Equipment) {
        guard let scene = previewView.scene else { return }

        // Remove old preview
        scene.rootNode.childNodes.filter { $0.name == "equipment" }.forEach { $0.removeFromParentNode() }

        let isSnowboarder = GameManager.shared.selectedCharacter == .snowboarder
        let node = SCNNode()
        node.name = "equipment"

        if isSnowboarder {
            // Snowboard preview
            let boardGeometry = SCNBox(width: 0.35, height: 0.06, length: 1.6, chamferRadius: 0.03)
            let boardMaterial = SCNMaterial()
            boardMaterial.diffuse.contents = equip.color
            boardMaterial.specular.contents = UIColor.white
            boardMaterial.roughness.contents = NSNumber(value: 0.2)
            boardGeometry.materials = [boardMaterial]
            let boardNode = SCNNode(geometry: boardGeometry)
            node.addChildNode(boardNode)

            // Accent stripe
            let stripeGeometry = SCNBox(width: 0.32, height: 0.065, length: 0.15, chamferRadius: 0.01)
            let stripeMaterial = SCNMaterial()
            stripeMaterial.diffuse.contents = equip.accentColor
            stripeGeometry.materials = [stripeMaterial]
            let stripeNode = SCNNode(geometry: stripeGeometry)
            stripeNode.position = SCNVector3(0, 0, 0.3)
            node.addChildNode(stripeNode)
        } else {
            // Ski pair preview
            for side in [-0.12, 0.12] as [Float] {
                let skiGeometry = SCNBox(width: 0.1, height: 0.04, length: 1.8, chamferRadius: 0.02)
                let skiMaterial = SCNMaterial()
                skiMaterial.diffuse.contents = equip.color
                skiMaterial.specular.contents = UIColor.white
                skiGeometry.materials = [skiMaterial]
                let skiNode = SCNNode(geometry: skiGeometry)
                skiNode.position = SCNVector3(side, 0, 0)
                node.addChildNode(skiNode)

                // Accent tip
                let tipGeometry = SCNBox(width: 0.09, height: 0.045, length: 0.2, chamferRadius: 0.01)
                let tipMaterial = SCNMaterial()
                tipMaterial.diffuse.contents = equip.accentColor
                tipGeometry.materials = [tipMaterial]
                let tipNode = SCNNode(geometry: tipGeometry)
                tipNode.position = SCNVector3(side, 0, -0.7)
                node.addChildNode(tipNode)
            }
        }

        node.runAction(SCNAction.repeatForever(
            SCNAction.rotateBy(x: 0, y: CGFloat.pi * 2, z: 0, duration: 6)
        ))

        scene.rootNode.addChildNode(node)
    }

    // MARK: - Actions

    @objc private func backTapped() {
        dismiss(animated: true)
    }
}

// MARK: - Table View

extension EquipmentSelectionViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return equipment.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EquipmentCell", for: indexPath) as! EquipmentCell
        let equip = equipment[indexPath.row]
        let isSelected = indexPath.row == selectedIndex
        cell.configure(with: equip, isSelected: isSelected)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        let isSnowboarder = GameManager.shared.selectedCharacter == .snowboarder
        if isSnowboarder {
            EquipmentManager.shared.selectedBoardIndex = indexPath.row
        } else {
            EquipmentManager.shared.selectedSkiIndex = indexPath.row
        }

        updatePreview(for: equipment[indexPath.row])
        tableView.reloadData()
        AudioManager.shared.playSound(.menuSelect)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}

// MARK: - Equipment Cell

class EquipmentCell: UITableViewCell {
    private let cardView = UIView()
    private let colorDot = UIView()
    private let nameLabel = UILabel()
    private let brandLabel = UILabel()
    private let descLabel = UILabel()
    private let statsStack = UIStackView()
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
        cardView.layer.cornerRadius = 12
        cardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cardView)

        colorDot.layer.cornerRadius = 16
        colorDot.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(colorDot)

        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        nameLabel.textColor = .white
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(nameLabel)

        brandLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        brandLabel.textColor = UIColor(white: 1.0, alpha: 0.5)
        brandLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(brandLabel)

        descLabel.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        descLabel.textColor = UIColor(white: 1.0, alpha: 0.4)
        descLabel.numberOfLines = 2
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(descLabel)

        let checkConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .bold)
        checkmark.image = UIImage(systemName: "checkmark.circle.fill", withConfiguration: checkConfig)
        checkmark.tintColor = UIColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 1.0)
        checkmark.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(checkmark)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),

            colorDot.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            colorDot.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            colorDot.widthAnchor.constraint(equalToConstant: 32),
            colorDot.heightAnchor.constraint(equalToConstant: 32),

            nameLabel.leadingAnchor.constraint(equalTo: colorDot.trailingAnchor, constant: 12),
            nameLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),

            brandLabel.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 8),
            brandLabel.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),

            descLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            descLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            descLabel.trailingAnchor.constraint(equalTo: checkmark.leadingAnchor, constant: -8),

            checkmark.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),
            checkmark.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
        ])
    }

    func configure(with equip: Equipment, isSelected: Bool) {
        colorDot.backgroundColor = equip.color
        nameLabel.text = equip.name
        brandLabel.text = equip.brand
        descLabel.text = equip.description
        checkmark.isHidden = !isSelected
        cardView.layer.borderWidth = isSelected ? 2 : 0
        cardView.layer.borderColor = UIColor(red: 0.3, green: 0.7, blue: 1.0, alpha: 1.0).cgColor
    }
}
