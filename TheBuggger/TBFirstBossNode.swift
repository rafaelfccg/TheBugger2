//
//  TBFirstBossNode.swift
//  TheBuggger
//
//  Created by Victor Augusto Pereira Porciúncula on 12/27/15.
//  Copyright © 2015 rfccg. All rights reserved.
//

import Foundation
import SpriteKit

class TBFirstBossNode: SKSpriteNode,TBMonsterProtocol {
    static let name = "SpawnFirstBoss"
    let defaultSpeed = 430    // Mesma velocidade do heroi
    var life = 10
    var metalBallIsRunning = false   // Variaveis auxiliares para checar
    var megaLaserDownIsRunning = false
    var megaLaserUpIsRunning = false
    
    init() {
        
        super.init(texture:SKTexture(), color: UIColor.clearColor(), size: CGSizeMake(0, 0))
        
        self.color = UIColor.blackColor()
        //self.size = CGSizeMake(80, 80)
        // self.anchorPoint = CGPointMake(0, 20)
        self.size = CGSizeMake(150, 270)
        //self.anchorPoint = CGPointMake(0.5, 0.36)
        self.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.size.width, self.size.height))
        self.physicsBody?.friction = 0;
        self.physicsBody?.linearDamping = 0;
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.dynamic = true
        self.physicsBody?.restitution = 0
        self.physicsBody?.velocity = CGVectorMake(0, 0)
        self.physicsBody?.mass = 100
        self.physicsBody?.categoryBitMask = GameScene.BOSSONE_NODE
        self.physicsBody?.collisionBitMask = ~GameScene.JOINT_ATTACK_NODE & ~GameScene.MOEDA_NODE & ~GameScene.REFERENCIA_NODE & ~GameScene.TIRO_NODE
        self.physicsBody?.contactTestBitMask = GameScene.PLAYER_NODE | GameScene.JOINT_ATTACK_NODE | GameScene.METALBALL_NODE
        ~GameScene.JOINT_ATTACK_NODE & ~GameScene.MOEDA_NODE & ~GameScene.REFERENCIA_NODE
        
    }
    
    func dieAnimation(hero: TBPlayerNode)
    {
        //adicionando score ao heroi
//        self.removeAllActions()
//        hero.score += 10
//        hero.monstersKilled++
//        //tirando corpo fisico e contato
//        self.physicsBody?.categoryBitMask = 0
//        self.physicsBody?.collisionBitMask = 0
//        self.physicsBody?.pinned = true
//        self.removeAllChildren()
//        runAction(SKAction.sequence([TBShotBotNode.deathAnimation!, SKAction.runBlock({
//            self.removeFromParent()
//            self.removeAllActions()
//        })]), withKey: "dieMonster")
    }
    
    func updateVelocity() {
        self.physicsBody?.velocity = CGVectorMake(CGFloat(self.defaultSpeed), 0)
    }
    
    func startBoss() {      // O boss comeca a se movimentar e realizar suas acoes
        runAction(SKAction.runBlock({self.startAttack()}))
    }
    
    func startAttack() {       // O boss comeca a atacar
            //let diceRoll = Int(arc4random_uniform(3))
            self.megaLaserAttackUp()
        
    }
    
    func ballAttack() { // Ataque da bola de metal
        self.createBall()
    }
    
    func createBall() { // Cria a bola de metal
        let ball = TBBallFirstBossNode(ballPosition: CGPointMake(-95, -85))
        ball.name = TBBallFirstBossNode.name
        self.addChild(ball)
    }
    
    func decreaseLifeMetalBall() { // Diminui a vida do boss quando receber dano da metalBall
        self.life--
    }
    
    func decreaseLife() { // Diminui a vida do boss quando receber dano
        self.life--
    }
    
    func megaLaserAttackDown() {    // Ataque do megaLaser em baixo
        self.createMegaLaserDown()
    }
    
    func createMegaLaserDown() {      // Cria o megaLaser em baixo
        let megaLaser = TBMegaLaserNode(laserPosition: CGPointMake(-372, -115))
        megaLaser.name = TBMegaLaserNode.name
        self.addChild(megaLaser)
    }
    
    func megaLaserAttackUp() {           // Ataque do megaLaser em cima
        self.createMegaLaserUp()
    }
    
    func createMegaLaserUp() {      // Cria o megaLaser em cima
        let megaLaser = TBMegaLaserNode(laserPosition: CGPointMake(-372, -60))
        megaLaser.name = TBMegaLaserNode.name
        self.addChild(megaLaser)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}