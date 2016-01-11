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
    
    static let name = "SpawnMonsterType3"
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
        self.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.size.width-60, self.size.height-30))
        self.physicsBody?.friction = CGFloat(0)
        self.physicsBody?.linearDamping = 0
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.friction = 0.8
        self.physicsBody?.categoryBitMask = GameScene.MONSTER_NODE
        self.physicsBody?.collisionBitMask = ~GameScene.JOINT_ATTACK_NODE & ~GameScene.MOEDA_NODE & ~GameScene.REFERENCIA_NODE & ~GameScene.TIRO_NODE
        self.physicsBody?.contactTestBitMask = GameScene.PLAYER_NODE | GameScene.JOINT_ATTACK_NODE
        
        self.runAnimationWithTime()
        
        // adicionando referencia, dá pra otimizar
        let referencia:SKSpriteNode! = SKSpriteNode()
        referencia?.name = "referencia"
        referencia?.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(10, 1000))
        referencia?.position = CGPointMake(-370, 0)
        referencia.physicsBody?.pinned = true
        referencia.physicsBody?.affectedByGravity = false
        referencia.physicsBody?.allowsRotation = false
        referencia.physicsBody?.friction = 0
        referencia.physicsBody?.dynamic = false
        referencia.physicsBody?.categoryBitMask = GameScene.REFERENCIA_NODE
        referencia.physicsBody?.contactTestBitMask = GameScene.PLAYER_NODE
        self.addChild(referencia!)
        
    }
    
    func runAnimationWithTime() {   // Comeca a animacao depois de um delay aleatorio para os bots ficarem dessincronizados
        let diceRoll = Int(arc4random_uniform(4))
        var delay:Double = 0;
        switch(diceRoll) {
        case 0:
            delay = 0.1
        case 1:
            delay = 0.2
        case 2:
            delay = 0.3
        case 3:
            delay = 0.4
        default:
            print("Error")
        }
        self.runAction(SKAction.sequence([SKAction.waitForDuration(delay), SKAction.repeatActionForever(TBBopperBotNode.animation!)]))
    }
    
    static func createSKActionAnimation()
    {
        let monsterArray = TBUtils.getSprites(SKTextureAtlas(named: "BopperMonsterStand"), nomeImagens: "enemy2stop-")
        TBBopperBotNode.animation = SKAction.animateWithTextures(monsterArray, timePerFrame: 0.15);
        
        let deathArray = TBUtils.getSprites(SKTextureAtlas(named: "BopperMonsterDeath"), nomeImagens: "enemy2dead-")
        TBBopperBotNode.deathAnimation = SKAction.group([SKAction.animateWithTextures(deathArray, timePerFrame: 0.1), SKAction.playSoundFileNamed("robotExplosion.mp3", waitForCompletion: true)]);
        
        let attackArray = TBUtils.getSprites(SKTextureAtlas(named: "BopperMonsterAttack"), nomeImagens: "enemyatk-")
        let attack = SKAction.animateWithTextures(attackArray, timePerFrame: 0.05)
        let move = SKAction.moveBy(CGVector(dx: -210, dy: 0), duration: 0.45)
        TBBopperBotNode.attackAnimation = SKAction.group([attack, move, SKAction.playSoundFileNamed("pinote.mp3", waitForCompletion: true)]);
    }
    
    func dieAnimation(hero: TBPlayerNode)
    {

        self.removeAllActions()
            //adicionando score ao heroi
        hero.score += 10
        hero.monstersKilled++
            //tirando corpo fisico e contato
        self.physicsBody?.categoryBitMask = 0
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.pinned = true
        self.removeAllChildren()
        runAction(SKAction.sequence([TBBopperBotNode.deathAnimation!, SKAction.runBlock({
                self.removeFromParent()
        })]), withKey: "dieMonster")
        
    }
    
    func startAttack() {
    
        self.runAction(TBBopperBotNode.attackAnimation!, withKey: "attack")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}