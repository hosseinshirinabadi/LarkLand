//
//  OfficeScene.swift
//  LarkLand
//
//  Created by Hossein on 12/16/20.
//

import Foundation
import SpriteKit

var userDict = [String:User]()
var friendNodeDict = [String:SKSpriteNode]()

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
let screenWidth = UIScreen.main.bounds.width
let screenHeight = UIScreen.main.bounds.height



class OfficeScene: SKScene {
  
    struct PhysicsCategory {
        static let none      : UInt32 = 0
        static let all       : UInt32 = UInt32.max
        static let monster   : UInt32 = 0b1       // 1
        static let projectile: UInt32 = 0b10      // 2
    }
    
    let player = SKSpriteNode(texture: SpriteSheet(texture: SKTexture(imageNamed: "spriteAtlas"), rows: 9, columns: 12, spacing: 0.1, margin: 0.8).textureForColumn(column: currUser.userData.spriteCol!, row: currUser.userData.spriteRow!))
    var timer: Timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(detectProximity), userInfo: nil, repeats: true)
    
    func setUpListener() {
        db.collection("users").addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            snapshot.documentChanges.forEach { diff in
                let dbUser = diff.document.data()
                let name = dbUser["name"] as! String
                let positionX = dbUser["positionX"] as! Float
                let positionY = dbUser["positionY"] as! Float
                let spriteCol = dbUser["spriteCol"] as! Int
                let spriteRow = dbUser["spriteRow"] as! Int
//                if (diff.type == .added && currUser.userData.name != name) {
//                    userDict[name] = User(userID: name, name: name, positionX: positionX, positionY: positionY, spriteRow: spriteRow, spriteCol: spriteCol)
//                    self.addFriend(name: name)
//                }
                if(diff.type == .modified && currUser.userData.name != name) {
                    self.moveFriend(user: userDict[name]!, positionX: positionX, positionY: positionY)
                }
            }
        }
        
    }
    
    
    func addUsers() {
        for (name, _) in userDict {
            addFriend(name: name)
        }
    }
    
    @objc func areTheyCloseFunction() {
        var closePeople: [SKSpriteNode] = []
        for (name, sprite) in friendNodeDict {
            
        }
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.white
        let positionX: Float!
        let positionY: Float!
        addUsers()
        setUpListener()
        
        //checks whether the users are in proximity of eachother
        Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(areTheyCloseFunction), userInfo: nil, repeats: true)
        
        if (currUser.userData.positionX == nil || currUser.userData.positionY == nil) {
            print("couldn't find user position")
            positionX = Constants.positionX
            positionY = Constants.positionY
            currUser.setPosition(positionX: positionX, positionY: positionY)
            currUser.setSprite(spriteRow: currUser.userData.spriteRow!, spriteCol: currUser.userData.spriteCol!)
            currUser.addToDB {}
        } else {
            positionX = currUser.userData.positionX!
            positionY = currUser.userData.positionY!
            print(currUser.userData.spriteRow!)
            print(currUser.userData.spriteCol!)
            currUser.setSprite(spriteRow: currUser.userData.spriteRow!, spriteCol: currUser.userData.spriteCol!)
        }
        
        player.position = CGPoint(x: size.width * CGFloat(positionX), y: size.height * CGFloat(positionY))
        addChild(player)
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
//        run(SKAction.repeatForever(
//              SKAction.sequence([
//                SKAction.run(detectProximity),
//                SKAction.wait(forDuration: 0.1)
//                ])
//        ))
    }
    
    @objc func detectProximity() {
//        var closePeople: [SKSpriteNode] = []
        for (name, sprite) in friendNodeDict {
            if (player.position - sprite.position).length() < 50 {
                print(name + " is close to you")
                timer.invalidate()
            } else {
                timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(areTheyCloseFunction), userInfo: nil, repeats: true)
            }
        }
    }
  
    func loadOffice() {
        
    }
  
    func addFriend(name: String) {
    // Create sprite
        let user = userDict[name]
        let friend = SKSpriteNode(texture: SpriteSheet(texture: SKTexture(imageNamed: "spriteAtlas"), rows: 9, columns: 12, spacing: 0.1, margin: 0.8).textureForColumn(column: user!.userData.spriteCol!, row: user!.userData.spriteRow!))
        
        friend.physicsBody = SKPhysicsBody(rectangleOf: friend.size) // 1
        friend.physicsBody?.isDynamic = true // 2
        friend.physicsBody?.categoryBitMask = PhysicsCategory.monster // 3
        friend.physicsBody?.contactTestBitMask = PhysicsCategory.projectile // 4
        friend.physicsBody?.collisionBitMask = PhysicsCategory.none // 5
        
        friend.position = CGPoint(x: size.width * CGFloat((user?.userData.positionX)!), y: size.height * CGFloat((user?.userData.positionY)!))
        
        addChild(friend)
        friendNodeDict[name] = friend
    }
  
    
    func moveFriend(user: User, positionX: Float, positionY: Float) {
        let previousPoint = CGPoint(x: size.width * CGFloat((user.userData.positionX)!), y: size.height * CGFloat((user.userData.positionY)!))
        let newPoint = CGPoint(x: size.width * CGFloat(positionX), y: size.height * CGFloat(positionY))
        let offset = newPoint - previousPoint
        let shootAmount = offset
        let realDest = shootAmount + previousPoint
        let movementTime = Float(realDest.length()) / Constants.speed
        let actionMove = SKAction.move(to: realDest, duration: TimeInterval(movementTime))
        let friend = friendNodeDict[user.userData.name!]
        friend!.run(actionMove)
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
    let movementTime = Float(realDest.length()) / Constants.speed
    let actionMove = SKAction.move(to: realDest, duration: TimeInterval(movementTime))
    var dbCount = 0
    player.run(actionMove)
    Timer.scheduledTimer(withTimeInterval: TimeInterval(movementTime / Float(Constants.numSteps)), repeats: true) { timer in
        dbCount += 1
        currUser.setPosition(positionX: Float(self.player.position.x / screenWidth), positionY: Float(self.player.position.y / screenHeight))
        currUser.addToDB{}
        if (dbCount == Constants.numSteps) {
            timer.invalidate()
        }
    }
  }
  
  func projectileDidCollideWithMonster(projectile: SKSpriteNode, monster: SKSpriteNode) {
    print("Hit")
    projectile.removeFromParent()
    monster.removeFromParent()
    
    var monstersDestroyed = 1
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
