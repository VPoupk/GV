import SceneKit
import UIKit

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

    // Snow park mode
    private let isSnowPark: Bool
    private var chunkIndex: Int = 0

    init(terrainRoot: SCNNode) {
        self.terrainRoot = terrainRoot
        let resort = ResortManager.shared.currentResort
        self.snowColor = resort.snowColor
        self.mountainColor = resort.mountainColor
        self.chunkWidth = GameConstants.terrainWidth * resort.widthMultiplier
        self.isSnowPark = resort.isSnowPark
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
        chunkIndex += 1
    }

    private func generateChunk(atZ z: Float) -> TerrainChunk {
        let node = SCNNode()

        if isSnowPark && chunkIndex > 2 {
            // Snow park terrain with halfpipe sections
            let snowPlane = createSnowSurface()
            node.addChildNode(snowPlane)
            addSideMountains(to: node)

            // Alternate between halfpipe sections and flat park areas
            let pattern = chunkIndex % 6
            if pattern < 3 {
                // Halfpipe section
                let halfpipe = createHalfpipe()
                node.addChildNode(halfpipe)
            } else {
                // Flat park area with features
                addParkFeatures(to: node)
                addTerrainDetails(to: node, z: z)
            }
        } else {
            // Regular terrain
            let snowPlane = createSnowSurface()
            node.addChildNode(snowPlane)
            addSideMountains(to: node)
            addTerrainDetails(to: node, z: z)
            addTrailMarkers(to: node)
        }

        node.position = SCNVector3(0, 0, z - chunkLength / 2)

        // Slight slope variation (flatter for snow park)
        noiseOffset += 0.3
        let slopeVariation = sin(noiseOffset) * (isSnowPark ? 0.005 : 0.02)
        let slopeAngle = isSnowPark ? GameConstants.baseSlopeAngle * 0.5 : currentSlope
        node.eulerAngles.x = -(slopeAngle + slopeVariation)

        return TerrainChunk(
            node: node,
            startZ: z,
            endZ: z - chunkLength
        )
    }

    private func createSnowSurface() -> SCNNode {
        let geometry = SCNPlane(width: CGFloat(chunkWidth), height: CGFloat(chunkLength))
        geometry.widthSegmentCount = 32
        geometry.heightSegmentCount = 32

        let material = SCNMaterial()
        material.diffuse.contents = snowColor
        material.specular.contents = UIColor(white: 0.8, alpha: 1.0)
        material.roughness.contents = NSNumber(value: 0.25)
        material.metalness.contents = NSNumber(value: 0.02)
        material.normal.intensity = 0.4
        material.ambientOcclusion.intensity = 0.3
        material.lightingModel = .physicallyBased
        geometry.materials = [material]

        let node = SCNNode(geometry: geometry)
        node.eulerAngles.x = -Float.pi / 2
        return node
    }

    private func addSideMountains(to parent: SCNNode) {
        let mountainHeight: CGFloat = 15
        let mountainWidth: CGFloat = 18

        for side in [-1.0, 1.0] as [Float] {
            let xPos = side * (chunkWidth / 2 + Float(mountainWidth) / 2 - 2)

            // Main mountain body
            let mountainGeometry = SCNBox(
                width: mountainWidth,
                height: mountainHeight,
                length: CGFloat(chunkLength + 2),
                chamferRadius: 3.0
            )

            let material = SCNMaterial()
            material.diffuse.contents = mountainColor
            material.roughness.contents = NSNumber(value: 0.75)
            material.metalness.contents = NSNumber(value: 0.05)
            material.lightingModel = .physicallyBased
            mountainGeometry.materials = [material]

            let mountainNode = SCNNode(geometry: mountainGeometry)
            mountainNode.position = SCNVector3(xPos, Float(mountainHeight) / 2 - 1, 0)
            parent.addChildNode(mountainNode)

            // Snow-capped peaks on top
            let peakHeight = CGFloat(Float.random(in: 5...10))
            let peakGeometry = SCNPyramid(
                width: mountainWidth * 0.7,
                height: peakHeight,
                length: CGFloat(chunkLength * 0.3)
            )
            let peakMaterial = SCNMaterial()
            peakMaterial.diffuse.contents = UIColor(white: 0.97, alpha: 1.0)
            peakMaterial.roughness.contents = NSNumber(value: 0.3)
            peakMaterial.lightingModel = .physicallyBased
            peakGeometry.materials = [peakMaterial]

            let peakNode = SCNNode(geometry: peakGeometry)
            peakNode.position = SCNVector3(
                xPos + Float.random(in: -2...2),
                Float(mountainHeight) + Float.random(in: 1...3),
                Float.random(in: -chunkLength * 0.3...chunkLength * 0.3)
            )
            parent.addChildNode(peakNode)

            // Additional smaller peaks for more realism
            if Float.random(in: 0...1) > 0.4 {
                let smallPeakGeometry = SCNPyramid(
                    width: mountainWidth * 0.4,
                    height: CGFloat(Float.random(in: 3...6)),
                    length: CGFloat(chunkLength * 0.2)
                )
                smallPeakGeometry.materials = [peakMaterial]
                let smallPeakNode = SCNNode(geometry: smallPeakGeometry)
                smallPeakNode.position = SCNVector3(
                    xPos + Float.random(in: -4...4),
                    Float(mountainHeight) + Float.random(in: 0...2),
                    Float.random(in: -chunkLength * 0.2...chunkLength * 0.2)
                )
                parent.addChildNode(smallPeakNode)
            }
        }
    }

    private func addTerrainDetails(to parent: SCNNode, z: Float) {
        // Random moguls (small bumps) with smoother geometry
        let mogulCount = Int.random(in: 2...6)
        for _ in 0..<mogulCount {
            let mogulRadius = CGFloat(Float.random(in: 0.3...1.2))
            let mogulGeometry = SCNSphere(radius: mogulRadius)
            mogulGeometry.segmentCount = 24

            let material = SCNMaterial()
            material.diffuse.contents = snowColor
            material.roughness.contents = NSNumber(value: 0.3)
            material.lightingModel = .physicallyBased
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

        // Occasional groomed snow patches for visual variety
        if Float.random(in: 0...1) > 0.7 {
            let patchGeometry = SCNPlane(width: CGFloat(Float.random(in: 3...6)), height: CGFloat(Float.random(in: 4...8)))
            patchGeometry.widthSegmentCount = 8
            patchGeometry.heightSegmentCount = 8
            let patchMaterial = SCNMaterial()
            patchMaterial.diffuse.contents = UIColor(white: 0.93, alpha: 0.4)
            patchMaterial.roughness.contents = NSNumber(value: 0.15)
            patchMaterial.lightingModel = .physicallyBased
            patchGeometry.materials = [patchMaterial]
            let patchNode = SCNNode(geometry: patchGeometry)
            patchNode.eulerAngles.x = -Float.pi / 2
            patchNode.position = SCNVector3(
                Float.random(in: -chunkWidth / 3...chunkWidth / 3),
                0.02,
                Float.random(in: -chunkLength / 3...chunkLength / 3)
            )
            parent.addChildNode(patchNode)
        }
    }

    /// Add colored trail marker poles along the edges
    private func addTrailMarkers(to parent: SCNNode) {
        guard Float.random(in: 0...1) > 0.6 else { return }

        let resort = ResortManager.shared.currentResort
        let markerColor = resort.difficulty.displayColor

        for side in [-1.0, 1.0] as [Float] {
            let poleGeometry = SCNCylinder(radius: 0.04, height: 1.2)
            poleGeometry.radialSegmentCount = 12
            let poleMaterial = SCNMaterial()
            poleMaterial.diffuse.contents = markerColor
            poleMaterial.lightingModel = .physicallyBased
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
            material.diffuse.contents = UIColor(red: 0.85, green: 0.87, blue: 0.92, alpha: 0.5)
            material.roughness.contents = NSNumber(value: 0.15)
            material.lightingModel = .physicallyBased
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

    // MARK: - Snow Park Features

    private func createHalfpipe() -> SCNNode {
        let halfpipeNode = SCNNode()

        let pipeWidth: Float = 12.0
        let wallHeight: Float = 4.0
        let transitionRadius: Float = 3.0
        let pipeLength: Float = chunkLength - 2

        // Create left and right quarter-pipe walls using custom geometry
        let leftWall = createQuarterPipeWall(
            radius: transitionRadius,
            wallHeight: wallHeight,
            length: pipeLength,
            isLeft: true,
            offsetX: -pipeWidth / 2 + transitionRadius
        )
        halfpipeNode.addChildNode(leftWall)

        let rightWall = createQuarterPipeWall(
            radius: transitionRadius,
            wallHeight: wallHeight,
            length: pipeLength,
            isLeft: false,
            offsetX: pipeWidth / 2 - transitionRadius
        )
        halfpipeNode.addChildNode(rightWall)

        // Flat bottom of the halfpipe
        let floorGeometry = SCNPlane(
            width: CGFloat(pipeWidth - transitionRadius * 2),
            height: CGFloat(pipeLength)
        )
        floorGeometry.widthSegmentCount = 16
        floorGeometry.heightSegmentCount = 16
        let floorMaterial = createIcySnowMaterial()
        floorGeometry.materials = [floorMaterial]
        let floorNode = SCNNode(geometry: floorGeometry)
        floorNode.eulerAngles.x = -Float.pi / 2
        floorNode.position = SCNVector3(0, 0.01, 0)
        halfpipeNode.addChildNode(floorNode)

        // Coping rails at the top of each wall
        for side in [-1.0, 1.0] as [Float] {
            let copingGeometry = SCNCylinder(radius: 0.06, height: CGFloat(pipeLength))
            copingGeometry.radialSegmentCount = 16
            let copingMaterial = SCNMaterial()
            copingMaterial.diffuse.contents = UIColor(red: 0.6, green: 0.6, blue: 0.65, alpha: 1.0)
            copingMaterial.metalness.contents = NSNumber(value: 0.9)
            copingMaterial.roughness.contents = NSNumber(value: 0.1)
            copingMaterial.lightingModel = .physicallyBased
            copingGeometry.materials = [copingMaterial]

            let copingNode = SCNNode(geometry: copingGeometry)
            copingNode.eulerAngles.x = Float.pi / 2
            copingNode.position = SCNVector3(
                side * (pipeWidth / 2),
                wallHeight + transitionRadius,
                0
            )
            halfpipeNode.addChildNode(copingNode)
        }

        // Side snow banks above the halfpipe walls
        for side in [-1.0, 1.0] as [Float] {
            let bankGeometry = SCNBox(
                width: CGFloat(chunkWidth / 2 - pipeWidth / 2 - 1),
                height: 0.5,
                length: CGFloat(pipeLength),
                chamferRadius: 0.2
            )
            let bankMaterial = SCNMaterial()
            bankMaterial.diffuse.contents = snowColor
            bankMaterial.roughness.contents = NSNumber(value: 0.3)
            bankMaterial.lightingModel = .physicallyBased
            bankGeometry.materials = [bankMaterial]

            let bankNode = SCNNode(geometry: bankGeometry)
            let bankOffset = (pipeWidth / 2 + chunkWidth / 4)
            bankNode.position = SCNVector3(
                side * bankOffset,
                wallHeight + transitionRadius - 0.25,
                0
            )
            halfpipeNode.addChildNode(bankNode)
        }

        return halfpipeNode
    }

    private func createQuarterPipeWall(radius: Float, wallHeight: Float, length: Float, isLeft: Bool, offsetX: Float) -> SCNNode {
        let arcSegments = 20
        let lengthSegments = 16

        var vertices: [SCNVector3] = []
        var normals: [SCNVector3] = []
        var texCoords: [CGPoint] = []
        var indices: [Int32] = []

        // Total profile: quarter-circle curve + vertical wall extension
        let totalProfileSegments = arcSegments + 8 // 8 segments for vertical wall
        let profileSegments = totalProfileSegments

        for j in 0...lengthSegments {
            let z = -length / 2 + length * Float(j) / Float(lengthSegments)
            let v = Float(j) / Float(lengthSegments)

            for i in 0...profileSegments {
                let t = Float(i) / Float(profileSegments)
                var x: Float
                var y: Float
                var nx: Float
                var ny: Float

                if i <= arcSegments {
                    // Quarter-circle curve section
                    let angle: Float
                    if isLeft {
                        angle = Float.pi / 2 * Float(i) / Float(arcSegments)
                    } else {
                        angle = Float.pi / 2 * (1.0 - Float(i) / Float(arcSegments))
                    }

                    if isLeft {
                        x = offsetX - radius * cos(angle)
                        y = radius * sin(angle)
                        nx = cos(angle)
                        ny = -sin(angle)
                    } else {
                        x = offsetX + radius * cos(angle)
                        y = radius * sin(angle)
                        nx = -cos(angle)
                        ny = -sin(angle)
                    }
                } else {
                    // Vertical wall extension
                    let wallFraction = Float(i - arcSegments) / Float(profileSegments - arcSegments)
                    if isLeft {
                        x = offsetX - radius
                        nx = 1.0
                    } else {
                        x = offsetX + radius
                        nx = -1.0
                    }
                    y = radius + wallFraction * wallHeight
                    ny = 0
                }

                vertices.append(SCNVector3(x, y, z))
                normals.append(SCNVector3(nx, ny, 0))
                texCoords.append(CGPoint(x: CGFloat(t), y: CGFloat(v)))
            }
        }

        // Generate triangle indices
        let stride = profileSegments + 1
        for j in 0..<lengthSegments {
            for i in 0..<profileSegments {
                let a = Int32(j * stride + i)
                let b = Int32(j * stride + i + 1)
                let c = Int32((j + 1) * stride + i)
                let d = Int32((j + 1) * stride + i + 1)

                indices.append(contentsOf: [a, c, b, b, c, d])
            }
        }

        let vertexSource = SCNGeometrySource(vertices: vertices)
        let normalSource = SCNGeometrySource(normals: normals)
        let texCoordSource = SCNGeometrySource(textureCoordinates: texCoords)
        let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)

        let geometry = SCNGeometry(sources: [vertexSource, normalSource, texCoordSource], elements: [element])
        let material = createIcySnowMaterial()
        material.isDoubleSided = true
        geometry.materials = [material]

        return SCNNode(geometry: geometry)
    }

    private func createIcySnowMaterial() -> SCNMaterial {
        let material = SCNMaterial()
        material.diffuse.contents = UIColor(red: 0.88, green: 0.92, blue: 0.98, alpha: 1.0)
        material.specular.contents = UIColor(white: 0.9, alpha: 1.0)
        material.roughness.contents = NSNumber(value: 0.15)
        material.metalness.contents = NSNumber(value: 0.05)
        material.lightingModel = .physicallyBased
        return material
    }

    private func addParkFeatures(to parent: SCNNode) {
        // Add rails
        let railCount = Int.random(in: 1...2)
        for _ in 0..<railCount {
            let rail = createRail()
            rail.position = SCNVector3(
                Float.random(in: -chunkWidth / 3...chunkWidth / 3),
                0,
                Float.random(in: -chunkLength / 3...chunkLength / 3)
            )
            parent.addChildNode(rail)
        }

        // Add kicker jumps
        if Float.random(in: 0...1) > 0.4 {
            let kicker = createKicker()
            kicker.position = SCNVector3(
                Float.random(in: -chunkWidth / 4...chunkWidth / 4),
                0,
                Float.random(in: -chunkLength / 4...chunkLength / 4)
            )
            parent.addChildNode(kicker)
        }

        // Add box features
        if Float.random(in: 0...1) > 0.5 {
            let box = createParkBox()
            box.position = SCNVector3(
                Float.random(in: -chunkWidth / 3...chunkWidth / 3),
                0,
                Float.random(in: -chunkLength / 4...chunkLength / 4)
            )
            parent.addChildNode(box)
        }
    }

    private func createRail() -> SCNNode {
        let railNode = SCNNode()

        // Support posts
        let postHeight: Float = 0.8
        for zOff in [-2.0, 0.0, 2.0] as [Float] {
            let postGeometry = SCNCylinder(radius: 0.04, height: CGFloat(postHeight))
            postGeometry.radialSegmentCount = 12
            let postMaterial = SCNMaterial()
            postMaterial.diffuse.contents = UIColor(red: 0.5, green: 0.5, blue: 0.55, alpha: 1.0)
            postMaterial.metalness.contents = NSNumber(value: 0.8)
            postMaterial.roughness.contents = NSNumber(value: 0.2)
            postMaterial.lightingModel = .physicallyBased
            postGeometry.materials = [postMaterial]
            let postNode = SCNNode(geometry: postGeometry)
            postNode.position = SCNVector3(0, postHeight / 2, zOff)
            railNode.addChildNode(postNode)
        }

        // Rail bar
        let barGeometry = SCNCylinder(radius: 0.05, height: 5.0)
        barGeometry.radialSegmentCount = 16
        let barMaterial = SCNMaterial()
        barMaterial.diffuse.contents = UIColor(red: 0.7, green: 0.7, blue: 0.75, alpha: 1.0)
        barMaterial.metalness.contents = NSNumber(value: 0.9)
        barMaterial.roughness.contents = NSNumber(value: 0.1)
        barMaterial.lightingModel = .physicallyBased
        barGeometry.materials = [barMaterial]
        let barNode = SCNNode(geometry: barGeometry)
        barNode.eulerAngles.x = Float.pi / 2
        barNode.position = SCNVector3(0, postHeight, 0)
        railNode.addChildNode(barNode)

        return railNode
    }

    private func createKicker() -> SCNNode {
        let kickerNode = SCNNode()

        let rampGeometry = SCNBox(width: 3.5, height: 0.4, length: 2.5, chamferRadius: 0.08)
        let rampMaterial = SCNMaterial()
        rampMaterial.diffuse.contents = UIColor(white: 0.92, alpha: 1.0)
        rampMaterial.roughness.contents = NSNumber(value: 0.25)
        rampMaterial.lightingModel = .physicallyBased
        rampGeometry.materials = [rampMaterial]

        let rampNode = SCNNode(geometry: rampGeometry)
        rampNode.position = SCNVector3(0, 0.3, 0)
        rampNode.eulerAngles.x = -Float.pi / 10
        kickerNode.addChildNode(rampNode)

        // Orange marker poles
        for side in [-1.8, 1.8] as [Float] {
            let poleGeometry = SCNCylinder(radius: 0.03, height: 1.2)
            poleGeometry.radialSegmentCount = 10
            let poleMaterial = SCNMaterial()
            poleMaterial.diffuse.contents = UIColor.orange
            poleMaterial.lightingModel = .physicallyBased
            poleGeometry.materials = [poleMaterial]
            let poleNode = SCNNode(geometry: poleGeometry)
            poleNode.position = SCNVector3(side, 0.6, 0)
            kickerNode.addChildNode(poleNode)
        }

        return kickerNode
    }

    private func createParkBox() -> SCNNode {
        let boxNode = SCNNode()

        let boxGeometry = SCNBox(width: 1.5, height: 0.6, length: 4.0, chamferRadius: 0.03)
        let boxMaterial = SCNMaterial()
        boxMaterial.diffuse.contents = UIColor(red: 0.2, green: 0.5, blue: 0.8, alpha: 1.0)
        boxMaterial.metalness.contents = NSNumber(value: 0.3)
        boxMaterial.roughness.contents = NSNumber(value: 0.4)
        boxMaterial.lightingModel = .physicallyBased
        boxGeometry.materials = [boxMaterial]

        let mainBox = SCNNode(geometry: boxGeometry)
        mainBox.position = SCNVector3(0, 0.3, 0)
        boxNode.addChildNode(mainBox)

        // Top surface (metal grind plate)
        let topGeometry = SCNBox(width: 1.52, height: 0.02, length: 4.02, chamferRadius: 0.01)
        let topMaterial = SCNMaterial()
        topMaterial.diffuse.contents = UIColor(red: 0.75, green: 0.75, blue: 0.8, alpha: 1.0)
        topMaterial.metalness.contents = NSNumber(value: 0.85)
        topMaterial.roughness.contents = NSNumber(value: 0.1)
        topMaterial.lightingModel = .physicallyBased
        topGeometry.materials = [topMaterial]
        let topNode = SCNNode(geometry: topGeometry)
        topNode.position = SCNVector3(0, 0.61, 0)
        boxNode.addChildNode(topNode)

        return boxNode
    }

    // MARK: - Reset

    func reset() {
        for chunk in chunks {
            chunk.node.removeFromParentNode()
        }
        chunks.removeAll()
        nextChunkZ = GameConstants.terrainStartZ
        noiseOffset = 0
        chunkIndex = 0
        generateInitialTerrain()
    }
}

// MARK: - Terrain Chunk

struct TerrainChunk {
    let node: SCNNode
    let startZ: Float
    let endZ: Float
}
