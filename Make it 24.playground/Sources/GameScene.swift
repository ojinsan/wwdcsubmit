
import SpriteKit

public class GameScene : SKScene, SKPhysicsContactDelegate{
    //Variables
    let numberOfNumbersAndOperators = 8
    let maxObjectSpeed:UInt32 = 50
    var objectLenght: CGFloat = 1.0
    var i: Double = 1.0
    
    var numbersAndOperators = [SKSpriteNode]()
    
    var numbersAndOperatorsValue = [    
        String(Int.random(in:1..<10))
        ,    String(Int.random(in:1..<10))
        ,    String(Int.random(in:1..<10))
        ,    String(Int.random(in:1..<10))
        ,"+","-","/","*"]
    
    var theResult:Int = -99
    var theEquationTemp = [-1001,-1001,-1001]
    //index0 -> first number
    //index1 -> operator code, 1:+ 2:- 3:* 4:/
    //index2 -> second number
    
    var player: SKSpriteNode!
    var gameOver = false
    var movingPlayer = false
    var offset:CGPoint!
    var equationLbl: SKLabelNode!
    var equationLblTemp: String = ""
    var messageLbl:SKLabelNode!
    var score:Int = 0
    var scoreLbl:SKLabelNode!
    var messageContents = ["Hello! Welcome to MakeIt24",
                           "In this game you'll have to make the result of a number of 24,",
                           "by catching all the existing numbers and some of operators needed.",
                           "Catch it one by one, to make a basic equation",
                           "You will generate a new number as a result once you catch two numbers and one operator!",
                           "Use the new number to your next equation.",
                           "You can use the operators as many as you can,",
                           "but be careful, when you catch a number, it will be disappearing,",
                           "as you catch it...",
                           "If you feel stucked, just make the result near the value of 24,",
                           "so you'll have less penalty score :p",
                           "try to beat more rounds and get the highest score within 3 minutes of the game",
                           " "]
    
    
    //program utama
    public override func didMove(to view: SKView) {
        objectLenght /= 2.0 //lama lama makin sempit jaraknya
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsBody?.friction = 0.0
        physicsWorld.contactDelegate = self
        
        //Background Setup
        let bg = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName: "Screen Shot 2020-05-17 at 14.04.12.png")))
        bg.setScale(1.0)
        bg.zPosition = 2
        bg.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(bg)
        
        //Create a Player Node
        player = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName: "Screen_Shot_2020-05-18_at_09-removebg-preview.png")), color: .clear, size: CGSize(width: size.width * 0.05, height: size.width * 0.05))
        player.position = CGPoint(x: frame.midX, y: frame.midY)
        player.addCircle(radius: player.size.width * (0.5 + objectLenght), edgeColor: .green, filled: true)
        addChild(player)
        //more on player
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width * (0.5 + objectLenght))
        player.physicsBody?.isDynamic = false
        
        player.physicsBody?.categoryBitMask = Bitmasks.player
        player.physicsBody?.contactTestBitMask = Bitmasks.activeObject
        
        //Equation Label to let user know the existing equation
        equationLbl = SKLabelNode(text: equationLblTemp)
        equationLbl.fontSize = 70.0
        equationLbl.position = CGPoint(x: 600, y: 525)
        equationLbl.zPosition = 3.0
        equationLbl.fontColor = #colorLiteral(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        addChild(equationLbl)
        equationLbl.text = ""
        
        //score label
        scoreLbl = SKLabelNode(text: equationLblTemp)
        scoreLbl.fontSize = 70.0
        scoreLbl.position = CGPoint(x: 75, y: 525)
        scoreLbl.zPosition = 3.0
        scoreLbl.fontColor = #colorLiteral(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        addChild(scoreLbl)
        scoreLbl.text = "Your Score: 0"
        
        //greeting message label
        messageLbl = SKLabelNode(text: equationLblTemp)
        messageLbl.fontSize = 70.0
        messageLbl.position = CGPoint(x: frame.midX, y: frame.midY)
        messageLbl.zPosition = 3.0
        messageLbl.fontColor = #colorLiteral(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        messageLbl.preferredMaxLayoutWidth = 800; 
        messageLbl.lineBreakMode = NSLineBreakMode.byWordWrapping
        messageLbl.numberOfLines = 2
        addChild(messageLbl)
        
        //     Create a new stage
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            bg.zPosition = -10
            self.newStage()
        }
        
        //set a timer (2 minutes) for game over
        DispatchQueue.main.asyncAfter(deadline: .now() + 120.0) {
            self.gameOver = true
            bg.zPosition = 2
            self.messageLbl.text = "Game Over, your score is \(self.score)"
        }
    }
    
    //Generate an Operator or a Number
    func createNumbersAndOperators(theValue:String){
        //set up the node appearance
        let aNumberOrOperatorNode = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName: "Picture1.png")), color: .clear, size: CGSize(width: size.width * 0.07, height: size.width * 0.07))
        aNumberOrOperatorNode.position = CGPoint(x: positionWithin(range: 0.8, containerSize: size.width), y: positionWithin(range: 0.8, containerSize: size.height-100))
        aNumberOrOperatorNode.addCircle(radius: player.size.width * (0.5 + objectLenght), edgeColor: .lightGray, filled: false)
        aNumberOrOperatorNode.addNumberOrOperatorLabel(aNumberOrOperatorValue:theValue)
        
        //Set the initial position so they wont be overwrited in position
        while (distanceFrom(posA: aNumberOrOperatorNode.position, posB: player.position) < aNumberOrOperatorNode.size.width * objectLenght * 5) {
            aNumberOrOperatorNode.position = CGPoint(x: positionWithin(range: 0.8, containerSize: size.width), y: positionWithin(range: 0.8, containerSize: size.height))
        }
        
        //set the value for each node, it can be a number or an operator.
        aNumberOrOperatorNode.name = theValue
        if aNumberOrOperatorNode.name == "+" || aNumberOrOperatorNode.name == "-" || aNumberOrOperatorNode.name == "*" || aNumberOrOperatorNode.name == "/" {
            aNumberOrOperatorNode.texture = SKTexture(image: #imageLiteral(resourceName: "Picture2.png"))
        }
        
        //generate the object node to the screen, and save this to the array
        addChild(aNumberOrOperatorNode)
        numbersAndOperators.append(aNumberOrOperatorNode)
        
        //the node object's physics body appereance
        aNumberOrOperatorNode.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width * (0.5 + objectLenght))
        aNumberOrOperatorNode.physicsBody?.affectedByGravity = false
        aNumberOrOperatorNode.physicsBody?.friction = 10.0
        aNumberOrOperatorNode.physicsBody?.angularDamping = 0.0
        aNumberOrOperatorNode.physicsBody?.restitution = 1.1
        aNumberOrOperatorNode.physicsBody?.allowsRotation = false
        aNumberOrOperatorNode.physicsBody?.categoryBitMask = Bitmasks.activeObject  //set the bitmask of the object node
        aNumberOrOperatorNode.physicsBody?.contactTestBitMask = Bitmasks.activeObject //set an another object type that will trigger the object when contacting
    }
    
    //Set the action when user touchs the screen --Movement
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !gameOver else { return }
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        let touchedNodes = nodes(at:touchLocation)
        
        //active the player movement when user clicks the player Node
        for node in touchedNodes{
            if node == player {
                movingPlayer = true
                offset = CGPoint(x: touchLocation.x - player.position.x, y: touchLocation.y - player.position.y)
            }
        }
    }
    
    //Set the action when user moves the --Movement
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !gameOver && movingPlayer else {return}
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        let newPlayerPosition = CGPoint(x: touchLocation.x - offset.x, y: touchLocation.y - offset.y)
        
        player.run(SKAction.move(to: newPlayerPosition, duration: 0.01)) //for smoothening
    }
    
    //Set the action when user touchs the screen --Movement
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        movingPlayer = false
    }
    
    //Set the action when the Player Node hit another object
    public func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask == Bitmasks.player  {
            aCollision(anObject: contact.bodyB.node as! SKSpriteNode)
        }else if contact.bodyB.categoryBitMask == Bitmasks.player{
            aCollision(anObject: contact.bodyA.node as! SKSpriteNode)
        }
    }
    
    //Trigger some action when a player hit an object (number or operator)
    func aCollision (anObject: SKSpriteNode){
        //if the object is a number, just put it on first and third element in equation
        if anObject.name != "+" && anObject.name != "-" && anObject.name != "*" && anObject.name != "/" {
            let a:Int? = Int(anObject.name!)
            if theEquationTemp[0] == -1001 {
                theEquationTemp[0] = a ?? theEquationTemp[0]
                anObject.removeFromParent()
                equationLblTemp = "\(String(theEquationTemp[0])) \(convertOperatorToChar(operatorCode: theEquationTemp[1]))"
                equationLbl.text = "\(equationLblTemp)"
            }else if theEquationTemp[2] == -1001{
                theEquationTemp[2] = a ?? theEquationTemp[2]
                anObject.removeFromParent()
                equationLblTemp = "\(String(theEquationTemp[0])) \(convertOperatorToChar(operatorCode: theEquationTemp[1])) \(String(theEquationTemp[2]))"
                equationLbl.text = "\(equationLblTemp)"
            }else {
                //find the operator!
                equationLbl.text = "\(equationLblTemp) \n Find and operator!"
            }
        } else{
            //if object is not a number, put the second element in the equation
            theEquationTemp[1] = convertOperatorToInt(operatorCode: anObject.name!)
            if theEquationTemp [2] != -1001 {
                equationLblTemp = "\(String(theEquationTemp[0])) \(convertOperatorToChar(operatorCode: theEquationTemp[1])) \(String(theEquationTemp[2]))"
            }else if theEquationTemp[0] != -1001{
                equationLblTemp = "\(String(theEquationTemp[0])) \(convertOperatorToChar(operatorCode: theEquationTemp[1]))"
            }else {
                equationLblTemp = anObject.name ?? ""
            }
            equationLbl.text = equationLblTemp
        }
        
        //if the equation is completed, generate a result
        if theEquationTemp[0] != -1001 && theEquationTemp[1] != -1001 && theEquationTemp[2] != -1001 {
            switch theEquationTemp[1] {
            case 1:
                theResult = theEquationTemp[0]+theEquationTemp[2]
            case 2:
                theResult = theEquationTemp[0]-theEquationTemp[2]
            case 3:
                theResult = theEquationTemp[0]*theEquationTemp[2]
            case 4:
                if theEquationTemp[2] != -1001{
                    theResult = theEquationTemp[0]/theEquationTemp[2]
                } else {
                    theResult = 0
                }
            default:
                print("Error, just go back!")
            }
            
            //generate a new number as the result of previous equation
            createNumbersAndOperators(theValue: String(theResult))
            numbersAndOperators[numbersAndOperators.count-1].physicsBody?.categoryBitMask = Bitmasks.activeObject 
            (numbersAndOperators[numbersAndOperators.count-1].children.first as? SKShapeNode)?.strokeColor = .blue
            theEquationTemp = [-1001,-1001,-1001] //restart the equation array
            
            //put the text of the result
            equationLbl.text = "\(equationLblTemp) = \(theResult)"
            
            //wait 0.75 second until we refresh the display for the next equation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                self.equationLblTemp = ""
                self.equationLbl.text = ""
            }
            
            //win and lose state of an stage
            if numbersAndOperators.count == 11 && numbersAndOperators[10].name == "24" {
                equationLbl.text = "You win this stage! +24"
                score += 5
                scoreLbl.text = String(score)
                gameOver = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.newStage()
                }
            } else if numbersAndOperators.count == 11 {
                equationLbl.text = "You lose this stage! -\(abs(24-theResult))"
                score -= abs(24-theResult)
                gameOver = true
                scoreLbl.text = String(score)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.newStage()
                }
            }
        }
    }
}
