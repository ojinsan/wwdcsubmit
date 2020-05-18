import SpriteKit

extension SKNode {
    func addCircle(radius:CGFloat, edgeColor: UIColor, filled: Bool){
        let circle = SKShapeNode(circleOfRadius: radius)
        circle.zPosition = -3
        circle.strokeColor = edgeColor
        circle.fillColor = filled ? edgeColor.withAlphaComponent(0.3) : .clear
        addChild(circle)
        var category: String
        var theNumber:Character
    }
    
    func addNumberOrOperatorLabel (aNumberOrOperatorValue:String){
        let aNumberOrOperator = SKLabelNode(text: "\(aNumberOrOperatorValue)")
        aNumberOrOperator.zPosition = 10
        aNumberOrOperator.verticalAlignmentMode = .center
        aNumberOrOperator.fontSize = 60
        aNumberOrOperator.fontColor = #colorLiteral(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        addChild(aNumberOrOperator)
    }
}

//utilities
extension GameScene {
    func convertOperatorToChar (operatorCode:Int) -> String {
        switch operatorCode {
        case 1:
            return "+"
        case 2:
            return "-"
        case 3:
            return "*"
        case 4:
            return "/"
        default:
            return "..."
        }
    }
    
    func convertOperatorToInt (operatorCode:String) -> Int {
        switch operatorCode {
        case "+":
            return 1
        case "-":
            return 2
        case "*":
            return 3
        case "/":
            return 4
        default:
            return 0
        }
    }
    
    //helps us calculate the right position randomly
    func positionWithin(range: CGFloat, containerSize: CGFloat) -> CGFloat{
        let partA = CGFloat(arc4random_uniform(100)) / 100.0
        let partB = (containerSize * (1.0 - range) * 0.5)
        let partC = containerSize * range + partB
        return  partA * partC
    }
    
    //help us calculate the distance an object to another object
    func distanceFrom(posA: CGPoint, posB: CGPoint) -> CGFloat {
        let aSquared = (posA.x - posB.x) * (posA.x - posB.x)
        let bSquared = (posA.y - posB.y) * (posA.y - posB.y)
        return sqrt(aSquared + bSquared)
    }
    
    //create new stage of the game
    func newStage(){
        for aNumberOrObject in numbersAndOperators {
            aNumberOrObject.removeFromParent()
        }
        theEquationTemp = [-1001,-1001,-1001]
        
        numbersAndOperatorsValue = [    
            String(Int.random(in:1..<10))
            ,    String(Int.random(in:1..<10))
            ,    String(Int.random(in:1..<10))
            ,    String(Int.random(in:1..<10))
            ,"+","-","/","*"]
        
        numbersAndOperators = []
        for aValue in numbersAndOperatorsValue {
            createNumbersAndOperators(theValue: aValue)
        }
        
        //Set the movement speed when collides 
        for aNumberOrOperator in numbersAndOperators{
            aNumberOrOperator.physicsBody?.applyImpulse(CGVector(dx: CGFloat(arc4random_uniform(maxObjectSpeed)) - (CGFloat(maxObjectSpeed) * 0.8), dy: CGFloat(arc4random_uniform(maxObjectSpeed))-(CGFloat(maxObjectSpeed) * 0.8)))
        }
        
        //Set all starting node active having black color of line
        for aNumberOrOperator in numbersAndOperators {
            let activeObject = aNumberOrOperator
            (activeObject.children.first as? SKShapeNode)?.strokeColor = .black
        }
        
        equationLblTemp = ""
        equationLbl.text = equationLblTemp
        gameOver = false
    }
}
