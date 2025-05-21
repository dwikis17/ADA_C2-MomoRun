//
//  GameScene.swift
//  ADA_C2_MomoRun
//
//  Created by Dwiki on 16/05/25.
//

import Foundation
import SpriteKit

final class GameSceneLab: SKScene {
    struct Tile {
        let sprite: SKSpriteNode
        var worldPosition: Vector
        var worldXOffset: Double // For smooth movement
    }
    private var floorTiles: [Tile] = []
    private let tileWidth: CGFloat = 32 // Adjust based on your tile size
    private let moveSpeed: Double = 5 // tiles per second
    private var lastUpdateTime: TimeInterval = 0
    private let floorLength = 18
    private let floorWidth = 3
    private var player: SKSpriteNode?
    private var playerY: Int = 1 // Start at row 2
    

    private func createPlayer() {
        let playerNode = SKSpriteNode(imageNamed: "player_0") // Start with the first frame
        let position = Vector(x: -3, y: playerY, z: 3)
        let screenVector = convertWorldToScreen(position)
        playerNode.position = CGPoint(x: CGFloat(screenVector.x), y: CGFloat(screenVector.y))
        playerNode.zPosition = CGFloat(convertWorldToZPosition(position))
        playerNode.setScale(0.5)
        addChild(playerNode)
        self.player = playerNode

        // Animation setup
        let playerFrames: [SKTexture] = (0..<9).map { SKTexture(imageNamed: "player_\($0)") }
        let runAnimation = SKAction.animate(with: playerFrames, timePerFrame: 0.1, resize: false, restore: true)
        let repeatRun = SKAction.repeatForever(runAnimation)
        playerNode.run(repeatRun, withKey: "run")
    }

    private func createArrows() {
        let leftArrow = SKSpriteNode(imageNamed: "arrow")
        leftArrow.name = "arrow_left"
        leftArrow.setScale(0.009)
        leftArrow.position = CGPoint(x: 60, y: 60)
        leftArrow.zPosition = 1000
        leftArrow.zRotation = .pi  // Rotate 180 degrees to point left
        addChild(leftArrow)

        let rightArrow = SKSpriteNode(imageNamed: "arrow")
        rightArrow.name = "arrow_right"
        rightArrow.setScale(0.009)
        rightArrow.position = CGPoint(x: 140, y: 60)
        rightArrow.zPosition = 1000
        addChild(rightArrow)
    }

    private func moveLeft() {
        guard playerY < floorWidth - 1 else { return }
        playerY += 1
        updatePlayerPosition()
    }

    private func moveRight() {
        guard playerY > 0 else { return }
        playerY -= 1
        updatePlayerPosition()
    }

    private func updatePlayerPosition() {
        guard let playerNode = player else { return }
        let position = Vector(x: -3, y: playerY, z: 3)
        let screenVector = convertWorldToScreen(position)
        playerNode.position = CGPoint(x: CGFloat(screenVector.x), y: CGFloat(screenVector.y))
        playerNode.zPosition = CGFloat(convertWorldToZPosition(position))
    }

    override func didMove(to view: SKView) {
        size = view.frame.size
        scaleMode = .aspectFill
        
        let cameraNode = SKCameraNode()
    
        let cameraScreenVector = convertWorldToScreen(Vector(x: 2, y: 2))
        cameraNode.position = CGPoint(x: CGFloat(cameraScreenVector.x), y: CGFloat(cameraScreenVector.y))
        cameraNode.setScale(0.4) // Zoom in to make tiles look bigger
        addChild(cameraNode)
        self.camera = cameraNode

        // Create floor tiles with world positions
        for y in 0..<floorWidth {
            for x in -13..<floorLength {
                let imageName = y == 0 || y == 2 ? "tile_side" : "tile_middle"
                let sprite = SKSpriteNode(imageNamed: imageName)
                let worldPos = Vector(x: x, y: y)
                let screenVector = convertWorldToScreen(worldPos)
                sprite.position = CGPoint(x: CGFloat(screenVector.x), y: CGFloat(screenVector.y))
                sprite.zPosition = -Double(screenVector.y)
                addChild(sprite)
                floorTiles.append(Tile(sprite: sprite, worldPosition: worldPos, worldXOffset: Double(x)))
            }
        }
        createPlayer()
        // createArrows()
    }
    
    // Helper for smooth isometric rendering (uses Double for x)
    private func convertWorldToScreenSmooth(_ worldX: Double, _ worldY: Int) -> CGPoint {
        let base = convertWorldToScreen(Vector(x: Int(floor(worldX)), y: worldY))
        let next = convertWorldToScreen(Vector(x: Int(floor(worldX)) + 1, y: worldY))
        let t = CGFloat(worldX - floor(worldX))
        let x = CGFloat(base.x) * (1 - t) + CGFloat(next.x) * t
        let y = CGFloat(base.y) * (1 - t) + CGFloat(next.y) * t
        return CGPoint(x: x, y: y)
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard lastUpdateTime != 0 else {
            lastUpdateTime = currentTime
            return
        }
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        // Move all tiles in world space (using worldXOffset for smooth movement)
        for i in 0..<floorTiles.count {
            floorTiles[i].worldXOffset -= moveSpeed * deltaTime
            
            // If tile is out of view (e.g., x < -13), recycle to the end
            if floorTiles[i].worldXOffset < -13 {
                // Find max worldXOffset in this row
                let y = floorTiles[i].worldPosition.y
                let maxX = floorTiles
                    .filter { $0.worldPosition.y == y }
                    .map { $0.worldXOffset }
                    .max() ?? 0
                floorTiles[i].worldXOffset = maxX + 1
            }
            
            // Update worldPosition.x for logic only
            floorTiles[i].worldPosition = Vector(x: Int(floor(floorTiles[i].worldXOffset)), y: floorTiles[i].worldPosition.y)
        }
        
        // Update sprite positions (use smooth Double for rendering)
        for tile in floorTiles {
            let pos = convertWorldToScreenSmooth(tile.worldXOffset, tile.worldPosition.y)
            tile.sprite.position = pos
            tile.sprite.zPosition = -Double(pos.y)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = self.nodes(at: location)
        for node in nodes {
            if node.name == "arrow_left" {
                moveLeft()
            } else if node.name == "arrow_right" {
                moveRight()
            }
        }
    }

    // Add public methods for watch control
    @objc func moveLeftFromWatch() {
        moveLeft()
    }
    @objc func moveRightFromWatch() {
        moveRight()
    }
}
