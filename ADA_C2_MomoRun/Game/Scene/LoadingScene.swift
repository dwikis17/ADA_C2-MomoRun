import SpriteKit
import Foundation

class LoadingScene: SKScene {
    // Reference to the watch session manager
    private var watchSession: WatchSessionManager
    
    // Properties for UI elements
    private var loadingLabel: SKLabelNode?
    private var runnerSprite: SKSpriteNode?
    
    // Initialize with watch session
    init(size: CGSize, watchSession: WatchSessionManager) {
        self.watchSession = watchSession
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        size = view.frame.size
        scaleMode = .aspectFill
        
        // Setup black background
        backgroundColor = .black
        
        setupUI()
        startAnimations()
        
    
        // Transition to game after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.transitionToGame()
        }
    }
    
    private func setupUI() {
        // Add loading text
        loadingLabel = SKLabelNode(fontNamed: "Jersey15-Regular")
        loadingLabel?.text = "Loading"
        loadingLabel?.fontSize = 36
        loadingLabel?.fontColor = .white
        loadingLabel?.position = CGPoint(x: size.width - 130, y: 50 )
        loadingLabel?.zPosition = 10
        
        addStrokeToText(loadingLabel!)
        addChild(loadingLabel!)
        
        // Add running girl sprite
        runnerSprite = SKSpriteNode(imageNamed: "player_0")
        runnerSprite?.position = CGPoint(x: size.width -  230, y: size.height/2 - 110)
        runnerSprite?.setScale(1) // Make it bigger for visibility
        runnerSprite?.zPosition = 10
        addChild(runnerSprite!)
    }
    
    private func startAnimations() {
        // Start loading text animation
        startLoadingTextAnimation()
        
        // Start running animation
        startRunningAnimation()
    }
    
    private func startLoadingTextAnimation() {
        let loadingTexts = ["Loading", "Loading.", "Loading..", "Loading..."]
        var currentIndex = 0
        
        let updateText = SKAction.run { [weak self] in
            guard let self = self, let loadingLabel = self.loadingLabel else { return }
            
            // Remove existing stroke labels
            self.removeStrokeLabels(for: loadingLabel)
            
            // Update the main text
            loadingLabel.text = loadingTexts[currentIndex]
            
            // Add new stroke with updated text
            self.addStrokeToText(loadingLabel)
            
            currentIndex = (currentIndex + 1) % loadingTexts.count
        }
        
        let wait = SKAction.wait(forDuration: 0.5)
        let sequence = SKAction.sequence([updateText, wait])
        let repeatForever = SKAction.repeatForever(sequence)
        
        loadingLabel?.run(repeatForever)
    }
    
    // Helper function to remove existing stroke labels
    private func removeStrokeLabels(for textNode: SKLabelNode) {
        // Find and remove all stroke labels that are positioned around this text node
        let strokeNodes = children.filter { node in
            guard let strokeLabel = node as? SKLabelNode else { return false }
            // Check if this is a stroke label (positioned slightly offset from main text)
            let xDiff = abs(strokeLabel.position.x - textNode.position.x)
            let yDiff = abs(strokeLabel.position.y - textNode.position.y)
            return strokeLabel.zPosition == textNode.zPosition - 1 && 
                   strokeLabel.text == textNode.text &&
                   (xDiff <= 3 && yDiff <= 3) && // Within stroke offset range
                   strokeLabel != textNode // Not the main text node
        }
        
        strokeNodes.forEach { $0.removeFromParent() }
    }
    
    private func startRunningAnimation() {
        // Create running animation frames
        let runningFrames: [SKTexture] = (0..<9).map { SKTexture(imageNamed: "player_\($0)") }
        let runningAnimation = SKAction.animate(with: runningFrames, timePerFrame: 0.1, resize: false, restore: true)
        let repeatRunning = SKAction.repeatForever(runningAnimation)
        
        runnerSprite?.run(repeatRunning)
    }
    
    private func transitionToGame() {
        // Transition to game scene
        let gameScene = GameSceneLab(size: size, watchSession: watchSession)
        gameScene.scaleMode = scaleMode
        let transition = SKTransition.fade(withDuration: 0.5)
        view?.presentScene(gameScene, transition: transition)
    }
    
    func addStrokeToText(_ textNode: SKLabelNode, strokeColor: UIColor = UIColor(red: 71/255.0, green: 23/255.0, blue: 21/255.0, alpha: 1.0), strokeWidth: CGFloat = 2.0) {
        // Create stroke offsets for 8-directional stroke
        let strokeOffsets: [(CGFloat, CGFloat)] = [
            (-strokeWidth, -strokeWidth), // Bottom-left
            (0, -strokeWidth),            // Bottom
            (strokeWidth, -strokeWidth),  // Bottom-right
            (-strokeWidth, 0),            // Left
            (strokeWidth, 0),             // Right
            (-strokeWidth, strokeWidth),  // Top-left
            (0, strokeWidth),             // Top
            (strokeWidth, strokeWidth)    // Top-right
        ]
        
        // Create stroke labels for each direction
        for (offsetX, offsetY) in strokeOffsets {
            let strokeLabel = SKLabelNode(fontNamed: textNode.fontName)
            strokeLabel.text = textNode.text
            strokeLabel.fontSize = textNode.fontSize
            strokeLabel.fontColor = strokeColor
            strokeLabel.position = CGPoint(
                x: textNode.position.x + offsetX,
                y: textNode.position.y + offsetY
            )
            strokeLabel.zPosition = textNode.zPosition - 1 // Behind the main text
            strokeLabel.horizontalAlignmentMode = textNode.horizontalAlignmentMode
            strokeLabel.verticalAlignmentMode = textNode.verticalAlignmentMode
            
            // Add stroke label to the same parent as the text node
            if let parent = textNode.parent {
                parent.addChild(strokeLabel)
            } else {
                addChild(strokeLabel)
            }
        }
    }
}
