import SceneKit

/// Generates procedural snowy mountain terrain chunks as the player moves downhill
class TerrainGenerator {

    private let terrainRoot: SCNNode
    private var chunks: [TerrainChunk] = []
    private var nextChunkZ: Float = GameConstants.terrainStartZ
    private let chunkLength: Float = GameConstants.terrainChunkLength
    private var chunkWidth: Float

    // Terrain variation
    private var currentSlope: Float = GameConstants.baseSlopeAngle
    private var noiseOffset: Float = 0

    // Resort-themed colors
    private let snowColor: UIColor
    private let mountainColor: UIColor

    init(terrainRoot: SCNNode) {
        self.terrainRoot = terrainRoot
        let resort = ResortManager.shared.currentResort
        self.snowColor = resort.snowColor
        self.mountainColor = resort.mountainColor
        self.chunkWidth = GameConstants.terrainWidth * resort.widthMultiplier
    }

    // MARK: - Initial Generation

    func generateInitialTerrain() {
        for _ in 0..<GameConstants.initialChunkCount {
            addChunk()
        }
    }

    // MARK: - Update

    func update(playerZ: Float) {
        // Generate new chunks ahead of the player
        while nextChunkZ > playerZ - GameConstants.terrainLookAhead {
            addChunk()
        }

        // Remove chunks far behind the player
        chunks.removeAll { chunk in
            if chunk.endZ > playerZ + GameConstants.terrainCleanupDistance {
                chunk.node.removeFromParentNode()
                return true
            }
            return false
        }
    }

    // MARK: - Chunk Generation

    private func addChunk() {
        let chunk = generateChunk(atZ: nextChunkZ)
        terrainRoot.addChildNode(chunk.node)
        chunks.append(chunk)
        nextChunkZ -= chunkLength
    }

    private func generateChunk(atZ z: Float) -> TerrainChunk {
        let node = SCNNode()

        // Main snow surface
        let snowPlane = createSnowSurface()
        node.addChildNode(snowPlane)

        // Side mountains / walls
        addSideMountains(to: node)

        // Moguls and bumps for variation
        addTerrainDetails(to: node, z: z)

        // Trail markers for immersion
        addTrailMarkers(to: node)

        node.position = SCNVector3(0, 0, z - chunkLength / 2)

        // Slight slope variation
        noiseOffset += 0.3
        let slopeVariation = sin(noiseOffset) * 0.02
        node.eulerAngles.x = -(currentSlope + slopeVariation)

        return TerrainChunk(
            node: node,
            startZ: z,
            endZ: z - chunkLength
        )
    }

    private func createSnowSurface() -> SCNNode {
        let geometry = SCNPlane(width: CGFloat(chunkWidth), height: CGFloat(chunkLength))
        geometry.widthSegmentCount = 16
        geometry.heightSegmentCount = 16

        let material = SCNMaterial()
        material.diffuse.contents = snowColor
        material.specular.contents = UIColor(white: 0.6, alpha: 1.0)
        material.roughness.contents = NSNumber(value: 0.3)
        material.metalness.contents = NSNumber(value: 0.0)
        material.normal.intensity = 0.3
        geometry.materials = [material]

        let node = SCNNode(geometry: geometry)
        node.eulerAngles.x = -Float.pi / 2
        return node
    }

    private func addSideMountains(to parent: SCNNode) {
        let mountainHeight: CGFloat = 12
        let mountainWidth: CGFloat = 15

        for side in [-1.0, 1.0] as [Float] {
            let xPos = side * (chunkWidth / 2 + Float(mountainWidth) / 2 - 2)

            let mountainGeometry = SCNBox(
                width: mountainWidth,
                height: mountainHeight,
                length: CGFloat(chunkLength + 2),
                chamferRadius: 2.0
            )

            let material = SCNMaterial()
            material.diffuse.contents = mountainColor
            material.roughness.contents = NSNumber(value: 0.8)
            mountainGeometry.materials = [material]

            let mountainNode = SCNNode(geometry: mountainGeometry)
            mountainNode.position = SCNVector3(xPos, Float(mountainHeight) / 2 - 1, 0)
            parent.addChildNode(mountainNode)

            // Snow-capped peaks on top
            let peakGeometry = SCNPyramid(
                width: mountainWidth * 0.7,
                height: CGFloat(Float.random(in: 4...8)),
                length: CGFloat(chunkLength * 0.3)
            )
            let peakMaterial = SCNMaterial()
            peakMaterial.diffuse.contents = UIColor.white
            peakGeometry.materials = [peakMaterial]

            let peakNode = SCNNode(geometry: peakGeometry)
            peakNode.position = SCNVector3(
                xPos + Float.random(in: -2...2),
                Float(mountainHeight) + Float.random(in: 1...3),
                Float.random(in: -chunkLength * 0.3...chunkLength * 0.3)
            )
            parent.addChildNode(peakNode)
        }
    }

