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
        let board = SKSpriteNode(imageNamed: "board")
        board.position = CGPoint(x: size.width / 2, y: size.height / 2)
        board.zPosition = 10
        addChild(board)
        
        // Add header text at the top
        let headerText = SKLabelNode(fontNamed: "Jersey15-Regular")
        headerText.text = "USE YOUR WATCH CROWN TO ADJUST CALORIE GOAL"
        headerText.fontSize = 20
        headerText.fontColor = UIColor(red: 71/255.0, green: 23/255.0, blue: 21/255.0, alpha: 1.0)
        headerText.position = CGPoint(x: size.width / 2, y: size.height - 50)
        headerText.zPosition = 15
        addChild(headerText)
        
        // Add "SET YOUR CALORIE GOAL" text
        let titleLabel = SKLabelNode(fontNamed: "Jersey15-Regular")
        titleLabel.text = "SET YOUR CALORIE GOAL"
        titleLabel.fontSize = 30
        titleLabel.fontColor = UIColor(red: 71/255.0, green: 23/255.0, blue: 21/255.0, alpha: 1.0)
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 + 50)
        titleLabel.zPosition = 15
        addChild(titleLabel)
        
        // Add apple icon
        let apple = SKSpriteNode(imageNamed: "apple")
        apple.setScale(0.5)
        apple.position = CGPoint(x: size.width / 2, y: size.height / 2 + 100)
        apple.zPosition = 15
        addChild(apple)
        
        // Add calorie value label
        calorieLabel = SKLabelNode(fontNamed: "Jersey15-Regular")
        calorieLabel?.text = "0 KCAL"
        calorieLabel?.fontSize = 40
        calorieLabel?.fontColor = UIColor(red: 71/255.0, green: 23/255.0, blue: 21/255.0, alpha: 1.0)
        calorieLabel?.position = CGPoint(x: size.width / 2, y: size.height / 2)
        calorieLabel?.zPosition = 15
        addChild(calorieLabel!)
        
        // Add horizontal line
        let line = SKSpriteNode(color: UIColor(red: 71/255.0, green: 23/255.0, blue: 21/255.0, alpha: 1.0), size: CGSize(width: 200, height: 2))
        line.position = CGPoint(x: size.width / 2, y: size.height / 2 - 20)
        line.zPosition = 15
        addChild(line)
        
        // Add "Press" text
        let pressLabel = SKLabelNode(fontNamed: "Jersey15-Regular")
        pressLabel.text = "Press"
        pressLabel.fontSize = 25
        pressLabel.fontColor = .white
        pressLabel.position = CGPoint(x: size.width / 2 - 100, y: size.height / 2 - 80)
        pressLabel.zPosition = 15
        addChild(pressLabel)
        
        // Add done button
        doneButton = SKSpriteNode(imageNamed: "done-button")
        doneButton?.setScale(0.5)
        doneButton?.position = CGPoint(x: size.width / 2, y: size.height / 2 - 80)
        doneButton?.zPosition = 15
        doneButton?.name = "doneButton"
        addChild(doneButton!)
        
        // Add "on your Apple Watch when you finished" text
        let finishedLabel = SKLabelNode(fontNamed: "Jersey15-Regular")
        finishedLabel.text = "on your Apple Watch when you finished"
        finishedLabel.fontSize = 25
        finishedLabel.fontColor = .white
        finishedLabel.position = CGPoint(x: size.width / 2 + 150, y: size.height / 2 - 80)
        finishedLabel.zPosition = 15
        addChild(finishedLabel)
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
} 