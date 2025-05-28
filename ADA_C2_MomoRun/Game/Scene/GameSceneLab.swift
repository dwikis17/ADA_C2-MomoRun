//
//  GameScene.swift
//  ADA_C2_MomoRun
//
//  Created by Dwiki on 16/05/25.
//

import Foundation
import SpriteKit
import WatchConnectivity


final class GameSceneLab: SKScene {
    struct Tile {
        let sprite: SKSpriteNode
        var worldPosition: Vector
        var worldXOffset: Double // For smooth movement
    }
    private var floorTiles: [Tile] = []
    private var grassTiles: [Tile] = []
    private let tileWidth: CGFloat = 32 // Adjust based on your tile size
    private let moveSpeed: Double = Config.gameMoveSpeed // tiles per second
    private var lastUpdateTime: TimeInterval = 0
    private let floorLength = 40
    private let floorWidth = 3
    private var player: SKSpriteNode?
    private var playerY: Int = Config.playerY// Start at row 2
    private var obstacles: [SKSpriteNode] = []
    private var obstacleSpawnTimer: TimeInterval = 0
    private let obstacleSpawnInterval: TimeInterval = Config.obstacleSpawnInterval // seconds
    private let obstacleStartX: Int = 20
    private var isGameOver: Bool = false
    private var restartLabel: SKLabelNode?
    private var boar: SKSpriteNode?
    private var playerZ: Int = 3 // Default ground level
    
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

    private func createPlayer() {
        let playerNode = SKSpriteNode(imageNamed: "run_0") // Start with the first frame
        let position = Vector(x: -3, y: playerY, z: 3)
        let screenVector = convertWorldToScreen(position)
        playerNode.position = CGPoint(x: CGFloat(screenVector.x), y: CGFloat(screenVector.y))
        playerNode.zPosition = CGFloat(convertWorldToZPosition(position))
        // Adjust anchor point to bottom center
        playerNode.anchorPoint = CGPoint(x: 0.5, y: 0.6)
        addChild(playerNode)
        self.player = playerNode

        let playerFrames: [SKTexture] = (1..<6).map { SKTexture(imageNamed: "run_0\($0)") }
        let runAnimation = SKAction.animate(with: playerFrames, timePerFrame: 0.1, resize: false, restore: true)
        let repeatRun = SKAction.repeatForever(runAnimation)
        playerNode.run(repeatRun, withKey: "run")
    }


    
    private func setupBackground() {
        let backgroundNode = SKSpriteNode(imageNamed: "background")
        backgroundNode.position = CGPoint(x: -35, y: 16)
        backgroundNode.zPosition = -1000
        backgroundNode.setScale(0.22) // Zoom out by scaling up the background
        addChild(backgroundNode)
    }

    private func setupGrassTiles() {
        // Bottom border (y = -1)
        for x in -13..<floorLength {
            let sprite = SKSpriteNode(imageNamed: "grass")
            let worldPos = Vector(x: x, y: -1)
            let screenVector = convertWorldToScreen(worldPos)
            sprite.position = CGPoint(x: CGFloat(screenVector.x), y: CGFloat(screenVector.y))
            sprite.zPosition = CGFloat(convertWorldToZPosition(worldPos))
            addChild(sprite)
            grassTiles.append(Tile(sprite: sprite, worldPosition: worldPos, worldXOffset: Double(x)))
        }
        // Top border (y = floorWidth)
        for x in -13..<floorLength {
            let sprite = SKSpriteNode(imageNamed: "grass")
            let worldPos = Vector(x: x, y: floorWidth)
            let screenVector = convertWorldToScreen(worldPos)
            sprite.position = CGPoint(x: CGFloat(screenVector.x), y: CGFloat(screenVector.y))
            sprite.zPosition = CGFloat(convertWorldToZPosition(worldPos))
            addChild(sprite)
            grassTiles.append(Tile(sprite: sprite, worldPosition: worldPos, worldXOffset: Double(x)))
        }
    }