    private func addTerrainDetails(to parent: SCNNode, z: Float) {
        // Random moguls (small bumps)
        let mogulCount = Int.random(in: 2...6)
        for _ in 0..<mogulCount {
            let mogulRadius = CGFloat(Float.random(in: 0.3...1.2))
            let mogulGeometry = SCNSphere(radius: mogulRadius)

            let material = SCNMaterial()
            material.diffuse.contents = snowColor
            material.roughness.contents = NSNumber(value: 0.4)
            mogulGeometry.materials = [material]

            let mogulNode = SCNNode(geometry: mogulGeometry)
            mogulNode.position = SCNVector3(
                Float.random(in: -chunkWidth / 2 + 3...chunkWidth / 2 - 3),
                Float(mogulRadius) * 0.3,
                Float.random(in: -chunkLength / 2...chunkLength / 2)
            )
            mogulNode.scale = SCNVector3(1, 0.4, 1)
            parent.addChildNode(mogulNode)
        }

        // Occasional ski track marks
        if Float.random(in: 0...1) > 0.5 {
            let trackNode = createSkiTracks()
            parent.addChildNode(trackNode)
        }
    }

    /// Add colored trail marker poles along the edges
    private func addTrailMarkers(to parent: SCNNode) {
        guard Float.random(in: 0...1) > 0.6 else { return }

        let resort = ResortManager.shared.currentResort
        let markerColor = resort.difficulty.displayColor

        for side in [-1.0, 1.0] as [Float] {
            let poleGeometry = SCNCylinder(radius: 0.04, height: 1.2)
            let poleMaterial = SCNMaterial()
            poleMaterial.diffuse.contents = markerColor
            poleGeometry.materials = [poleMaterial]

            let poleNode = SCNNode(geometry: poleGeometry)
            poleNode.position = SCNVector3(
                side * (chunkWidth / 2 - 2),
                0.6,
                Float.random(in: -chunkLength * 0.3...chunkLength * 0.3)
            )
            parent.addChildNode(poleNode)
        }
    }

    private func createSkiTracks() -> SCNNode {
        let parent = SCNNode()
        let trackWidth: CGFloat = 0.08
        let trackLength = CGFloat(chunkLength * 0.6)
        let separation: Float = 0.25

        for offset in [-separation, separation] {
            let trackGeometry = SCNPlane(width: trackWidth, height: trackLength)
            let material = SCNMaterial()
            material.diffuse.contents = UIColor(red: 0.85, green: 0.87, blue: 0.92, alpha: 0.6)
            trackGeometry.materials = [material]

            let trackNode = SCNNode(geometry: trackGeometry)
            trackNode.eulerAngles.x = -Float.pi / 2
            trackNode.position = SCNVector3(
                Float.random(in: -5...5) + offset,
                0.01,
                Float.random(in: -chunkLength * 0.2...chunkLength * 0.2)
            )
            parent.addChildNode(trackNode)
        }

        return parent
    }

    // MARK: - Reset

    func reset() {
        for chunk in chunks {
            chunk.node.removeFromParentNode()
        }
        chunks.removeAll()
        nextChunkZ = GameConstants.terrainStartZ
        noiseOffset = 0
        generateInitialTerrain()
    }
}

// MARK: - Terrain Chunk

struct TerrainChunk {
    let node: SCNNode
    let startZ: Float
    let endZ: Float
}
