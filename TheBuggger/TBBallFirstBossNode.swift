//
//  TBBallFirstBossNode.swift
//  TheBuggger
//
//  Created by Victor Augusto Pereira Porciúncula on 12/27/15.
//  Copyright © 2015 rfccg. All rights reserved.
//

import UIKit
import SpriteKit

class TBBallFirstBossNode: SKSpriteNode {
    
    static let name = "metalBall"
    var specialChance = 30   // 30% de chance da bola ser especial
    var isSpecial = false
    var initialTime: CFTimeInterval = 0
    
    init(ballPosition: CGPoint) {
        super.init(texture: nil, color: UIColor.whiteColor(), size: CGSizeMake(50, 50))
        
        self.position = CGPointMake(ballPosition.x, ballPosition.y)
        self.size = CGSizeMake(35, 35)
        self.physicsBody = SKPhysicsBody(rectangleOfSize: self.size)
        self.physicsBody? = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.size.width, self.size.height))
        self.physicsBody?.velocity = CGVectorMake(-200, 0)
        self.physicsBody?.friction = CGFloat(0)
        self.physicsBody?.linearDamping = 0
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.affectedByGravity = false
        self.setSpecialOrNot()
        self.physicsBody?.categoryBitMask = GameScene.METALBALL_NODE
        self.physicsBody?.collisionBitMask = ~GameScene.MOEDA_NODE & ~GameScene.REFERENCIA_NODE & ~GameScene.MONSTER_NODE
        self.physicsBody?.contactTestBitMask = GameScene.PLAYER_NODE | GameScene.BOSSONE_NODE
    }
    
    func defendeAnimation() { //  Quando o heroi defender a bola, ela voltara contra o boss
        if(self.isSpecial) {
            self.physicsBody?.velocity = CGVectorMake(1000, 0)
        } else {
            let defendedNoSpecialBall = SKAction.sequence([SKAction.waitForDuration(0), SKAction.runBlock({self.bossWaitBackToAttack(); self.removeFromParent()})])
            runAction(defendedNoSpecialBall)
        }
    }
    
    func setSpecialOrNot() {     // Diferenca nas cores, animacoes e afins entre uma bola especial e nao especial
        if(getSpecial()) {
            self.color = UIColor.blueColor()
        } else {
            self.color = UIColor.blackColor()
        }
    }
    
    func getSpecial() -> Bool {        // Saber se a bola sera especial ou nao
        let diceRoll = Int(arc4random_uniform(100))
        if(diceRoll > 99 - self.specialChance) {
            self.isSpecial = true
        }
        return self.isSpecial
    }
    
    func bossWaitBackToAttack() {     // Funcao pro boss voltar a atacar depois de certo tempo
        if let boss = self.parent as? TBFirstBossNode {
            boss.waitTimeToAttack()
        }
    }
    
    func bossBackToAttack() {      // Funcao pro boss voltar a atacar
        if let boss = self.parent as? TBFirstBossNode {
            boss.startAttack()
        }
    }
    
    func bossDamaged() {  // Acao que remove o no metalBall quando acertar o boss
        self.bossBackToAttack()
        self.removeFromParent()
    }
    
    func heroDamaged() {  // Acao que remove o no metalBall quando acertar o heroi
        self.removeFromParent()
    }
    
    func ballMissed() {    // Acao que remove o no metalBall quando o heroi desviar
        self.bossBackToAttack()
        self.removeFromParent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

