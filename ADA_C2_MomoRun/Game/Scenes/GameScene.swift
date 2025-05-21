//
//  GameScene.swift
//  ADA_C2_MomoRun
//
//  Created by Dwiki on 16/05/25.
//

import Foundation
import SpriteKit


final class GameScene: SKScene {
    private var groundTiles: [SKSpriteNode] = []
    private var obstacles: [SKSpriteNode] = []
    private let scrollSpeed: CGFloat = 200.0
    private var lastUpdateTime: TimeInterval = 0
    private let gridWidth = 80 // Width of the grid in tiles
    private let gridHeight = 8 // Height of the grid in tiles
    private var character: SKSpriteNode!
    
    // Lane system
    private let lanePositions = [5, 6, 7] // World x-coordinates for left, middle, right lanes
    private var currentLane = 1 // Start in middle lane (index 1)
    private let laneChangeSpeed: CGFloat = 0.3 // Speed of lane change animation
    
    // Function to get tile's world position based on index
    private func getTileWorldPosition(index: Int) -> Vector {
        let x = index % gridWidth
        let y = index / gridWidth
        return Vector(x: x, y: y)
    }
    
    override func didMove(to view: SKView) {
        size = view.frame.size
        scaleMode = .aspectFill
        
        let cameraNode = SKCameraNode()
        let cameraScreenVector = convertWorldToScreen(Vector(x: 28, y: 6))
        cameraNode.position = CGPoint(x: CGFloat(cameraScreenVector.x), y: CGFloat(cameraScreenVector.y))
        addChild(cameraNode)
        self.camera = cameraNode
        
        // Create ground tiles in a grid pattern
        for y in 0..<gridHeight {
            for x in 0..<gridWidth {
                let sprite = SKSpriteNode(imageNamed: "floor")
                let screenVector = convertWorldToScreen(Vector(x: x, y: y))
                sprite.position = CGPoint(x: CGFloat(screenVector.x), y: CGFloat(screenVector.y))
                sprite.zPosition = -Double(screenVector.y)
                addChild(sprite)
                groundTiles.append(sprite)
            }
        }
        
        // Add character
        character = SKSpriteNode(imageNamed: "test")
        let characterScreenVector = convertWorldToScreen(Vector(x: lanePositions[currentLane], y: 6))
        character.position = CGPoint(x: CGFloat(characterScreenVector.x), y: CGFloat(characterScreenVector.y))
        character.zPosition = 1 // Make sure character appears above the ground
        addChild(character)
        
        // Add initial obstacles
        spawnObstacle()
        
        // Add touch handling
        let leftArea = SKSpriteNode(color: .clear, size: CGSize(width: size.width/3, height: size.height))
        leftArea.position = CGPoint(x: size.width/6, y: size.height/2)
        leftArea.name = "leftArea"
        addChild(leftArea)
        
        let rightArea = SKSpriteNode(color: .clear, size: CGSize(width: size.width/3, height: size.height))
        rightArea.position = CGPoint(x: size.width * 5/6, y: size.height/2)
        rightArea.name = "rightArea"
        addChild(rightArea)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = nodes(at: location)
        
        for node in nodes {
            if node.name == "leftArea" {
                moveLeft()
            } else if node.name == "rightArea" {
                moveRight()
            }
        }
    }
    
    private func moveLeft() {
        if currentLane > 0 {
            currentLane -= 1
            let newScreenVector = convertWorldToScreen(Vector(x: lanePositions[currentLane], y: 6))
            let moveAction = SKAction.move(to: CGPoint(x: CGFloat(newScreenVector.x), y: CGFloat(newScreenVector.y)), duration: laneChangeSpeed)
            character.run(moveAction)
        }
    }
    
    private func moveRight() {
        if currentLane < lanePositions.count - 1 {
            currentLane += 1
            let newScreenVector = convertWorldToScreen(Vector(x: lanePositions[currentLane], y: 6))
            let moveAction = SKAction.move(to: CGPoint(x: CGFloat(newScreenVector.x), y: CGFloat(newScreenVector.y)), duration: laneChangeSpeed)
            character.run(moveAction)
        }
    }
    
    private func spawnObstacle() {
        let obstacle = SKSpriteNode(imageNamed: "test")
        // Position obstacle at the right edge of the screen
        let obstacleScreenVector = convertWorldToScreen(Vector(x: gridWidth + 5, y: 6))
        obstacle.position = CGPoint(x: CGFloat(obstacleScreenVector.x), y: CGFloat(obstacleScreenVector.y))
        obstacle.zPosition = 1
        addChild(obstacle)
        obstacles.append(obstacle)
    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
            return
        }
        
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        // Calculate movement in screen space based on isometric direction
        let movementX = scrollSpeed * CGFloat(deltaTime)
        let movementY = scrollSpeed * CGFloat(deltaTime) * 0.5 // Half speed for y axis for isometric look
        
        // Move all ground tiles
        for (index, tile) in groundTiles.enumerated() {
            // Move tiles diagonally for isometric effect
            tile.position.x -= movementX
            tile.position.y -= movementY
            
            // Get the floor tile width for recycling calculation
            let tileWidth = tile.size.width
            
            // If tile is off screen to the left, move it to the right side
            if tile.position.x < -tileWidth {
                // Get the tile's row from the index
                let tileWorldPos = getTileWorldPosition(index: index)
                
                // Calculate new position at the rightmost edge
                let newWorldPos = Vector(x: gridWidth, y: tileWorldPos.y)
                let screenVector = convertWorldToScreen(newWorldPos)
                
                // Reposition tile
                tile.position = CGPoint(x: CGFloat(screenVector.x), y: CGFloat(screenVector.y))
                tile.zPosition = -Double(screenVector.y)
            }
        }
        
        // Move obstacles
        // for obstacle in obstacles {
        //     obstacle.position.x -= movementX
        //     obstacle.position.y -= movementY
        //     obstacle.zPosition = -Double(obstacle.position.y)
            
        //     // Check for collision with character
        //     if obstacle.frame.intersects(character.frame) {
        //         print("Collision detecteds!")
        //     }
            
        //     // Remove obstacle if it's off screen
        //     if obstacle.position.x < -obstacle.size.width {
        //         obstacle.removeFromParent()
        //         if let index = obstacles.firstIndex(of: obstacle) {
        //             obstacles.remove(at: index)
        //         }
        //         // Spawn new obstacle
        //         spawnObstacle()
        //     }
        // }
    }
}
