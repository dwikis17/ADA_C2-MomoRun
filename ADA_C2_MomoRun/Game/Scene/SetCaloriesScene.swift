import SpriteKit
import Foundation

class SetCaloriesScene: SKScene {
    // Reference to the watch session manager
    private var watchSession: WatchSessionManager
    
    // Properties for UI elements
    private var calorieValue: Int = 0
    private var calorieLabel: SKLabelNode?
    private var doneButton: SKSpriteNode?
    
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
        
        // Setup background
        let backgroundTexture = SKTexture(imageNamed: "main-background")
        let backgroundNode = SKSpriteNode(texture: backgroundTexture)
        backgroundNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        let scale = max(size.width / backgroundNode.size.width, size.height / backgroundNode.size.height)
        backgroundNode.setScale(scale)
        backgroundNode.zPosition = -1
        addChild(backgroundNode)
        
        setupUI()
        
        // Setup watch session handler for calorie changes
        watchSession.onCalorieChange = { [weak self] value in
            self?.updateCalorieValue(value)
        }
        
        // Setup watch session handler for done button
        watchSession.onCalorieDone = { [weak self] in
            self?.saveCalorieTarget()
        }
    }
    
    private func setupUI() {
        // Add board/panel
        let board = SKSpriteNode(imageNamed: "board_2")
        board.position = CGPoint(x: size.width / 2, y: size.height / 2)
        board.zPosition = 10
        board.setScale(1)
        addChild(board)
        

        // Add header text at the top
        let headerText = SKLabelNode(fontNamed: "Jersey15-Regular")
        headerText.text = "Press"
        headerText.fontSize = 30
        headerText.fontColor = UIColor(red: 255, green: 255, blue: 255, alpha: 255)
        headerText.position = CGPoint(x: (size.width / 2) - 170, y: size.height - 50)
        headerText.zPosition = 15
        addChild(headerText)
        addStrokeToText(headerText)
        
        let topPlus = SKSpriteNode(imageNamed: "plus")
        topPlus.position = CGPoint(x: (size.width / 2) - 110, y: size.height - 43)
        topPlus.zPosition = 15
        topPlus.setScale(0.5)
        addChild(topPlus)
        
        // Add header text at the top
        let headerText2 = SKLabelNode(fontNamed: "Jersey15-Regular")
        headerText2.text = "to set your Calorie Goal"
        headerText2.fontSize = 30
        headerText2.fontColor = UIColor(red: 255, green: 255, blue: 255, alpha: 255)
        headerText2.position = CGPoint(x: (size.width / 2) + 50, y: size.height - 50)
        headerText2.zPosition = 15
        addChild(headerText2)
        addStrokeToText(headerText2)
        
        let crown = SKSpriteNode(imageNamed: "crown")
        crown.position = CGPoint(x: (size.width / 2) - 25, y: size.height - 75)
        crown.zPosition = 15
        crown.setScale(1)
        addChild(crown)
        
        // Add header text at the top
        let headerText3 = SKLabelNode(fontNamed: "Jersey15-Regular")
        headerText3.text = "or Use your        Watch Crown to"
        headerText3.fontSize = 30
        headerText3.fontColor = UIColor(red: 255, green: 255, blue: 255, alpha: 255)
        headerText3.position = CGPoint(x: (size.width / 2) , y: size.height - 85)
        headerText3.zPosition = 15
        addChild(headerText3)
        addStrokeToText(headerText3)
        
        // Add "SET YOUR CALORIE GOAL" text
        let titleLabel = SKLabelNode(fontNamed: "Jersey15-Regular")
        titleLabel.text = "SET YOUR CALORIE GOAL !"
        titleLabel.fontSize = 28
        titleLabel.fontColor = UIColor(red: 71/255.0, green: 23/255.0, blue: 21/255.0, alpha: 1.0)
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 - 10)
        titleLabel.zPosition = 15
        addChild(titleLabel)
        
        // Add apple icon
        let apple = SKSpriteNode(imageNamed: "apple")
        apple.setScale(1)
        apple.position = CGPoint(x: size.width / 2, y: size.height / 2 + 50)
        apple.zPosition = 15
        addChild(apple)
        
        let plus = SKSpriteNode(imageNamed: "plus")
        plus.setScale(0.5)
        plus.position = CGPoint(x: size.width / 2 + 80, y: size.height / 2 - 40)
        plus.zPosition = 15
        addChild(plus)
        
        
        let minus = SKSpriteNode(imageNamed: "min")
        minus.setScale(0.5)
        minus.position = CGPoint(x: size.width / 2 - 80, y: size.height / 2 - 40)
        minus.zPosition = 15
        addChild(minus)
        
        // Add calorie value label
        calorieLabel = SKLabelNode(fontNamed: "Jersey15-Regular")
        calorieLabel?.text = "0 KCAL"
        calorieLabel?.fontSize = 40
        calorieLabel?.fontColor = UIColor(red: 71/255.0, green: 23/255.0, blue: 21/255.0, alpha: 1.0)
        calorieLabel?.position = CGPoint(x: size.width / 2, y: size.height / 2 - 50)
        calorieLabel?.zPosition = 15
        addChild(calorieLabel!)
        
        // Add horizontal line
        let line = SKSpriteNode(color: UIColor(red: 71/255.0, green: 23/255.0, blue: 21/255.0, alpha: 1.0), size: CGSize(width: 100, height: 3))
        line.position = CGPoint(x: size.width / 2, y: size.height / 2 - 60)
        line.zPosition = 15
        addChild(line)
        
        // Add "Press" text
        let pressLabel = SKLabelNode(fontNamed: "Jersey15-Regular")
        pressLabel.text = "Press"
        pressLabel.fontSize = 30
        pressLabel.fontColor = .white
        pressLabel.position = CGPoint(x: size.width / 2 - 150, y: size.height / 2 - 150)
        pressLabel.zPosition = 15
        addChild(pressLabel)
        
        addStrokeToText(pressLabel)
        
        // Add done button
        doneButton = SKSpriteNode(imageNamed: "board")
        doneButton?.setScale(1)
        doneButton?.position = CGPoint(x: size.width / 2 - 70, y: size.height / 2 - 145)
        doneButton?.zPosition = 15
        doneButton?.name = "doneButton"
        addChild(doneButton!)
        
        // Add "on your Apple Watch when you finished" text
        let finishedLabel = SKLabelNode(fontNamed: "Jersey15-Regular")
        finishedLabel.text = "when you finished"
        finishedLabel.fontSize = 30
        finishedLabel.fontColor = .white
        finishedLabel.position = CGPoint(x: size.width / 2 + 80, y: size.height / 2 - 150)
        finishedLabel.zPosition = 15
        addChild(finishedLabel)
        addStrokeToText(finishedLabel)
    }
    
    // Update the calorie value based on watch input
    func updateCalorieValue(_ value: Int) {
        calorieValue = value
        calorieLabel?.text = "\(value) KCAL"
    }
    
    // Save the calorie target and transition to the game
    func saveCalorieTarget() {
        // Save the calorie target to the shared model
        CalorieData.shared.setTarget(calorieValue)
        
        // Transition to game scene
        let gameScene = GameSceneLab(size: size, watchSession: watchSession)
        gameScene.scaleMode = scaleMode
        let transition = SKTransition.fade(withDuration: 0.5)
        view?.presentScene(gameScene, transition: transition)
    }
    
    // Handle touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = self.nodes(at: location)
        
        for node in nodes {
            if node.name == "doneButton" {
                saveCalorieTarget()
            }
        }
    }
    
    // Function to add stroke effect to text nodes
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
