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
    var initialTime: CFTimeInterval = 0
    
    init(ballPosition: CGPoint) {
        super.init(texture: nil, color: UIColor.whiteColor(), size: CGSizeMake(50, 50))
        
        self.position = CGPointMake(ballPosition.x, ballPosition.y)
        self.color = UIColor.blackColor()
        self.size = CGSizeMake(35, 35)
        self.physicsBody = SKPhysicsBody(rectangleOfSize: self.size)
        self.physicsBody? = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.size.width, self.size.height))
        self.physicsBody?.velocity = CGVectorMake(-200, 0)
        self.physicsBody?.friction = CGFloat(0)
        self.physicsBody?.linearDamping = 0
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.affectedByGravity = false
        
        self.physicsBody?.categoryBitMask = GameScene.METALBALL_NODE
        self.physicsBody?.collisionBitMask = ~GameScene.MOEDA_NODE & ~GameScene.REFERENCIA_NODE & ~GameScene.MONSTER_NODE
        self.physicsBody?.contactTestBitMask = GameScene.PLAYER_NODE | GameScene.BOSSONE_NODE
    }
    
    func defendeAnimation() { //  Quando o heroi defender a bola, ela voltara contra o boss
        self.physicsBody?.velocity = CGVectorMake(1000, 0)
    }
    
    func bossDamaged() {  // Acao que remove o no metalBall quando acertar o boss
        self.removeFromParent()
    }
    
    func heroDamaged() {  // Acao que remove o no metalBall quando acertar o heroi
        self.removeFromParent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

