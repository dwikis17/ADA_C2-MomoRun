//
//  MainMenuScene.swift
//  MomoRun
//
//  Created by [Your Name] on [Date].
//

import Foundation
import SpriteKit

final class MainMenuScene: SKScene {

    override func didMove(to view: SKView) {
        size = view.frame.size
        scaleMode = .aspectFill

        // MARK: - Background
        // Use the menu-background image
        let backgroundTexture = SKTexture(imageNamed: "menu-background")
        let backgroundNode = SKSpriteNode(texture: backgroundTexture)
        backgroundNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        backgroundNode.size = size // Make sure the background covers the screen
        backgroundNode.zPosition = -1 // Ensure it's behind other elements
        addChild(backgroundNode)

        // Remove the solid color background
        // backgroundColor = SKColor(red: 0.15, green: 0.15, blue: 0.3, alpha: 0.7) // Example dark background

        // MARK: - Play Button
        let playButtonTexture = SKTexture(imageNamed: "play-button") // Replace "play-button" with your actual button image name, or create a text label
        let playButton = SKSpriteNode(texture: playButtonTexture)
        playButton.position = CGPoint(x: size.width / 2, y: size.height * 0.3)
        playButton.name = "playButton" // Assign a name for touch detection
        playButton.setScale(0.8) // Adjusted scale
        addChild(playButton)
    }

    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodesAtLocation = nodes(at: location)

        for node in nodesAtLocation {
            if node.name == "playButton" {
                // Transition to the Game Scene
                let gameScene = GameSceneLab(size: size)
                gameScene.scaleMode = scaleMode
                let transition = SKTransition.fade(withDuration: 0.5)
                view?.presentScene(gameScene, transition: transition)
                break // Exit loop after finding the button
            }
        }
    }
} 
