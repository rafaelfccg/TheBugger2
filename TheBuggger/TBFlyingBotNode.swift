//
//  TBFlyingBotNode.swift
//  TheBuggger
//
//  Created by Victor Augusto Pereira Porciúncula on 06/10/15.
//  Copyright © 2015 rfccg. All rights reserved.
//

import UIKit
import Foundation
import SpriteKit


class TBFlyingBotNode: SKSpriteNode,TBMonsterProtocol {
    
    static let name = "SpawnMonsterType4"
    static var animation: SKAction?
    static var deathAnimation: SKAction?
    static var attackAnimation: SKAction?
    static let animationAtlas = SKTextureAtlas(named: "FlyingMonster")
    static let deathAtlas = SKTextureAtlas(named: "FlyingMonsterDeath")
    
    init() {
        
        super.init(texture:SKTexture(), color: UIColor.clearColor(), size: CGSizeMake(0, 0))
    
        self.size = CGSizeMake(84, 82)
        self.anchorPoint = CGPointMake(0.5, 0.5)
        self.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.size.width, self.size.height))
        self.physicsBody?.friction = CGFloat(0)
        self.physicsBody?.linearDamping = 0
        //não pode ser afetado pela gravidade pois está voando
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.allowsRotation = false
        // deixei a massa como 5 para ele n andar para trás quando colidir com o heroi
        self.physicsBody?.mass = 5
        self.physicsBody?.dynamic = true
        self.physicsBody?.friction = 0.8
        self.physicsBody?.categoryBitMask = GameScene.MONSTER_NODE
        self.physicsBody?.collisionBitMask = ~GameScene.JOINT_ATTACK_NODE & ~GameScene.MOEDA_NODE & ~GameScene.REFERENCIA_NODE & ~GameScene.TIRO_NODE
        self.physicsBody?.contactTestBitMask = GameScene.PLAYER_NODE | GameScene.JOINT_ATTACK_NODE
        
        self.runAnimationWithTime()
        
        // adicionando referencia, dá pra otimizar
        let referencia:SKSpriteNode! = SKSpriteNode()
        referencia?.name = "referencia"
        referencia?.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(10, 1000))
        referencia?.position = CGPointMake(-800, 0)
        referencia.physicsBody?.pinned = true
        referencia.physicsBody?.affectedByGravity = false
        referencia.physicsBody?.allowsRotation = false
        referencia.physicsBody?.friction = 0
        referencia.physicsBody?.dynamic = false
        referencia.physicsBody?.categoryBitMask = GameScene.REFERENCIA_NODE
        referencia.physicsBody?.contactTestBitMask = GameScene.PLAYER_NODE
        self.addChild(referencia!)
        
        let referencia2:SKSpriteNode! = SKSpriteNode()
        referencia2?.name = "referencia2"
        referencia2?.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(10, 1000))
        //depois que passa o bot a animação de ataque para, distacia pode ser ajustada
        referencia2?.position = CGPointMake(self.size.width/2, 0)
        referencia2.physicsBody?.pinned = true
        referencia2.physicsBody?.affectedByGravity = false
        referencia2.physicsBody?.allowsRotation = false
        referencia2.physicsBody?.friction = 0
        referencia2.physicsBody?.dynamic = false
        referencia2.physicsBody?.categoryBitMask = GameScene.REFERENCIA_NODE
        referencia2.physicsBody?.contactTestBitMask = GameScene.PLAYER_NODE
        self.addChild(referencia2!)
        setAudioNode()
        
    }
    
    func setAudioNode(){
        let buzz:SKAudioNode = SKAudioNode(fileNamed: "beeBuzz.mp3")
        buzz.positional = true
        buzz.autoplayLooped = true
        self.addChild(buzz)
//        buzz.
        buzz.runAction(SKAction.play())
    }
    
    func runAnimationWithTime() {   // Comeca a animacao depois de um delay aleatorio para os bots ficarem dessincronizados
        let diceRoll = Int(arc4random_uniform(8))
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
        case 4:
            delay = 0.5
        case 5:
            delay = 0.6
        case 6:
            delay = 0.7
        case 7:
            delay = 0.8
        default:
            print("Error")
        }
        self.runAction(SKAction.sequence([SKAction.waitForDuration(delay), SKAction.repeatActionForever(TBFlyingBotNode.animation!)]))
    }
    
    static func createSKActionAnimation()
    {
        let monsterArray = TBUtils.getSprites(SKTextureAtlas(named: "FlyingMonster"), nomeImagens: "bug-")
        TBFlyingBotNode.animation = SKAction.animateWithTextures(monsterArray, timePerFrame: 0.03);
        
        let deathArray = TBUtils.getSprites(TBFlyingBotNode.deathAtlas, nomeImagens: "bug-exp-")
        TBFlyingBotNode.deathAnimation = SKAction.animateWithTextures(deathArray, timePerFrame: 0.1);

        //melhorar movimento
        let moveUp = SKAction.moveBy(CGVector(dx: -20, dy: 75), duration: 0.6)
        let moveDown = SKAction.moveBy(CGVector(dx: -70, dy: -75), duration: 0.4)
        //sem animação, apenas movimento
        TBFlyingBotNode.attackAnimation = SKAction.repeatActionForever(SKAction.sequence([moveDown, moveUp]))
    }
    
    func dieAnimation(hero: TBPlayerNode)
    {
        //adicionando score ao heroi
        hero.score += 10
        hero.monstersKilled++
        //tirando corpo fisico e contato
        self.physicsBody?.categoryBitMask = 0
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.pinned = true
        self.removeAllChildren()
        runAction(SKAction.sequence([TBFlyingBotNode.deathAnimation!, SKAction.runBlock({
            self.removeFromParent()
        })]), withKey: "dieMonster")
    }
    
    func startAttack() {
        
        self.runAction(TBFlyingBotNode.attackAnimation!, withKey: "botAttack")
    }
    
    func stopAttack() {
        
        self.removeActionForKey("botAttack")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
