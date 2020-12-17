//
//  LandingView.swift
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

class GameScene: SKScene {
  
    struct PhysicsCategory {
        static let none      : UInt32 = 0
        static let all       : UInt32 = UInt32.max
        static let monster   : UInt32 = 0b1       // 1
        static let projectile: UInt32 = 0b10      // 2
    }
  
  // 1
//    let player = SKSpriteNode(imageNamed: "player")
//    let sheet = SpriteSheet(texture: SKTexture(imageNamed: "spriteAtlas"), rows: 8, columns: 12, spacing: 1, margin: 1)
    let player = SKSpriteNode(texture: SpriteSheet(texture: SKTexture(imageNamed: "spriteAtlas"), rows: 9, columns: 12, spacing: 0.1, margin: 0.8).textureForColumn(column: 8, row: 1))
    var monstersDestroyed = 0
  
  override func didMove(to view: SKView) {
    // 2
    backgroundColor = SKColor.white
    // 3
    player.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
    // 4
    addChild(player)
    
    
    
    physicsWorld.gravity = .zero
    physicsWorld.contactDelegate = self
    
    
    SKAction.run(addMonster)
    
//    run(SKAction.repeatForever(
//      SKAction.sequence([
//        SKAction.run(addMonster),
//        SKAction.wait(forDuration: 1.0)
//        ])
//    ))
    
  }
  
  func random() -> CGFloat {
    return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
  }
  
  func random(min: CGFloat, max: CGFloat) -> CGFloat {
    return random() * (max - min) + min
  }
  
  func addMonster() {
    // Create sprite
    let monster = SKSpriteNode(imageNamed: "monster")
    
    monster.physicsBody = SKPhysicsBody(rectangleOf: monster.size) // 1
    monster.physicsBody?.isDynamic = true // 2
    monster.physicsBody?.categoryBitMask = PhysicsCategory.monster // 3
    monster.physicsBody?.contactTestBitMask = PhysicsCategory.projectile // 4
    monster.physicsBody?.collisionBitMask = PhysicsCategory.none // 5
    
    // Determine where to spawn the monster along the Y axis
    let actualY = random(min: monster.size.height/2, max: size.height - monster.size.height/2)
    
    // Position the monster slightly off-screen along the right edge,
    // and along a random position along the Y axis as calculated above
    monster.position = CGPoint(x: size.width/2, y: size.height/2)
    
    // Add the monster to the scene
    addChild(monster)
    
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
    
    // 2 - Set up initial location of projectile
//    let projectile = SKSpriteNode(imageNamed: "projectile")
//    projectile.position = player.position
    
    
    player.physicsBody?.isDynamic = true
    player.physicsBody?.categoryBitMask = PhysicsCategory.projectile
//    player.physicsBody?.contactTestBitMask = PhysicsCategory.monster
//    player.physicsBody?.collisionBitMask = PhysicsCategory.none
//    player.physicsBody?.usesPreciseCollisionDetection = true
    
    // 3 - Determine offset of location to projectile
    let offset = touchLocation - player.position
    
    // 4 - Bail out if you are shooting down or backwards
//    if offset.x < 0 { return }
    
    // 5 - OK to add now - you've double checked position
//    addChild(projectile)
    
    // 6 - Get the direction of where to shoot
    
    // 7 - Make it shoot far enough to be guaranteed off screen
    let shootAmount = offset
    
    // 8 - Add the shoot amount to the current position
    let realDest = shootAmount + player.position
    
    // 9 - Create the actions
    let actionMove = SKAction.move(to: realDest, duration: 2.0)
//    let actionMoveDone = SKAction.removeFromParent()
    player.run(SKAction.sequence([actionMove]))
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

extension GameScene: SKPhysicsContactDelegate {
  func didBegin(_ contact: SKPhysicsContact) {
    // 1
    var firstBody: SKPhysicsBody
    var secondBody: SKPhysicsBody
    if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
      firstBody = contact.bodyA
      secondBody = contact.bodyB
    } else {
      firstBody = contact.bodyB
      secondBody = contact.bodyA
    }
    
    // 2
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
