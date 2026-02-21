import UIKit
import SceneKit

/// Full character customization: gender, jacket, pants, boots, helmet, gloves, goggles
class CharacterCustomizationViewController: UIViewController {

    private let previewView = SCNView()
    private let scrollView = UIScrollView()
    private let optionsStack = UIStackView()
    private var previewBodyNode: SCNNode?

    private let appearance = CharacterAppearance.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupPreview()
        buildOptions()
    }

    override var prefersStatusBarHidden: Bool { true }

    // MARK: - 3D Preview

    private func setupPreview() {
        let scene = SCNScene()
        scene.background.contents = UIColor(red: 0.12, green: 0.15, blue: 0.28, alpha: 1.0)

        let character = buildCharacterPreview()
        previewBodyNode = character
        scene.rootNode.addChildNode(character)

        // Slow rotation
        character.runAction(SCNAction.repeatForever(
            SCNAction.rotateBy(x: 0, y: CGFloat.pi * 2, z: 0, duration: 8)
        ))

        // Lighting
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
        cameraNode.position = SCNVector3(0, 0.7, 2.5)
        cameraNode.eulerAngles = SCNVector3(-Float.pi / 20, 0, 0)
        scene.rootNode.addChildNode(cameraNode)

        previewView.scene = scene
        previewView.allowsCameraControl = false
        previewView.isUserInteractionEnabled = false
    }

    private func buildCharacterPreview() -> SCNNode {
        let root = SCNNode()
        let scale = appearance.gender.bodyScale

        // Helmet
        let helmetGeometry = SCNSphere(radius: 0.16)
        let helmetMaterial = SCNMaterial()
        helmetMaterial.diffuse.contents = appearance.helmetColor
        helmetMaterial.specular.contents = UIColor.white
        helmetGeometry.materials = [helmetMaterial]
        let helmetNode = SCNNode(geometry: helmetGeometry)
        helmetNode.name = "helmet"
        helmetNode.position = SCNVector3(0, 1.05, 0)
        helmetNode.scale = SCNVector3(1, 0.85, 1)
        root.addChildNode(helmetNode)

        // Head/face
        let headGeometry = SCNSphere(radius: 0.12)
        let headMaterial = SCNMaterial()
        headMaterial.diffuse.contents = UIColor(red: 0.96, green: 0.8, blue: 0.7, alpha: 1.0)
        headGeometry.materials = [headMaterial]
        let headNode = SCNNode(geometry: headGeometry)
        headNode.name = "head"
        headNode.position = SCNVector3(0, 1.0, 0.04)
        headNode.scale = SCNVector3(
            appearance.gender.headScale,
            appearance.gender.headScale,
            appearance.gender.headScale
        )
        root.addChildNode(headNode)

        // Goggles
        let goggleGeometry = SCNBox(width: 0.22, height: 0.08, length: 0.08, chamferRadius: 0.03)
        let goggleMaterial = SCNMaterial()
        goggleMaterial.diffuse.contents = appearance.goggleColor
        goggleMaterial.specular.contents = UIColor.white
        goggleGeometry.materials = [goggleMaterial]
        let goggleNode = SCNNode(geometry: goggleGeometry)
        goggleNode.name = "goggles"
        goggleNode.position = SCNVector3(0, 1.03, 0.12)
        root.addChildNode(goggleNode)

        // Jacket/torso
        let torsoGeometry = SCNCapsule(capRadius: CGFloat(0.15 * scale.width), height: CGFloat(0.6 * scale.height))
        let torsoMaterial = SCNMaterial()
        torsoMaterial.diffuse.contents = appearance.jacketColor
        torsoGeometry.materials = [torsoMaterial]
        let torsoNode = SCNNode(geometry: torsoGeometry)
        torsoNode.name = "jacket"
        torsoNode.position = SCNVector3(0, 0.55, 0)
        root.addChildNode(torsoNode)

        // Arms with gloves
        for side in [-1.0, 1.0] as [Float] {
            // Arm (jacket color)
            let armGeometry = SCNCapsule(capRadius: 0.06, height: 0.35)
            let armMaterial = SCNMaterial()
            armMaterial.diffuse.contents = appearance.jacketColor
            armGeometry.materials = [armMaterial]
            let armNode = SCNNode(geometry: armGeometry)
            armNode.name = "arm"
            armNode.position = SCNVector3(side * 0.22, 0.55, 0)
            armNode.eulerAngles.z = side * 0.3
            root.addChildNode(armNode)

            // Glove
            let gloveGeometry = SCNSphere(radius: 0.06)
            let gloveMaterial = SCNMaterial()
            gloveMaterial.diffuse.contents = appearance.gloveColor
            gloveGeometry.materials = [gloveMaterial]
            let gloveNode = SCNNode(geometry: gloveGeometry)
            gloveNode.name = "glove"
            gloveNode.position = SCNVector3(
                side * 0.27,
                0.35,
                0
            )
            root.addChildNode(gloveNode)
        }

        // Pants/legs
        for side in [-1.0, 1.0] as [Float] {
            let legGeometry = SCNCapsule(capRadius: 0.07, height: 0.4)
            let legMaterial = SCNMaterial()
            legMaterial.diffuse.contents = appearance.pantsColor
            legGeometry.materials = [legMaterial]
            let legNode = SCNNode(geometry: legGeometry)
            legNode.name = "pants"
            legNode.position = SCNVector3(side * 0.1, 0.22, 0)
            root.addChildNode(legNode)
        }

        // Boots
        for side in [-1.0, 1.0] as [Float] {
            let bootGeometry = SCNBox(width: 0.1, height: 0.08, length: 0.16, chamferRadius: 0.02)
            let bootMaterial = SCNMaterial()
            bootMaterial.diffuse.contents = appearance.bootColor
            bootGeometry.materials = [bootMaterial]
            let bootNode = SCNNode(geometry: bootGeometry)
            bootNode.name = "boot"
            bootNode.position = SCNVector3(side * 0.1, 0.04, 0.02)
            root.addChildNode(bootNode)
        }

        return root
    }

    private func refreshPreview() {
        previewBodyNode?.removeFromParentNode()
        guard let scene = previewView.scene else { return }
        let character = buildCharacterPreview()
        previewBodyNode = character
        character.runAction(SCNAction.repeatForever(
            SCNAction.rotateBy(x: 0, y: CGFloat.pi * 2, z: 0, duration: 8)
        ))
        scene.rootNode.addChildNode(character)
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
        titleLabel.text = "CHARACTER"
        titleLabel.font = UIFont.systemFont(ofSize: 22, weight: .black)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        // 3D Preview area
        previewView.backgroundColor = .clear
        previewView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(previewView)

        // Options scroll
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        optionsStack.axis = .vertical
        optionsStack.spacing = 16
        optionsStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(optionsStack)

        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),

            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),

            previewView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            previewView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            previewView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            previewView.heightAnchor.constraint(equalToConstant: 250),

            scrollView.topAnchor.constraint(equalTo: previewView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            optionsStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 12),
            optionsStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            optionsStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            optionsStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -30),
            optionsStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40),
        ])
    }

    private func buildOptions() {
        // Gender
        addSegmentedOption(title: "Gender", options: CharacterAppearance.Gender.allCases.map { $0.rawValue }, selectedIndex: CharacterAppearance.Gender.allCases.firstIndex(of: appearance.gender) ?? 0) { [weak self] index in
            self?.appearance.gender = CharacterAppearance.Gender.allCases[index]
            self?.refreshPreview()
        }

        // Jacket
        addColorPicker(title: "Jacket", colors: CharacterAppearance.jacketColors, selectedIndex: appearance.jacketColorIndex) { [weak self] index in
            self?.appearance.jacketColorIndex = index
            self?.refreshPreview()
        }

        // Pants
        addColorPicker(title: "Pants", colors: CharacterAppearance.pantsColors, selectedIndex: appearance.pantsColorIndex) { [weak self] index in
            self?.appearance.pantsColorIndex = index
            self?.refreshPreview()
        }

        // Boots
        addColorPicker(title: "Boots", colors: CharacterAppearance.bootColors, selectedIndex: appearance.bootColorIndex) { [weak self] index in
            self?.appearance.bootColorIndex = index
            self?.refreshPreview()
        }

        // Helmet
        addColorPicker(title: "Helmet", colors: CharacterAppearance.helmetColors, selectedIndex: appearance.helmetColorIndex) { [weak self] index in
            self?.appearance.helmetColorIndex = index
            self?.refreshPreview()
        }

        // Gloves
        addColorPicker(title: "Gloves", colors: CharacterAppearance.gloveColors, selectedIndex: appearance.gloveColorIndex) { [weak self] index in
            self?.appearance.gloveColorIndex = index
            self?.refreshPreview()
        }

        // Goggles
        addColorPicker(title: "Goggles", colors: CharacterAppearance.goggleColors, selectedIndex: appearance.goggleColorIndex) { [weak self] index in
            self?.appearance.goggleColorIndex = index
            self?.refreshPreview()
        }
    }

    // MARK: - Option Builders

    private func addSegmentedOption(title: String, options: [String], selectedIndex: Int, onChange: @escaping (Int) -> Void) {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = title.uppercased()
        label.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        label.textColor = UIColor(white: 1.0, alpha: 0.6)
        label.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)

        let segmented = UISegmentedControl(items: options)
        segmented.selectedSegmentIndex = selectedIndex
        segmented.backgroundColor = UIColor(white: 1.0, alpha: 0.1)
        segmented.selectedSegmentTintColor = UIColor(red: 0.3, green: 0.5, blue: 0.9, alpha: 1.0)
        segmented.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        segmented.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        segmented.translatesAutoresizingMaskIntoConstraints = false

        let callback = onChange
        let action = UIAction { [weak segmented] _ in
            guard let seg = segmented else { return }
            callback(seg.selectedSegmentIndex)
        }
        segmented.addAction(action, for: .valueChanged)
        container.addSubview(segmented)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor),

            segmented.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 6),
            segmented.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            segmented.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            segmented.heightAnchor.constraint(equalToConstant: 36),
            segmented.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])

        optionsStack.addArrangedSubview(container)
    }

    private func addColorPicker(title: String, colors: [CharacterAppearance.ColorOption], selectedIndex: Int, onChange: @escaping (Int) -> Void) {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = title.uppercased()
        label.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        label.textColor = UIColor(white: 1.0, alpha: 0.6)
        label.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)

        let colorScroll = UIScrollView()
        colorScroll.showsHorizontalScrollIndicator = false
        colorScroll.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(colorScroll)

        let colorStack = UIStackView()
        colorStack.axis = .horizontal
        colorStack.spacing = 10
        colorStack.translatesAutoresizingMaskIntoConstraints = false
        colorScroll.addSubview(colorStack)

        for (index, colorOption) in colors.enumerated() {
            let swatch = UIButton(type: .custom)
            swatch.backgroundColor = colorOption.color
            swatch.layer.cornerRadius = 20
            swatch.layer.borderWidth = index == selectedIndex ? 3 : 0
            swatch.layer.borderColor = UIColor.white.cgColor
            swatch.tag = index
            swatch.translatesAutoresizingMaskIntoConstraints = false

            let callback = onChange
            let action = UIAction { [weak colorStack] _ in
                callback(index)
                // Update selection visuals
                colorStack?.arrangedSubviews.forEach { view in
                    (view as? UIButton)?.layer.borderWidth = view.tag == index ? 3 : 0
                }
            }
            swatch.addAction(action, for: .touchUpInside)

            NSLayoutConstraint.activate([
                swatch.widthAnchor.constraint(equalToConstant: 40),
                swatch.heightAnchor.constraint(equalToConstant: 40),
            ])

            colorStack.addArrangedSubview(swatch)
        }

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor),

            colorScroll.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 8),
            colorScroll.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            colorScroll.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            colorScroll.heightAnchor.constraint(equalToConstant: 44),
            colorScroll.bottomAnchor.constraint(equalTo: container.bottomAnchor),

            colorStack.topAnchor.constraint(equalTo: colorScroll.topAnchor),
            colorStack.leadingAnchor.constraint(equalTo: colorScroll.leadingAnchor),
            colorStack.trailingAnchor.constraint(equalTo: colorScroll.trailingAnchor),
            colorStack.bottomAnchor.constraint(equalTo: colorScroll.bottomAnchor),
            colorStack.heightAnchor.constraint(equalTo: colorScroll.heightAnchor),
        ])

        optionsStack.addArrangedSubview(container)
    }

    // MARK: - Actions

    @objc private func backTapped() {
        dismiss(animated: true)
    }
}
