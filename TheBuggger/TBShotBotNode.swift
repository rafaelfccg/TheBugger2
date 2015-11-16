//
//  TBShotBotNode.swift
//  TheBuggger
//
//  Created by Victor Augusto Pereira Porciúncula on 02/10/15.
//  Copyright © 2015 rfccg. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class TBShotBotNode: SKSpriteNode,TBMonsterProtocol {
    static let name = "SpawnMonsterType2"
    static var animation: SKAction?
    static var deathAnimation: SKAction?
    static var shootingAnimation: SKAction?
    static var shootingAnimation2: SKAction?
    static var shootingAnimationReal: SKAction?
    var shooted = false
    var shootedStopped = false
    var startShootingTime: NSTimeInterval?
    
    var jaAtacou = false // Variavel auxiliar para o bot atacar apenas uma vez
    
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
        self.runAction(SKAction.repeatActionForever(TBShotBotNode.animation!))
        
    }
    
    static func createSKActionAnimation()
    {
        //        let monsterArray = TBUtils().getSprites("GroundMonster", nomeImagens: "groundMonster-")
        //        TBGroundBotNode.animation = SKAction.animateWithTextures(monsterArray, timePerFrame: 0.1);
        
        let monsterArray = TBUtils().getSprites("RepousoShotBot", nomeImagens: "repousoShotBot-")
        TBShotBotNode.animation = SKAction.animateWithTextures(monsterArray, timePerFrame: 0.15);
        
        let deathArray = TBUtils().getSprites("DieShooterBot", nomeImagens: "dieShooterBot-")
        TBShotBotNode.deathAnimation = SKAction.animateWithTextures(deathArray, timePerFrame: 0.1);
        
        let shootingArray = TBUtils().getSprites("ShooterBot", nomeImagens: "shooterBot-")
        TBShotBotNode.shootingAnimation = SKAction.animateWithTextures(shootingArray, timePerFrame: 0.05)
        
        let shootingArray2 = TBUtils().getSprites("ShooterBot2", nomeImagens: "shooterBot2-")
        TBShotBotNode.shootingAnimation2 = SKAction.animateWithTextures(shootingArray2, timePerFrame: 0.15)
        
        
    }
    
    func dieAnimation()
    {
        //tirando corpo fisico e contato
        self.physicsBody?.categoryBitMask = 0
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.pinned = true
        self.removeAllChildren()
        runAction(SKAction.sequence([TBShotBotNode.deathAnimation!, SKAction.runBlock({
            self.removeFromParent()
        })]), withKey: "dieMonster")
    }
    
    func shooting() {
        runAction(TBShotBotNode.shootingAnimation!)
        print("entrou")
    }
    
    func shooting2() {
        runAction(SKAction.sequence([TBShotBotNode.shootingAnimation2!, TBShotBotNode.animation!]))
    }
    
    func stopShooting() {
        runAction(TBShotBotNode.animation!)
        self.shootedStopped = true
        print("stopped")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
