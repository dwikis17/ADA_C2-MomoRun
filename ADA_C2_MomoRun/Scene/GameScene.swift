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
    private let scrollSpeed: CGFloat = 200.0
    private var lastUpdateTime: TimeInterval = 0
    private let roadWidth = 11 // Width of the road in tiles
    
    override func didMove(to view: SKView) {
        size = view.frame.size
        scaleMode = .aspectFill
        
        let cameraNode = SKCameraNode()
        let cameraScreenPosition = convertWorldToScreen(Vector(x:28, y: 6))
        cameraNode.position = CGPoint(x: cameraScreenPosition.x, y: cameraScreenPosition.y)
        addChild(cameraNode)
        self.camera = cameraNode
        
        for y in 0..<8 {
            for x in 0..<80 {
                let sprite = SKSpriteNode(imageNamed: "floor")
                let screenPosition = convertWorldToScreen(Vector(x: x, y: y))
                sprite.position = CGPoint(x: screenPosition.x, y: screenPosition.y)
                sprite.zPosition = -Double(screenPosition.y)
                addChild(sprite)
                groundTiles.append(sprite)
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
            return
        }
        
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        // Move all ground tiles
        for tile in groundTiles {
            // Move tiles diagonally for isometric effect
            tile.position.x -= scrollSpeed * CGFloat(deltaTime)
            tile.position.y -= scrollSpeed * CGFloat(deltaTime) * 0.5 // Half speed for y to maintain isometric look
            
            // // If tile is off screen, move it to the right side
            // if tile.position.x < -tile.size.width - 100 {
            //     let screenPosition = convertWorldToScreen(Vector(x: 80, y: 0))
            //     tile.position = CGPoint(x: screenPosition.x, y: screenPosition.y)
            // }
        }
    }
}
