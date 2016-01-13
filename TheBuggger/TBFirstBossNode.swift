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
    var totalAttacks = 0
    var currentBit = 0
    var bossMode = "Normal"     // Variavei auxiliar pra saber qual o modo progressivo em que o boss esta
    
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
        self.physicsBody?.affectedByGravity = false
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
    
    func waitTimeToAttack() {    // Espera algum tempo pra comecar a atacar, criei esta funcao pra nao comecar a atacar tao rapido depois da bola nao especial
        let waitTimeAttack = SKAction.sequence([SKAction.waitForDuration(0.5), SKAction.runBlock({self.startAttack()})])
        runAction(waitTimeAttack)
    }
    
    func startAttack() {       // O boss ira atacar depois de certo tempo, dependendo do seu modo
        var time = 0.8
        switch(self.bossMode) {
        case "Normal":
            time = 1
            break
        case "Hard":
            time = 0.5
            break
        case "Insane":
            time = 0
            break
        default:
            print("Error setting time")
        }
        let attackAction = SKAction.sequence([SKAction.waitForDuration(time), SKAction.runBlock({self.startAttackAfterTime()})])
        runAction(attackAction)
    }
    
    func startAttackAfterTime() {      // O boss comeca a atacar
        if(!self.checkEnergy()) {   // Checa a energia antes de comecar a atacar
            if(self.checkBitTime()) {     // Checa se e hora de atirar um bit
                self.shotBit()
            } else {
                let diceRoll = Int(arc4random_uniform(3))
                switch(diceRoll) {
                case 0:
                    if(self.lastAttack != 0) {
                        self.ballAttackDown()
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
                        self.ballAttackUp()
                    }
                case 3:
                    if(self.lastAttack != 3) {
                        self.ballAttackUp()
                    } else {
                        self.ballAttackDown()
                    }
                default:
                    print("Error")
                }
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
    
    func ballAttackDown() { // Ataque da bola de metal em baixo
        self.attacksHappened++
        self.totalAttacks++
        self.lastAttack = 0
        self.createBallDown()
    }
    
    func createBallDown() { // Cria a bola de metal em baixo
        let ball = TBBallFirstBossNode(ballPosition: CGPointMake(-95, -85))
        ball.name = TBBallFirstBossNode.name
        self.addChild(ball)
    }
    
    func ballAttackUp() { // Ataque da bola de metal em cima
        self.attacksHappened++
        self.totalAttacks++
        self.lastAttack = 3
        self.createBallUp()
    }
    
    func createBallUp() { // Cria a bola de metal em cima
        let ball = TBBallFirstBossNode(ballPosition: CGPointMake(-95, 0))
        ball.name = TBBallFirstBossNode.name
        ball.physicsBody?.velocity = CGVectorMake(-70, 0)
        self.addChild(ball)
    }
    
    func decreaseLifeMetalBall() { // Diminui a vida do boss quando receber dano da metalBall
        self.life -= 5
        print(self.life)
        if(self.life <= 0) {
            self.bossDie()
        }
    }
    
    func decreaseLife() {       // Diminui a vida do boss quando receber dano
        self.life--
        print(self.life)
        if(self.life <= 0) {
            self.bossDie()
        }
    }
    
    func bossDie() {     // Funcao para a morte do boss
        self.removeFromParent()
    }
    
    func bossLowEnergy() {    // Chamada quando a energia do boss estiver baixa
        let slowDownAction = SKAction.sequence([SKAction.runBlock({self.physicsBody?.velocity.dx = 0}), SKAction.waitForDuration(5)])
        // Pode se reposicionar de duas maneiras, a primeira e apenas acelerando pra frente
        let accelerateAction = SKAction.sequence([SKAction.runBlock({self.physicsBody?.velocity.dx = CGFloat(self.defaultSpeed+600)}), SKAction.waitForDuration(0.8), SKAction.runBlock({self.physicsBody?.velocity.dx = CGFloat(self.defaultSpeed)}), SKAction.waitForDuration(2), SKAction.runBlock({self.checkBossMode()}), SKAction.runBlock({self.startAttack()})])
        // A segunda e pulando
        let up = SKAction.moveBy(CGVectorMake(405, 130), duration: 0.4)
        let down = SKAction.moveBy(CGVectorMake(405, -130), duration: 0.4)
        let jumpAction = SKAction.sequence([up, down, SKAction.waitForDuration(0), SKAction.runBlock({self.physicsBody?.velocity = CGVectorMake(CGFloat(self.defaultSpeed), CGFloat(0))}), SKAction.waitForDuration(2), SKAction.runBlock({self.checkBossMode()}), SKAction.runBlock({self.startAttack()})])
        
        let diceRoll = Int(arc4random_uniform(2))
        switch(diceRoll) {
        case 0:
            runAction(SKAction.sequence([slowDownAction, accelerateAction]))
        case 1:
            runAction(SKAction.sequence([slowDownAction, jumpAction]))
        default:
            print("Error")
        }
    }
    
    func checkBossMode() {     // O boss ira aumentar seu poder de ataque de forma progressiva
        if(self.life >= 30 && self.life <= 45) {
            self.bossMode = "Hard"
            print(self.bossMode)
        } else if(self.life < 30) {
            self.bossMode = "Insane"
            print(self.bossMode)
            
        }
//        if(self.life >= 21 && self.life <= 35) {
//            self.bossMode = "Hard"
//            print(self.bossMode)
//        } else if(self.life < 20) {
//            self.bossMode = "Insane"
//            print(self.bossMode)
//
//        }
    }
    
    func megaLaserAttackDown() {    // Ataque do megaLaser em baixo
        self.attacksHappened++
        self.totalAttacks++
        self.lastAttack = 1
        self.createMegaLaserDown()
    }
    
    func createMegaLaserDown() {      // Cria o megaLaser em baixo
        let megaLaser = TBMegaLaserNode(laserPosition: CGPointMake(-372, -115))
        megaLaser.name = TBMegaLaserNode.name
        self.addChild(megaLaser)
    }
    
    func megaLaserAttackUp() {           // Ataque do megaLaser em cima
        self.attacksHappened++
        self.totalAttacks++
        self.lastAttack = 2
        self.createMegaLaserUp()
    }
    
    func createMegaLaserUp() {      // Cria o megaLaser em cima
        let megaLaser = TBMegaLaserNode(laserPosition: CGPointMake(-372, -60))
        megaLaser.name = TBMegaLaserNode.name
        self.addChild(megaLaser)
    }
    
    func createBit() {     // Cria um bit
        let bit = TBBitNode()
        //bit.position = (node.position)
        bit.physicsBody?.pinned = false
        bit.position = CGPointMake(-95, 0)
        bit.physicsBody?.categoryBitMask = GameScene.MOEDA_NODE
        bit.physicsBody?.contactTestBitMask = GameScene.PLAYER_NODE
        bit.physicsBody?.velocity = CGVectorMake(-350, 0)
        bit.name  = "removable"
        bit.num = self.currentBit++
        self.addChild(bit)
        bit.runAction(SKAction.repeatActionForever( TBBitNode.animation!), withKey: "moedaBit")
    }
    
    func shotBit() {       // Atira um bit
        let shootingBit = SKAction.sequence([SKAction.waitForDuration(1), SKAction.runBlock({self.createBit()}), SKAction.waitForDuration(1.5), SKAction.runBlock({self.startAttack()})])
        runAction(shootingBit)
    }
    
    func checkBitTime() -> Bool {      // Funcao para saber se e o momento de atirar um bit
        var itsTime = false
        if(self.totalAttacks == 12) {
            self.totalAttacks++
            itsTime = true
        } else if(self.totalAttacks == 22) {
            self.totalAttacks++
            itsTime = true
        } else if(self.totalAttacks == 30) {
            self.totalAttacks++
            itsTime = true
        }
        return itsTime
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