    private func createTree(x: Int) {
        let sprite = SKSpriteNode(imageNamed: "tree")
        let worldPos = Vector(x: x, y: -1, z:-5)
        let screenVector = convertWorldToScreen(worldPos)
        
        // Set anchor point to bottom center of the tree sprite
        sprite.anchorPoint = CGPoint(x: 0.5, y: 0.1)
        
        sprite.position = CGPoint(
            x: CGFloat(screenVector.x),
            y: CGFloat(screenVector.y)
        )
        sprite.zPosition = CGFloat(convertWorldToZPosition(worldPos))
        addChild(sprite)
        grassTiles.append(Tile(sprite: sprite, worldPosition: worldPos, worldXOffset: Double(x)))
    }

    private func createBoar() {
        let boarNode = SKSpriteNode(imageNamed: "boar_0")
        boarNode.anchorPoint = CGPoint(x: 0.5, y: 0.0)
        let boarPosition = Vector(x: -8, y: playerY, z: 3)
        
        let screenVector = convertWorldToScreen(boarPosition)
        let xOffset: CGFloat = 40 // tweak as needed
        let yOffset: CGFloat = -8 // tweak as needed
        boarNode.position = CGPoint(
            x: CGFloat(screenVector.x) + xOffset,
            y: CGFloat(screenVector.y) + yOffset
        )
        boarNode.zPosition = CGFloat(convertWorldToZPosition(boarPosition))
        boarNode.setScale(0.8)
        addChild(boarNode)
        self.boar = boarNode

        // Animation setup
        let boarFrames: [SKTexture] = (0..<4).map { SKTexture(imageNamed: "boar_\($0)") }
        let runAnimation = SKAction.animate(with: boarFrames, timePerFrame: 0.1, resize: false, restore: true)
        let repeatRun = SKAction.repeatForever(runAnimation)
        boarNode.run(repeatRun, withKey: "run")
    }

    private func moveLeft() {
        guard playerY < floorWidth - 1 else { return }
        playerY += 1
        updatePlayerPosition()
    }

    private func createObstacles() {
        let y = [0, 1, 2].randomElement() ?? 0
        let z = Int(3)
        let obstacle = SKSpriteNode(imageNamed: "rock")
        let position = Vector(x: obstacleStartX, y: y, z: z)
        let screenVector = convertWorldToScreen(position)
        obstacle.position = CGPoint(x: CGFloat(screenVector.x), y: CGFloat(Double(screenVector.y)))
        obstacle.zPosition = CGFloat(convertWorldToZPosition(position))
        obstacle.anchorPoint = CGPoint(x: 0.5, y: y == 0 ? 0.5 : (y == 2 ? 0.0 : 0.3))
        obstacle.userData = ["worldX": Double(obstacleStartX), "y": y, "z": z]
        addChild(obstacle)
        obstacles.append(obstacle)
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
        let xOffset: CGFloat = 40 // tweak as needed
        let yOffset: CGFloat = -8 // tweak as needed
        // Move boar to follow player
        if let boarNode = boar {
            let boarPosition = Vector(x: -8, y: playerY, z: 3)
            let boarScreenVector = convertWorldToScreen(boarPosition)
            boarNode.position = CGPoint(
            x: CGFloat(boarScreenVector.x) + xOffset,
            y: CGFloat(boarScreenVector.y) + yOffset
            )        
            boarNode.zPosition = CGFloat(convertWorldToZPosition(boarPosition))
        }
    }

