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
    var life = 50
    let attacksToLowEnergy = 8     // Numero de ataques necessarios pro boss descarregar
    var lastAttack = -1        // Variavel auxiliar para nao repetir o mesmo attack duas vezes
    var attacksHappened = 0
    
    init() {
        
        super.init(texture:SKTexture(), color: UIColor.clearColor(), size: CGSizeMake(0, 0))
        self.color = UIColor.blackColor()
        self.size = CGSizeMake(150, 270)
        self.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.size.width, self.size.height))
        self.physicsBody?.friction = 0;
        self.physicsBody?.linearDamping = 0;
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.dynamic = true
        self.physicsBody?.restitution = 0
        self.physicsBody?.velocity = CGVectorMake(0, 0)
        self.physicsBody?.mass = 100000
        self.physicsBody?.categoryBitMask = GameScene.BOSSONE_NODE
        self.physicsBody?.collisionBitMask = GameScene.PLAYER_NODE | ~GameScene.JOINT_ATTACK_NODE & ~GameScene.MOEDA_NODE & ~GameScene.REFERENCIA_NODE & ~GameScene.TIRO_NODE
        self.physicsBody?.contactTestBitMask = GameScene.PLAYER_NODE | GameScene.JOINT_ATTACK_NODE | GameScene.METALBALL_NODE & ~GameScene.MOEDA_NODE & ~GameScene.REFERENCIA_NODE
        
    }
    
    func dieAnimation(hero: TBPlayerNode)
    {

    }
    
    func updateVelocity() {
        self.physicsBody?.velocity = CGVectorMake(CGFloat(self.defaultSpeed), 0)
    }
    
    func startBoss() {      // O boss comeca a se movimentar e realizar suas acoes
        runAction(SKAction.runBlock({self.startAttack()}))
    }
    
    func startAttack() {       // O boss comeca a atacar
        if(!self.checkEnergy()) {   // Checa a energia antes de comecar a atacar
            let diceRoll = Int(arc4random_uniform(3))
            switch(diceRoll) {
            case 0:
                if(self.lastAttack != 0) {
                    self.ballAttack()
                } else {
                    self.megaLaserAttackDown()
                }
            case 1:
                if(self.lastAttack != 1) {
                    self.megaLaserAttackDown()
                } else {
                    self.megaLaserAttackUp()
                }
            case 2:
                if(self.lastAttack != 2) {
                    self.megaLaserAttackUp()
                } else {
                    self.ballAttack()
                }
            default:
                print("Error")
            }
        }
    }
    
    func checkEnergy() -> Bool {   // Funcao para checar se a energia do boss está baixa
        var energyIsSlow = false
        if(self.attacksHappened == self.attacksToLowEnergy) {
            self.attacksHappened = 0
            self.bossLowEnergy()
            energyIsSlow = true
        }
        return energyIsSlow
    }
    
    func ballAttack() { // Ataque da bola de metal
        self.attacksHappened +=  1
        self.lastAttack = 0
        self.createBall()
    }
    
    func createBall() { // Cria a bola de metal
        let ball = TBBallFirstBossNode(ballPosition: CGPointMake(-95, -85))
        ball.name = TBBallFirstBossNode.name
        self.addChild(ball)
    }
    
    func decreaseLifeMetalBall() { // Diminui a vida do boss quando receber dano da metalBall
        self.life--
        print(self.life)
        if(self.life == 0) {
            self.bossDie()
        }
    }
    
    func decreaseLife() {       // Diminui a vida do boss quando receber dano
        self.life--
        print(self.life)
        if(self.life == 0) {
            self.bossDie()
        }
    }
    
    func bossDie() {     // Funcao para a morte do boss
        self.removeFromParent()
    }
    
    func bossLowEnergy() {    // Chamada quando a energia do boss estiver baixa
        let slowDownAction = SKAction.sequence([SKAction.runBlock({self.physicsBody?.velocity.dx = 0}), SKAction.waitForDuration(5)])
        let accelerateAction = SKAction.sequence([SKAction.runBlock({self.physicsBody?.velocity.dx = CGFloat(self.defaultSpeed+600)}), SKAction.waitForDuration(0.8), SKAction.runBlock({self.physicsBody?.velocity.dx = CGFloat(self.defaultSpeed)}), SKAction.waitForDuration(0.5), SKAction.runBlock({self.startAttack()})])
        runAction(SKAction.sequence([slowDownAction, accelerateAction]))
    }
    
    func megaLaserAttackDown() {    // Ataque do megaLaser em baixo
        self.attacksHappened +=  1
        self.lastAttack = 1
        self.createMegaLaserDown()
    }
    
    func createMegaLaserDown() {      // Cria o megaLaser em baixo
        let megaLaser = TBMegaLaserNode(laserPosition: CGPointMake(-372, -115))
        megaLaser.name = TBMegaLaserNode.name
        self.addChild(megaLaser)
    }
    
    func megaLaserAttackUp() {           // Ataque do megaLaser em cima
        self.attacksHappened +=  1
        self.lastAttack = 2
        self.createMegaLaserUp()
    }
    
    func createMegaLaserUp() {      // Cria o megaLaser em cima
        let megaLaser = TBMegaLaserNode(laserPosition: CGPointMake(-372, -60))
        megaLaser.name = TBMegaLaserNode.name
        self.addChild(megaLaser)
    }
    
    func setParedeNode() {     // Funcao para que quando o boss pare se crie um no parede, para o player nao ficar indo sempre pra frente
        let parede:SKSpriteNode! = SKSpriteNode()
        parede.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(40, 1000))
        parede.physicsBody?.affectedByGravity = false;
        parede.physicsBody?.linearDamping = 0;
        parede.physicsBody?.friction = 0;
        parede.physicsBody?.pinned = true
        parede.physicsBody?.allowsRotation = false
        parede.physicsBody?.restitution = 0
        parede.physicsBody?.mass = 0.0000001
        parede.physicsBody?.collisionBitMask = 0b0
        parede.physicsBody?.categoryBitMask = GameScene.TOCO_NODE
        parede.physicsBody?.contactTestBitMask = GameScene.PLAYER_NODE
        parede.position = CGPointMake(-150 , 0)
        parede.zRotation = 0
        addChild(parede)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}