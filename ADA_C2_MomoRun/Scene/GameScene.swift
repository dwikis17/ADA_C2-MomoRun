//
//  GameScene.swift
//  ADA_C2_MomoRun
//
//  Created by Dwiki on 16/05/25.
//

import Foundation
import SpriteKit


final class GameScene: SKScene {
    override func didMove(to view: SKView) {
        size = view.frame.size
        scaleMode = .aspectFill
        
        for y in 0 ..< 4  {
            for x in 0 ..< 4 {
                let sprite = SKSpriteNode(imageNamed: "floor")
                let screenPosition = convertWorldToScreen(Vector(x: x, y: y))
                sprite.position = CGPoint(x: screenPosition.x, y: screenPosition.y)
                addChild(sprite)
            }
        }
    }
}
