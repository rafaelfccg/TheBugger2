//
//  TBMegaLaserNode.swift
//  TheBuggger
//
//  Created by Victor Augusto Pereira Porciúncula on 12/28/15.
//  Copyright © 2015 rfccg. All rights reserved.
//

import UIKit
import SpriteKit

class TBMegaLaserNode: SKSpriteNode {
    
    static let name = "megaLaser"
    var jaAtirou = false
    var initialTime: CFTimeInterval = 0
    var entrouContato = false // Variavel auxiliar para o megaLaser nao mudar de estado mais vezes, quando o player voltar a entrar em contato com ele
    
    init(laserPosition: CGPoint) {
        super.init(texture: nil, color: UIColor.whiteColor(), size: CGSizeMake(50, 50))
        
        self.jaAtirou = false
        self.position = CGPointMake(laserPosition.x, laserPosition.y)
        self.color = UIColor.greenColor()
        self.size = CGSizeMake(600, 40)
        self.zPosition = 1000
        self.physicsBody = SKPhysicsBody(rectangleOfSize: self.size);
        self.physicsBody? = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.size.width, self.size.height))
        self.physicsBody?.velocity = CGVectorMake(430, 0) // Mesma velocidade do boss e do player
        self.physicsBody?.friction = CGFloat(0)
        self.physicsBody?.linearDamping = 0
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.affectedByGravity = false
        
        self.setNormalCategoryBitMask()
    }
    
    func initFire(sender:GameScene) {    // Comeca a mudanca de estado para o modo que mata
        self.entrouContato = true
        let changeToBusy = SKAction.sequence([SKAction.waitForDuration(1), SKAction.runBlock({self.color = UIColor.yellowColor()})])
        let changeToFire = SKAction.sequence([SKAction.waitForDuration(0.4), SKAction.runBlock({self.color = UIColor.redColor(); self.setFireCategoryBitMask(); self.checkPlayerContact(sender);})])
        let backToBusy = SKAction.sequence([SKAction.waitForDuration(0.3), SKAction.runBlock({self.color = UIColor.yellowColor(); self.setNormalCategoryBitMask()})])
        let backToNormal = SKAction.sequence([SKAction.waitForDuration(0.6), SKAction.runBlock({self.color = UIColor.greenColor()})])
        let bossChangeAttack = SKAction.runBlock({if let boss = self.parent as? TBFirstBossNode {
            boss.startAttack(); self.removeFromParent()
            }})
        runAction(SKAction.sequence([changeToBusy, changeToFire, backToBusy, backToNormal, bossChangeAttack]))
    }
    
    func setNormalCategoryBitMask() {     // Categoria do laser que nao mata o player
        self.physicsBody?.categoryBitMask = GameScene.MEGALASER_NODE
        self.physicsBody?.collisionBitMask = ~GameScene.MOEDA_NODE & ~GameScene.REFERENCIA_NODE & ~GameScene.MONSTER_NODE & ~GameScene.PLAYER_NODE
        self.physicsBody?.contactTestBitMask = GameScene.PLAYER_NODE
    }
    
    func setFireCategoryBitMask() {       // Categoria do laser que ira matar o player
        self.physicsBody?.categoryBitMask = GameScene.MEGALASERKILLER_NODE
        self.physicsBody?.collisionBitMask = ~GameScene.MOEDA_NODE & ~GameScene.REFERENCIA_NODE & ~GameScene.MONSTER_NODE & ~GameScene.PLAYER_NODE
        self.physicsBody?.contactTestBitMask = GameScene.PLAYER_NODE
    }
    
    func checkPlayerContact(sender:GameScene) {      // Checa se o player esta em contato com o megaLaser no modo que mata
        let bodies = self.physicsBody?.allContactedBodies()
        for body : SKPhysicsBody in bodies! {
            if let player = body.node as? TBPlayerNode {
                player.dangerCollision(self.physicsBody!, sender: sender)
            } else if (body.node?.name == "standNode") {
                if let player = body.node?.parent as? TBPlayerNode {
                    player.dangerCollision(self.physicsBody!, sender: sender)
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

