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
    
    // Text size constant
    private let kTextFontSize: CGFloat = 48
    
    // Add a property to hold the breathing group node
    private var breathingGroup: SKNode?
    private var breathingParticles: SKEmitterNode?
    
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

        addBackgroundParticles() // Add subtle background particles

        // MARK: - Background (Pixel Art Sky with Trees)
        let backgroundTexture = SKTexture(imageNamed: "main-background")
        let backgroundNode = SKSpriteNode(texture: backgroundTexture)
        backgroundNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        // Scale background to fill the screen while maintaining aspect ratio
        let scale = max(size.width / backgroundNode.size.width, size.height / backgroundNode.size.height)
        backgroundNode.setScale(scale)
        backgroundNode.zPosition = -1 // Ensure it's behind other elements
        addChild(backgroundNode)

        // MARK: - Game Title
        createGameTitle()
        
        // MARK: - Play Button Instruction
        createPlayButtonInstruction()
        
        // MARK: - Settings Button
        let settingsButtonTexture = SKTexture(imageNamed: "settings-button")
        let settingsButton = SKSpriteNode(texture: settingsButtonTexture)
        // Position in top right with some padding
        let padding: CGFloat = 40
        settingsButton.position = CGPoint(x: size.width - padding, y: size.height - padding)
        settingsButton.name = "settingsButton" // Assign a name for touch detection
        settingsButton.setScale(0.4) // Adjust scale as needed
        addChild(settingsButton)
        
        // MARK: - Reset Button
        createResetButton()
        
        // Set up watch session start handler
        watchSession.onStart = { [weak self] in
            self?.animateBreathingGroupAndStartGame()
        }
    }
    
    private func createGameTitle() {
        
        // Add subtle floating animation to the title
        let moveUp = SKAction.moveBy(x: 0, y: 10, duration: 2.0)
        moveUp.timingMode = .easeInEaseOut
        let moveDown = SKAction.moveBy(x: 0, y: -10, duration: 2.0)
        moveDown.timingMode = .easeInEaseOut
        let sequence = SKAction.sequence([moveUp, moveDown])
        let repeatForever = SKAction.repeatForever(sequence)
        
    }
    
    private func createPlayButtonInstruction() {
        // Remove previous group if any
        breathingGroup?.removeFromParent()
        breathingParticles?.removeFromParent()
        let group = SKNode()
        group.zPosition = 10
        breathingGroup = group
        // Set group position to play button center
        let groupCenter = CGPoint(x: (size.width / 2) + 15, y: (size.height * 0.4) + 15)
        group.position = groupCenter
        addChild(group)

        // Create stroke color from #471715
        let strokeColor = UIColor(red: 71/255.0, green: 23/255.0, blue: 21/255.0, alpha: 1.0)
        let kTextFontSize: CGFloat = 48
        // --- Press ---
        let pressPos = CGPoint(x: (size.width / 2 - 100) - groupCenter.x, y: (size.height * 0.4) - groupCenter.y)
        for xOffset in [-2, 2] {
            for yOffset in [-2, 2] {
                let shadow = SKLabelNode(fontNamed: "Jersey15-Regular")
                shadow.text = "Press"
                shadow.fontSize = kTextFontSize
                shadow.fontColor = strokeColor
                shadow.position = CGPoint(x: pressPos.x + CGFloat(xOffset), y: pressPos.y + CGFloat(yOffset))
                shadow.zPosition = 9
                group.addChild(shadow)
            }
        }
        let pressLabel = SKLabelNode(fontNamed: "Jersey15-Regular")
        pressLabel.text = "Press"
        pressLabel.fontSize = kTextFontSize
        pressLabel.fontColor = .white
        pressLabel.position = pressPos
        pressLabel.zPosition = 10
        group.addChild(pressLabel)
        // --- Play Button ---
        let playButton = SKSpriteNode(imageNamed: "play-button")
        playButton.setScale(0.4)
        playButton.position = .zero // Center of group
        playButton.zPosition = 10
        group.addChild(playButton)
        // --- on ---
        let onPos = CGPoint(x: (size.width / 2 + 100) - groupCenter.x, y: (size.height * 0.4) - groupCenter.y)
        for xOffset in [-2, 2] {
            for yOffset in [-2, 2] {
                let shadow = SKLabelNode(fontNamed: "Jersey15-Regular")
                shadow.text = "on"
                shadow.fontSize = kTextFontSize
                shadow.fontColor = strokeColor
                shadow.position = CGPoint(x: onPos.x + CGFloat(xOffset), y: onPos.y + CGFloat(yOffset))
                shadow.zPosition = 9
                group.addChild(shadow)
            }
        }
        let onLabel = SKLabelNode(fontNamed: "Jersey15-Regular")
        onLabel.text = "on"
        onLabel.fontSize = kTextFontSize
        onLabel.fontColor = .white
        onLabel.position = onPos
        onLabel.zPosition = 10
        group.addChild(onLabel)
        // --- your Apple Watch ---
        let watchPos = CGPoint(x: (size.width / 2) - groupCenter.x, y: (size.height * 0.28) - groupCenter.y)
        for xOffset in [-2, 2] {
            for yOffset in [-2, 2] {
                let shadow = SKLabelNode(fontNamed: "Jersey15-Regular")
                shadow.text = "your Apple Watch"
                shadow.fontSize = kTextFontSize
                shadow.fontColor = strokeColor
                shadow.position = CGPoint(x: watchPos.x + CGFloat(xOffset), y: watchPos.y + CGFloat(yOffset))
                shadow.zPosition = 9
                group.addChild(shadow)
            }
        }
        let watchLabel = SKLabelNode(fontNamed: "Jersey15-Regular")
        watchLabel.text = "your Apple Watch"
        watchLabel.fontSize = kTextFontSize
        watchLabel.fontColor = .white
        watchLabel.position = watchPos
        watchLabel.zPosition = 10
        group.addChild(watchLabel)

        // Add breathing animation to the group (subtle)
        let breatheUp = SKAction.scale(to: 1.03, duration: 1.1)
        breatheUp.timingMode = .easeInEaseOut
        let breatheDown = SKAction.scale(to: 0.97, duration: 1.1)
        breatheDown.timingMode = .easeInEaseOut
        let breatheSequence = SKAction.sequence([breatheUp, breatheDown])
        let breatheForever = SKAction.repeatForever(breatheSequence)
        group.run(breatheForever, withKey: "breathing")

        // Add particles (simple sparkle effect)
        if let particles = makeBreathingParticles() {
            particles.position = CGPoint(x: 0, y: (size.height * 0.36) - groupCenter.y)
            particles.zPosition = 20
            group.addChild(particles)
            breathingParticles = particles
        }
    }
    
    private func makeBreathingParticles() -> SKEmitterNode? {
        let emitter = SKEmitterNode()
        emitter.particleTexture = SKTexture(imageNamed: "sparkle") // Add a small white sparkle asset
        emitter.particleBirthRate = 8
        emitter.particleLifetime = 1.2
        emitter.particlePositionRange = CGVector(dx: 220, dy: 60)
        emitter.particleSpeed = 18
        emitter.particleSpeedRange = 10
        emitter.particleAlpha = 0.7
        emitter.particleAlphaRange = 0.2
        emitter.particleAlphaSpeed = -0.6
        emitter.particleScale = 0.1
        emitter.particleScaleRange = 0.08
        emitter.particleScaleSpeed = -0.12
        emitter.particleColor = .white
        emitter.particleColorBlendFactor = 1.0
        emitter.particleBlendMode = .add
        emitter.emissionAngleRange = .pi * 2
        return emitter
    }

    private func animateBreathingGroupAndStartGame() {
        guard let group = breathingGroup else {
            startGame()
            return
        }
        // Stop breathing
        group.removeAction(forKey: "breathing")
        // Animate: scale up and fade out
        let scaleUp = SKAction.scale(to: 1.25, duration: 0.35)
        let fadeOut = SKAction.fadeOut(withDuration: 0.35)
        let groupAnim = SKAction.group([scaleUp, fadeOut])
        group.run(groupAnim) { [weak self] in
            group.removeFromParent()
            self?.breathingParticles?.removeFromParent()
            self?.startGame()
        }
        // Animate particles fade out
        breathingParticles?.run(SKAction.fadeOut(withDuration: 0.35))
    }

    private func startGame() {
        // Check if the calorie target has been set
        if !CalorieData.shared.isTargetSet {
            // Show calorie setup scene first
            let calorieSetupScene = SetCaloriesScene(size: size, watchSession: watchSession)
            calorieSetupScene.scaleMode = scaleMode
            let transition = SKTransition.fade(withDuration: 0.5)
            
            // Tell the watch to show calorie setup UI
            watchSession.sendShowCalorieSetup()
            
            view?.presentScene(calorieSetupScene, transition: transition)
        } else {
            // Transition directly to the Game Scene if calorie target is already set
            let gameScene = GameSceneLab(size: size, watchSession: watchSession)
            gameScene.scaleMode = scaleMode
            let transition = SKTransition.fade(withDuration: 0.5)
            view?.presentScene(gameScene, transition: transition)
        }
    }

    // Handle touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodesAtLocation = nodes(at: location)

        for node in nodesAtLocation {
            if node.name == "settingsButton" {
                // Handle settings button tap
                print("Settings button tapped!") // Placeholder action
                break
            } else if node.name == "resetButton" || node.parent?.name == "resetButton" {
                // Directly reset data without confirmation
                CalorieData.shared.resetAllData()
                
                // Add a confirmation flash
                let flash = SKSpriteNode(color: .red, size: CGSize(width: size.width, height: size.height))
                flash.position = CGPoint(x: size.width/2, y: size.height/2)
                flash.zPosition = 2000
                flash.alpha = 0
                addChild(flash)
                
                let fadeIn = SKAction.fadeAlpha(to: 0.3, duration: 0.2)
                let fadeOut = SKAction.fadeAlpha(to: 0, duration: 0.3)
                let sequence = SKAction.sequence([fadeIn, fadeOut, SKAction.removeFromParent()])
                flash.run(sequence)
                break
            }
        }
    }

    private func addBackgroundParticles() {
        let emitter = SKEmitterNode()
        emitter.particleTexture = SKTexture(imageNamed: "bg-sparkle") // Use a soft pixel/sparkle asset
        emitter.particleBirthRate = 2
        emitter.particleLifetime = 6
        emitter.particlePositionRange = CGVector(dx: size.width, dy: size.height * 0.7)
        emitter.particleSpeed = 10
        emitter.particleSpeedRange = 8
        emitter.particleAlpha = 0.18
        emitter.particleAlphaRange = 0.1
        emitter.particleAlphaSpeed = -0.02
        emitter.particleScale = 0.12
        emitter.particleScaleRange = 0.05
        emitter.particleScaleSpeed = -0.01
        emitter.particleColor = .white
        emitter.particleColorBlendFactor = 1.0
        emitter.particleBlendMode = .add
        emitter.position = CGPoint(x: size.width / 2, y: size.height / 2)
        emitter.zPosition = -0.5 // Just above the background, below everything else
        addChild(emitter)
    }

    private func createResetButton() {
        // Create reset button container with background
        let resetContainer = SKNode()
        resetContainer.position = CGPoint(x: 70, y: size.height - 40)
        resetContainer.zPosition = 100
        addChild(resetContainer)
        
        // Button background (rounded rect)
        let background = SKShapeNode(rectOf: CGSize(width: 120, height: 40), cornerRadius: 15)
        background.fillColor = UIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 0.7)
        background.strokeColor = .white
        background.lineWidth = 2
        background.zPosition = 0
        resetContainer.addChild(background)
        
        // Reset text
        let resetText = SKLabelNode(fontNamed: "Jersey15-Regular")
        resetText.text = "RESET DATA"
        resetText.fontSize = 16
        resetText.fontColor = .white
        resetText.position = CGPoint(x: 0, y: -6) // Centering adjustment
        resetText.zPosition = 1
        resetContainer.addChild(resetText)
        
        // Make the entire container interactive
        resetContainer.name = "resetButton"
        
        // Add subtle hover animation
        let scaleUp = SKAction.scale(to: 1.1, duration: 0.5)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.5)
        let pulse = SKAction.sequence([scaleUp, scaleDown])
        let repeatPulse = SKAction.repeatForever(pulse)
        resetContainer.run(repeatPulse)
    }
} 
