//
//  TBBopperBotNode.swift
//  TheBuggger
//
//  Created by Allysson Lukas de Lima Andrade on 17/11/15.
//  Copyright © 2015 rfccg. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class TBBopperBotNode: SKSpriteNode,TBMonsterProtocol {
    
    static let name = "monsterPinoteiro"
    static var animation: SKAction?
    static var deathAnimation: SKAction?
    static var attackAnimation: SKAction?
    
    init() {
        
        super.init(texture:SKTexture(), color: UIColor.clearColor(), size: CGSizeMake(0, 0))
        
        //self.color = UIColor.whiteColor()
        //self.size = CGSizeMake(80, 80)
        // self.anchorPoint = CGPointMake(0, 20)
        self.size = CGSizeMake(154, 110)
        self.anchorPoint = CGPointMake(0.5, 0.36)
        self.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.size.width-80, self.size.height-38))
        self.physicsBody?.friction = CGFloat(0)
        self.physicsBody?.linearDamping = 0
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.friction = 0.8
        self.runAction(SKAction.repeatActionForever(TBBopperBotNode.animation!))
        
        // adicionando referencia, dá pra otimizar
        let referencia:SKSpriteNode! = SKSpriteNode()
        referencia?.name = "referencia"
        referencia?.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(10, 1000))
        referencia?.position = CGPointMake(-400, 0)
        referencia.physicsBody?.pinned = true
        referencia.physicsBody?.affectedByGravity = false
        referencia.physicsBody?.allowsRotation = false
        referencia.physicsBody?.friction = 0
        referencia.physicsBody?.dynamic = false
        referencia.physicsBody?.categoryBitMask = GameScene.REFERENCIA_NODE
        referencia.physicsBody?.contactTestBitMask = GameScene.PLAYER_NODE
        self.addChild(referencia!)
        
    }
    
    static func createSKActionAnimation()
    {
        let monsterArray = TBUtils().getSprites("BopperMonsterStand", nomeImagens: "enemy2stop-")
        TBBopperBotNode.animation = SKAction.animateWithTextures(monsterArray, timePerFrame: 0.15);
        
        let deathArray = TBUtils().getSprites("BopperMonsterDeath", nomeImagens: "enemy2dead-")
        TBBopperBotNode.deathAnimation = SKAction.animateWithTextures(deathArray, timePerFrame: 0.1);
        
        let attackArray = TBUtils().getSprites("BopperMonsterAttack", nomeImagens: "enemyatk-")
        let attack = SKAction.animateWithTextures(attackArray, timePerFrame: 0.05)
        let move = SKAction.moveBy(CGVector(dx: -60, dy: 0), duration: 0.45)
        TBBopperBotNode.attackAnimation = SKAction.group([attack, move])
    }
    
    func dieAnimation()
    {
        //tirando corpo fisico e contato
        self.physicsBody?.categoryBitMask = 0
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.pinned = true
        self.removeAllChildren()
        runAction(SKAction.sequence([TBBopperBotNode.deathAnimation!, SKAction.runBlock({
            self.removeFromParent()
        })]), withKey: "dieMonster")
    }
    
    // Cria um tiro a partir do bot
    func startAttack() {
        
        self.runAction(TBBopperBotNode.attackAnimation!)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}