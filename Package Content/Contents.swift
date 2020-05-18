
import SpriteKit
import PlaygroundSupport
import UIKit

//canvas
let skView = SKView(frame: .zero)

//screen size
let gameScene = GameScene(size: UIScreen.main.bounds.size)
gameScene.scaleMode = .aspectFill
skView.presentScene(gameScene)
skView.preferredFramesPerSecond = 60

PlaygroundPage.current.liveView = skView
PlaygroundPage.current.wantsFullScreenLiveView = true


