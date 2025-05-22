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
    
    // Properties for the breathing text instruction
    private var instructionLabel: SKLabelNode?
    private var breathingAction: SKAction?
    
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

        // MARK: - Breathing Instruction Text
        createBreathingText()
        
        // MARK: - Settings Button
        let settingsButtonTexture = SKTexture(imageNamed: "settings-button") // Placeholder image name
        let settingsButton = SKSpriteNode(texture: settingsButtonTexture)
        // Position in top right with some padding
        let padding: CGFloat = 40
        settingsButton.position = CGPoint(x: size.width - padding, y: size.height - padding)
        settingsButton.name = "settingsButton" // Assign a name for touch detection
        settingsButton.setScale(0.4) // Adjust scale as needed
        addChild(settingsButton)
        
        // Set up watch session start handler
        watchSession.onStart = { [weak self] in
            self?.startGame()
        }
    }
    
    private func createBreathingText() {
        // Create the instruction label
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = "Start from Watch"
        label.fontSize = 36
        label.fontColor = .white
        label.position = CGPoint(x: size.width / 2, y: size.height * 0.4)
        label.zPosition = 10
        addChild(label)
        self.instructionLabel = label
        
        // Create breathing animation
        let scaleUp = SKAction.scale(to: 1.2, duration: 1.0)
        scaleUp.timingMode = .easeInEaseOut
        let scaleDown = SKAction.scale(to: 1.0, duration: 1.0)
        scaleDown.timingMode = .easeInEaseOut
        let breathe = SKAction.sequence([scaleUp, scaleDown])
        let breatheForever = SKAction.repeatForever(breathe)
        
        // Apply the animation
        label.run(breatheForever)
    }
    
    private func startGame() {
        // Transition to the Game Scene, passing the watchSession instance
        let gameScene = GameSceneLab(size: size, watchSession: watchSession)
        gameScene.scaleMode = scaleMode
        let transition = SKTransition.fade(withDuration: 0.5)
        view?.presentScene(gameScene, transition: transition)
    }

    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodesAtLocation = nodes(at: location)

        for node in nodesAtLocation {
            if node.name == "settingsButton" {
                // Handle settings button tap
                print("Settings button tapped!") // Placeholder action
                break
            }
        }
    }
} 