    private func createTiles() {
        for y in 0..<floorWidth {
            for x in -15..<floorLength {
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
        setupGrassTiles()
    }

    private func createCamera() {
        let cameraNode = SKCameraNode()
        let cameraScreenVector = convertWorldToScreen(Vector(x: 0, y: 2))
        cameraNode.position = CGPoint(x: CGFloat(cameraScreenVector.x), y: CGFloat(cameraScreenVector.y))
        cameraNode.setScale(0.4) // Zoom in to make tiles look bigger
        addChild(cameraNode)
        self.camera = cameraNode
    }

    private func createArrowButtons() {
        // Left Arrow
        let leftArrow = SKSpriteNode(imageNamed: "arrow")
        leftArrow.name = "arrow_left"
        leftArrow.setScale(0.5)
        leftArrow.position = CGPoint(x: 60, y: 60)
        leftArrow.zPosition = 1000
        addChild(leftArrow)
        // Right Arrow
        let rightArrow = SKSpriteNode(imageNamed: "arrow")
        rightArrow.name = "arrow_right"
        rightArrow.setScale(0.5)
        rightArrow.position = CGPoint(x: size.width - 60, y: 60)
        rightArrow.zPosition = 1000
        addChild(rightArrow)
    }

    override func didMove(to view: SKView) {
        size = view.frame.size
        scaleMode = .aspectFill
        
        createCamera()
        createTiles()
        createPlayer()  
        createBoar()
        setupBackground()
        createArrowButtons()
        
        // Notify watch that we're in game
        watchSession.sendScreenChange("game")
        
        // Set up watch session handlers
        watchSession.onDirection = { [weak self] direction in
            guard let self = self else { return }
            print("direction: \(direction)")
            if direction == "left" {
                self.moveLeft()
            } else if direction == "right" {
                self.moveRight()
            } else if direction == "jump" {
                self.receiveJumpSignal()
            } else if direction == "crouch" {
                self.receiveCrouchSignal()
            }
        }
        watchSession.onRestart = { [weak self] in
            self?.restartGame()
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

    private func sendMessageToWatch(_ message: String) {
        if WCSession.default.isReachable {
            watchSession.sendToWatch(message: ["info": message])
        }
    }
    
     func restartGame() {
        // Remove all obstacles
        for obstacle in obstacles { obstacle.removeFromParent() }
        obstacles.removeAll()
        // Reset player position
        playerY = 1
        // updatePlayerPosition()
        // Reset timers and state
        obstacleSpawnTimer = 0
        isGameOver = false
        // Remove restart label if present
        restartLabel?.removeFromParent()
        restartLabel = nil
        lastUpdateTime = 0
        
        // Notify watch that we're back in game
        watchSession.sendScreenChange("game")
    }

    override func update(_ currentTime: TimeInterval) {
        guard !isGameOver else { return }
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
        
        // Animate grass border tiles like floor tiles
        for i in 0..<grassTiles.count {
            grassTiles[i].worldXOffset -= moveSpeed * deltaTime
            if grassTiles[i].worldXOffset < -13 {
                let y = grassTiles[i].worldPosition.y
                let maxX = grassTiles
                    .filter { $0.worldPosition.y == y }
                    .map { $0.worldXOffset }
                    .max() ?? 0
                grassTiles[i].worldXOffset = maxX + 1
            }
            grassTiles[i].worldPosition = Vector(x: Int(floor(grassTiles[i].worldXOffset)), y: grassTiles[i].worldPosition.y)
        }
        
        // Update sprite positions (use smooth Double for rendering)
        for tile in floorTiles {
            let pos = convertWorldToScreenSmooth(tile.worldXOffset, tile.worldPosition.y)
            tile.sprite.position = pos
            tile.sprite.zPosition = -Double(pos.y)
        }
        for tile in grassTiles {
            let pos = convertWorldToScreenSmooth(tile.worldXOffset, tile.worldPosition.y)
            tile.sprite.position = pos
            tile.sprite.zPosition = -Double(pos.y)
        }

        // --- Obstacle logic ---
        var didCollide = false
        for obstacle in obstacles {
            guard let userData = obstacle.userData,
                  let y = userData["y"] as? Int,
                  let z = userData["z"] as? Int,
                  let worldX = userData["worldX"] as? Double else { continue }
            let newWorldX = worldX - moveSpeed * deltaTime
            obstacle.userData?["worldX"] = newWorldX
            let pos = convertWorldToScreenSmooth(newWorldX, y)
            obstacle.position = pos
            let zPos = convertWorldToZPosition(Vector(x: Int(newWorldX), y: y, z: z))
            obstacle.zPosition = CGFloat(zPos)
    
            // Collision check: player is always at (-3, playerY, 3)
            if Int(round(newWorldX)) == -3 && y == playerY && z == 3 && playerZ == 3 {
                didCollide = true
            }
        }
        // Remove obstacles that are off screen
        obstacles.removeAll { obstacle in
            if let worldX = obstacle.userData?["worldX"] as? Double {
                return worldX < -13
            }
            return false
        }
        // Spawn new obstacles at random intervals
        obstacleSpawnTimer += deltaTime
        if obstacleSpawnTimer >= obstacleSpawnInterval {
            obstacleSpawnTimer = 0
            createObstacles()
        }
        // If collision, stop the game and tint player red
        if didCollide {
            sendMessageToWatch("Game Over")
            watchSession.sendScreenChange("gameOver")
            isGameOver = true
            player?.color = .red
            player?.colorBlendFactor = 0.7
            // Show restart label
            if restartLabel == nil {
                let label = SKLabelNode(text: "Tap to Restart")
                label.fontName = "AvenirNext-Bold"
                label.fontSize = 40
                label.fontColor = .white
                label.position = CGPoint(x: size.width/2, y: size.height/2)
                label.zPosition = 2000
                addChild(label)
                restartLabel = label
            }
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isGameOver {
            restartGame()
            return
        }
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = self.nodes(at: location)
        for node in nodes {
           receiveJumpSignal()
        }
    } 

    // Add public methods for watch control
    @objc func moveLeftFromWatch() {
        moveLeft()
    }
    @objc func moveRightFromWatch() {
        moveRight()
    }

    @objc func jumpFromWatch() {
        receiveJumpSignal()
    }

    @objc func crouchFromWatch() {
        receiveCrouchSignal()
    }

   private func receiveJumpSignal() {
    guard let playerNode = player else { return }
    playerNode.removeAction(forKey: "run")
    let jumpFrames: [SKTexture] = (1..<9).map { SKTexture(imageNamed: "jump_0\($0)") }
    let jumpAction = SKAction.animate(with: jumpFrames, timePerFrame: 0.08, resize: false, restore: true)
    let jumpHeight: CGFloat = 10
    let jumpDuration: TimeInterval = 0.2
    let moveUp = SKAction.moveBy(x: 0, y: jumpHeight, duration: jumpDuration)
    moveUp.timingMode = .easeOut
    let moveDown = SKAction.moveBy(x: 0, y: -jumpHeight, duration: jumpDuration)
    moveDown.timingMode = .easeIn
    let jumpMove = SKAction.sequence([moveUp, moveDown])
    // Animate z: set to 4 during jump, then back to 
    let setZUp = SKAction.run { [weak self] in self?.playerZ = 4 }
    let setZDown = SKAction.run { [weak self] in self?.playerZ = 3 }
    let zSequence = SKAction.sequence([setZUp, SKAction.wait(forDuration: jumpDuration * 2), setZDown])

    let group = SKAction.group([jumpAction, jumpMove, zSequence])
    let runFrames: [SKTexture] = (1..<6).map { SKTexture(imageNamed: "run_0\($0)") }
    let runAnimation = SKAction.animate(with: runFrames, timePerFrame: 0.1, resize: false, restore: true)
    let repeatRun = SKAction.repeatForever(runAnimation)
    let sequence = SKAction.sequence([group, repeatRun])
    playerNode.run(sequence, withKey: "run")
    }

    private func receiveCrouchSignal() {
         guard let playerNode = player else { return }
        // Stop current animation
        playerNode.removeAction(forKey: "run")
        // Prepare jump frames
        let crouchFrames: [SKTexture] = (1..<10).map { SKTexture(imageNamed: "roll_0\($0)") }
        let crouchAction = SKAction.animate(with: crouchFrames, timePerFrame: 0.08, resize: false, restore: true)
        // After jump, resume running
        let runFrames: [SKTexture] = (1..<6).map { SKTexture(imageNamed: "run_0\($0)") }
        let runAnimation = SKAction.animate(with: runFrames, timePerFrame: 0.1, resize: false, restore: true)
        let repeatRun = SKAction.repeatForever(runAnimation)
        let sequence = SKAction.sequence([crouchAction, repeatRun])
        playerNode.run(sequence, withKey: "run")
    }
}
