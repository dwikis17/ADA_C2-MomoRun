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
    private let moveSpeed: Double = 15 // tiles per second
    private var lastUpdateTime: TimeInterval = 0
    private let floorLength = 18
    private let floorWidth = 3
    
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
}