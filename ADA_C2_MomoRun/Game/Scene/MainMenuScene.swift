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

        // Create gradient background to match splash screen
        createGradientBackground()
        
        // Create the intro animation sequence
        createIntroSequence()
    }
    
    private func createGradientBackground() {
        // Create a gradient background that matches the splash screen
        let gradientTexture = createGradientTexture()
        let gradientBackground = SKSpriteNode(texture: gradientTexture)
        gradientBackground.position = CGPoint(x: size.width / 2, y: size.height / 2)
        gradientBackground.size = size
        gradientBackground.zPosition = -2 // Behind everything else
        addChild(gradientBackground)
    }
    
    private func createGradientTexture() -> SKTexture {
        // Create a texture with the same gradient as splash screen
        // Use screen dimensions to avoid stretching issues
        let textureSize = CGSize(width: size.width, height: size.height)
        UIGraphicsBeginImageContext(textureSize)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return SKTexture()
        }
        
        // Colors to match splash screen: black at top to dark blue-gray at bottom
        let colors = [
            UIColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 1.0).cgColor,
            UIColor.black.cgColor,
            
        ]
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: [0.0, 1.0])!
        
        // Draw gradient from top to bottom (black at top, lighter at bottom)
        context.drawLinearGradient(
            gradient,
            start: CGPoint(x: 0, y: textureSize.height), // Top of screen
            end: CGPoint(x: 0, y: 0), // Bottom of screen
            options: []
        )
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return SKTexture(image: image!)
    }
    
    private func createIntroSequence() {
        // 1. Create but hide background initially
        let backgroundTexture = SKTexture(imageNamed: "main-background")
        let backgroundNode = SKSpriteNode(texture: backgroundTexture)
        backgroundNode.position = CGPoint(x: (size.width / 2), y: (size.height / 2))
        let scale = max(size.width / backgroundNode.size.width, size.height / backgroundNode.size.height)
        backgroundNode.setScale(scale)
        backgroundNode.zPosition = -1
        backgroundNode.alpha = 0 // Hide initially
        addChild(backgroundNode)
        
        // 2. Create logo at center of screen, larger initially
        let logoTexture = SKTexture(imageNamed: "momo-run-logo")
        let logoNode = SKSpriteNode(texture: logoTexture)
        logoNode.position = CGPoint(x: size.width / 2, y: size.height / 2) // Center of screen
        logoNode.setScale(1.2) // Start larger
        logoNode.alpha = 0 // Hidden initially
        logoNode.zPosition = 10
        addChild(logoNode)
        
        // 3. Sequence of animations
        
        // Logo fade in
        let logoFadeIn = SKAction.fadeIn(withDuration: 1.2)
        
        // Logo move and scale to final position
        let logoFinalPosition = CGPoint(x: ((size.width / 2) - 15), y: size.height / 2 + 20)
        let logoMove = SKAction.move(to: logoFinalPosition, duration: 0.8)
        let logoScale = SKAction.scale(to: 0.85, duration: 0.8)
        let logoMoveAndScale = SKAction.group([logoMove, logoScale])
        
        // Background fade in
        let bgFadeIn = SKAction.fadeIn(withDuration: 0.8)
        
        // Create the sequence for the logo
        let logoSequence = SKAction.sequence([
            logoFadeIn,
            SKAction.wait(forDuration: 0.3),
            logoMoveAndScale
        ])
        
        // Run animations
        logoNode.run(logoSequence)
        
        // Wait for logo to finish moving, then fade in background and add other elements
        let waitForLogo = SKAction.wait(forDuration: 2.3) // Matches total logo animation time
        let addElements = SKAction.run { [weak self] in
            guard let self = self else { return }
            
            // Fade in background
            backgroundNode.run(bgFadeIn)
            
            // Add background particles
            self.addBackgroundParticles()
            
            // Add play button
            self.createPlayButton()
            
            // Add settings button
            self.createSettingsButton()
            
            // Add reset button
            // self.createResetButton()
            
            // Set up watch session start handler
            self.watchSession.onStart = { [weak self] in
                self?.startGame()
            }
        }
        
        let finalSequence = SKAction.sequence([waitForLogo, addElements])
        run(finalSequence)
    }
    
    private func createSettingsButton() {
        let settingsButtonTexture = SKTexture(imageNamed: "set-goal-button")
        let settingsButton = SKSpriteNode(texture: settingsButtonTexture)
        let padding: CGFloat = 40
        settingsButton.position = CGPoint(x: size.width - padding - 50, y: size.height - padding - 20)
        settingsButton.name = "settingsButton"
        settingsButton.setScale(0.9)
        settingsButton.zPosition = 10
        addChild(settingsButton)
    }

    private func createPlayButton() {
        // Create play button using the asset
        let playButton = SKSpriteNode(imageNamed: "press-play-to-start")
        playButton.name = "playButton"
        playButton.position = CGPoint(x: size.width / 2, y: size.height / 2 - 100) // Position below logo
        playButton.zPosition = 10
        playButton.setScale(0.8)
        playButton.alpha = 0 // Start invisible
        addChild(playButton)
        
        // Fade in the button
        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
        
        // Add breathing animation effect
        let breatheUp = SKAction.scale(to: 0.85, duration: 1.2)
        breatheUp.timingMode = .easeInEaseOut
        let breatheDown = SKAction.scale(to: 0.75, duration: 1.2)
        breatheDown.timingMode = .easeInEaseOut
        let breatheSequence = SKAction.sequence([breatheUp, breatheDown])
        let breatheForever = SKAction.repeatForever(breatheSequence)
        
        // Run fade in, then start breathing
        let sequence = SKAction.sequence([fadeIn, breatheForever])
        playButton.run(sequence)
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

    // Update touch handling for the new play button
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
            } else if node.name == "playButton" {
                // Start the game when play button is tapped
                let scaleUp = SKAction.scale(to: 1.15, duration: 0.15)
                let scaleDown = SKAction.scale(to: 1.0, duration: 0.15)
                let clickSequence = SKAction.sequence([scaleUp, scaleDown])
                
                node.run(clickSequence) { [weak self] in
                    self?.startGame()
                }
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
