import SpriteKit

final class GameSceneTest: SKScene {
    private var roadSegments: [SKSpriteNode] = []
    private let scrollSpeed: CGFloat = 200.0
    private var lastUpdateTime: TimeInterval = 0
    private let segmentCount = 3
    private var character: SKSpriteNode!
    // Lane system (for future use)
    private let laneOffsets: [CGFloat] = [-60, 0, 60] // Adjust for your road asset width
    private var currentLane = 1 // Start in middle lane
    private let laneY: CGFloat = 50 // Character y offset from road center

    override func didMove(to view: SKView) {
        size = view.frame.size
        scaleMode = .aspectFill

        let cameraNode = SKCameraNode()
        // Position camera to show more of the scene
        cameraNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        cameraNode.setScale(1) // Zoom out the camera
        addChild(cameraNode)
        self.camera = cameraNode

        // Add road segments with more spacing
        for i in 0..<segmentCount {
            let road = SKSpriteNode(imageNamed: "road")
            road.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            let offset: CGFloat = CGFloat(i) * road.size.height * 1.2 // Increased spacing
            let isoX = size.width / 2 + offset
            let isoY = size.height / 2 - offset * 0.5
            road.position = CGPoint(x: isoX, y: isoY)
            road.zPosition = -100
            addChild(road)
            roadSegments.append(road)
        }

        // Add character (center lane)
        character = SKSpriteNode(imageNamed: "test")
        let charX = size.width / 2 + laneOffsets[currentLane]
        let charY = size.height / 2 + laneY
        character.position = CGPoint(x: charX, y: charY)
        character.zPosition = 1
        addChild(character)
    }

    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
            return
        }
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        let moveX = scrollSpeed * CGFloat(deltaTime)
        let moveY = scrollSpeed * CGFloat(deltaTime) * 0.5

        guard let roadSample = roadSegments.first else { return }
        let offset: CGFloat = roadSample.size.height * 1.2 // Match the spacing from didMove

        for road in roadSegments {
            road.position.x -= moveX
            road.position.y -= moveY

            // If the segment is completely off the bottom of the screen, recycle it to the top
            if road.position.y + road.size.height / 2 < 0 {
                // Find the current top-most segment
                if let topMost = roadSegments.max(by: { $0.position.y < $1.position.y }) {
                    road.position.x = topMost.position.x + offset
                    road.position.y = topMost.position.y - offset * 0.5
                }
            }
        }
    }
} 