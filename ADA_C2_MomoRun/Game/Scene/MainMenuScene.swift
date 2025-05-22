//
//  MainMenuScene.swift
//  MomoRun
//
//  Created by Rafie Amandio on 21/05/25
//

import Foundation
import SpriteKit

final class MainMenuScene: SKScene {

    // Add a property to hold the WatchSessionManager instance
    private var watchSession: WatchSessionManager
    
    // Custom initializer that accepts the WatchSessionManager
    init(size: CGSize, watchSession: WatchSessionManager) {
        self.watchSession = watchSession
        super.init(size: size)
    }
    
    // Required initializer
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        size = view.frame.size
        scaleMode = .aspectFill

        // MARK: - Background
        let backgroundTexture = SKTexture(imageNamed: "main-background")
        let backgroundNode = SKSpriteNode(texture: backgroundTexture)
        backgroundNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        // Scale background to fill the screen while maintaining aspect ratio
        let scale = max(size.width / backgroundNode.size.width, size.height / backgroundNode.size.height)
        backgroundNode.setScale(scale)
        backgroundNode.zPosition = -1 // Ensure it's behind other elements
        addChild(backgroundNode)

        // MARK: - Play Button
        let playButtonTexture = SKTexture(imageNamed: "playbutton")
        let playButton = SKSpriteNode(texture: playButtonTexture)
        playButton.position = CGPoint(x: size.width / 2, y: size.height * 0.4)
        playButton.name = "playButton" // Assign a name for touch detection
        playButton.setScale(0.5) // Adjust scale as needed
        addChild(playButton)

        // MARK: - Settings Button
        let settingsButtonTexture = SKTexture(imageNamed: "settings-button") // Placeholder image name
        let settingsButton = SKSpriteNode(texture: settingsButtonTexture)
        // Position in top right with some padding
        let padding: CGFloat = 40
        settingsButton.position = CGPoint(x: size.width - padding, y: size.height - padding)
        settingsButton.name = "settingsButton" // Assign a name for touch detection
        settingsButton.setScale(0.4) // Adjust scale as needed
        addChild(settingsButton)
    }

    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodesAtLocation = nodes(at: location)

        for node in nodesAtLocation {
            if node.name == "playButton" {
                // Transition to the Game Scene, passing the watchSession instance
                let gameScene = GameSceneLab(size: size, watchSession: watchSession)
                gameScene.scaleMode = scaleMode
                let transition = SKTransition.fade(withDuration: 0.5) // Example transition
                view?.presentScene(gameScene, transition: transition)
                break // Exit loop after finding the button
            } else if node.name == "settingsButton" {
                // Handle settings button tap (e.g., transition to a settings scene)
                print("Settings button tapped!") // Placeholder action
                break
            }
        }
    }
} 
