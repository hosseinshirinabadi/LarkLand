//
//  OfficeScene.swift
//  LarkLand
//
//  Created by Hossein on 12/16/20.
//

import Foundation
import SpriteKit

func +(left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func -(left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func *(point: CGPoint, scalar: CGFloat) -> CGPoint {
  return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func /(point: CGPoint, scalar: CGFloat) -> CGPoint {
  return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
func sqrt(a: CGFloat) -> CGFloat {
  return CGFloat(sqrtf(Float(a)))
}
#endif

extension CGPoint {
  func length() -> CGFloat {
    return sqrt(x*x + y*y)
  }
  
  func normalized() -> CGPoint {
    return self / length()
  }
}

class OfficeScene: SKScene {
  
    struct PhysicsCategory {
        static let none      : UInt32 = 0
        static let all       : UInt32 = UInt32.max
        static let monster   : UInt32 = 0b1       // 1
        static let projectile: UInt32 = 0b10      // 2
    }
  
    let player = SKSpriteNode(texture: SpriteSheet(texture: SKTexture(imageNamed: "spriteAtlas"), rows: 9, columns: 12, spacing: 0.1, margin: 0.8).textureForColumn(column: Constants.spriteColHossein, row: Constants.spriteRowHossein))
    
    var monstersDestroyed = 0
    
  
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.white
        let positionX = Constants.positionX
        let positionY = Constants.positionY
        currUser.setPosition(positionX: positionX, positionY: positionY)
        currUser.setSprite(spriteRow: Constants.spriteRowHossein, spriteCol: Constants.spriteColHossein)
        currUser.addToDB {}
        player.position = CGPoint(x: size.width * CGFloat(positionX), y: size.height * CGFloat(positionY))
        addChild(player)
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        addFriend()
//    run(SKAction.repeatForever(
//      SKAction.sequence([
//        SKAction.run(addMonster),
//        SKAction.wait(forDuration: 1.0)
//        ])
//    ))
    
  }
  
  
  func addFriend() {
    // Create sprite
    let friend = SKSpriteNode(imageNamed: "monster")
    
    friend.physicsBody = SKPhysicsBody(rectangleOf: friend.size) // 1
    friend.physicsBody?.isDynamic = true // 2
    friend.physicsBody?.categoryBitMask = PhysicsCategory.monster // 3
    friend.physicsBody?.contactTestBitMask = PhysicsCategory.projectile // 4
    friend.physicsBody?.collisionBitMask = PhysicsCategory.none // 5
    
    
    friend.position = CGPoint(x: size.width/2, y: size.height/2)
    
    addChild(friend)
    
    // Determine speed of the monster
//    let actualDuration = random(min: CGFloat(2.0), max: CGFloat(4.0))
    
    // Create the actions
//    let actionMove = SKAction.move(to: CGPoint(x: -monster.size.width/2, y: actualY), duration: TimeInterval(actualDuration))
//    let actionMoveDone = SKAction.removeFromParent()
//    let loseAction = SKAction.run() { [weak self] in
//      guard let `self` = self else { return }
//      let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
////      let gameOverScene = GameOverScene(size: self.size, won: false)
////      self.view?.presentScene(gameOverScene, transition: reveal)
//    }
//    monster.run(SKAction.sequence([actionMove, loseAction, actionMoveDone]))
  }
  
    
    
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    // 1 - Choose one of the touches to work with
    guard let touch = touches.first else {
      return
    }
    
    let touchLocation = touch.location(in: self)
    
    let offset = touchLocation - player.position
    let shootAmount = offset
    let realDest = shootAmount + player.position
    let actionMove = SKAction.move(to: realDest, duration: 2.0)
    var dbCount = 0
    player.run(actionMove)
    Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { timer in
        dbCount += 1
        currUser.setPosition(positionX: Float(self.player.position.x), positionY: Float(self.player.position.y))
        currUser.addToDB{}
        if (dbCount == 10) {
            timer.invalidate()
        }
    }
  }
  
  func projectileDidCollideWithMonster(projectile: SKSpriteNode, monster: SKSpriteNode) {
    print("Hit")
    projectile.removeFromParent()
    monster.removeFromParent()
    
    monstersDestroyed += 1
    if monstersDestroyed > 30 {
    let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
//      let gameOverScene = GameOverScene(size: self.size, won: true)
//      view?.presentScene(gameOverScene, transition: reveal)
    }
  }
}

extension OfficeScene: SKPhysicsContactDelegate {
  func didBegin(_ contact: SKPhysicsContact) {
    var firstBody: SKPhysicsBody
    var secondBody: SKPhysicsBody
    if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
      firstBody = contact.bodyA
      secondBody = contact.bodyB
    } else {
      firstBody = contact.bodyB
      secondBody = contact.bodyA
    }
    
    if ((firstBody.categoryBitMask & PhysicsCategory.monster != 0) &&
      (secondBody.categoryBitMask & PhysicsCategory.projectile != 0)) {
      if let monster = firstBody.node as? SKSpriteNode,
        let projectile = secondBody.node as? SKSpriteNode {
        projectileDidCollideWithMonster(projectile: projectile, monster: monster)
      }
    }
  }
}

class SpriteSheet {
    let texture: SKTexture
    let rows: Int
    let columns: Int
    var margin: CGFloat=0
    var spacing: CGFloat=0
    var frameSize: CGSize {
        return CGSize(width: (self.texture.size().width-(self.margin*2+self.spacing*CGFloat(self.columns-1)))/CGFloat(self.columns),
            height: (self.texture.size().height-(self.margin*2+self.spacing*CGFloat(self.rows-1)))/CGFloat(self.rows))
    }

    init(texture: SKTexture, rows: Int, columns: Int, spacing: CGFloat, margin: CGFloat) {
        self.texture=texture
        self.rows=rows
        self.columns=columns
        self.spacing=spacing
        self.margin=margin

    }

    convenience init(texture: SKTexture, rows: Int, columns: Int) {
        self.init(texture: texture, rows: rows, columns: columns, spacing: 0, margin: 0)
    }

    func textureForColumn(column: Int, row: Int)->SKTexture? {
        if !(0...self.rows ~= row && 0...self.columns ~= column) {
            //location is out of bounds
            return nil
        }

        var textureRect=CGRect(x: self.margin+CGFloat(column)*(self.frameSize.width+self.spacing)-self.spacing,
                               y: self.margin+CGFloat(row)*(self.frameSize.height+self.spacing)-self.spacing,
                               width: self.frameSize.width,
                               height: self.frameSize.height)

        textureRect=CGRect(x: textureRect.origin.x/self.texture.size().width, y: textureRect.origin.y/self.texture.size().height,
            width: textureRect.size.width/self.texture.size().width, height: textureRect.size.height/self.texture.size().height)
        return SKTexture(rect: textureRect, in: self.texture)
    }

}
