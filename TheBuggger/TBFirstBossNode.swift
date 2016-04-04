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
    var life = 100
    let attacksToLowEnergy = 8     // Numero de ataques necessarios pro boss descarregar
    var lastAttack = -1        // Variavel auxiliar para nao repetir o mesmo attack duas vezes
    var bossSceneDelegate:BossProtocol?
    
    var attacksHappened = 0
    var totalAttacks = 0
    var currentBit:Int = 0
    var rechargingTime:Double = 5      // Tempo que o Boss ira recarregar
    var bossMode = "Normal"     // Variavei auxiliar pra saber qual o modo progressivo em que o boss esta
    var isDead = false     // Saber se o boss esta morto ou nao, pois pode atacar durante a animacao
    var stateHittedOff = false // Saber se o boss esta sendo hittado ou nao, para a animacao nao acontecer se ja estiver acontecendo
    var deathAnimationIsRunning = false     // Saber se a animacao de morte ja esta acontecendo
    var isLowEnergy = false
    var smokeIsOn = false       // Variavel que checa se a particula de fumaca ja foi emitida
    var smokeParticle: SKEmitterNode?
    
    static var animation: SKAction?
    static var deathAnimation: SKAction?
    static var turnOffAnimation: SKAction?
    static var hittedOffAnimation: SKAction?
    static var bossMegaLaserDownAnimation: SKAction?
    static var bossMegaLaserUpAnimation: SKAction?
    static var bossHittedByBallAnimation: SKAction?
    static var bossTurnOnAnimation: SKAction?
    
    static var defaultAtlas = SKTextureAtlas(named: "bossAnimation")
    static var deathAtlas = SKTextureAtlas(named: "bossDeath")
    static var turnOffAtlas = SKTextureAtlas(named: "turnOffBoss")
    static var hittedOffAtlas = SKTextureAtlas(named: "bossHittedOff")
    static var bossMegaLaserDownAtlas = SKTextureAtlas(named: "bossMegaLaserDown")
    static var bossMegaLaserUpAtlas = SKTextureAtlas(named: "bossMegaLaserUp")
    static var bossHittedByBallAtlas = SKTextureAtlas(named: "bossHittedByBall")
    static var bossTurnOnAtlas = SKTextureAtlas(named: "bossTurnOn")
    
    init() {
        
        super.init(texture:SKTexture(), color: UIColor.clearColor(), size: CGSizeMake(0, 0))
        self.color = UIColor.blackColor()
        self.size = CGSizeMake(190, 270)
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
        self.physicsBody?.collisionBitMask = GameScene.PLAYER_NODE | ~GameScene.JOINT_ATTACK_NODE & ~GameScene.MOEDA_NODE & ~GameScene.REFERENCIA_NODE & ~GameScene.TIRO_NODE & ~GameScene.OTHER_NODE & ~GameScene.ESPINHOS_NODE
        self.physicsBody?.contactTestBitMask = GameScene.PLAYER_NODE | GameScene.JOINT_ATTACK_NODE | GameScene.METALBALL_NODE & ~GameScene.MOEDA_NODE & ~GameScene.REFERENCIA_NODE & ~GameScene.ESPINHOS_NODE
        
        runAction(SKAction.repeatActionForever(TBFirstBossNode.animation!))
        
    }
    
    func dieAnimation(hero: TBPlayerNode)
    {

    }
    
    func createSmokeParticle() { // Cria a particula de fumaca quando o boss estiver morrendo
        if(!self.smokeIsOn) {
            self.smokeIsOn = true
            let smokeParticle = SKEmitterNode(fileNamed: "TBBossSmokeParticle.sks")
            smokeParticle?.zPosition = -1
            smokeParticle?.zRotation = -30
            smokeParticle?.position.y += 40
            smokeParticle?.position.x += 5
            smokeParticle?.particleScale = 0.5
            self.smokeParticle = smokeParticle
            self.addChild(self.smokeParticle!)
        }
    }
    
    static func createSKActionAnimation()
    {
        let monsterArray = TBUtils.getSprites(TBFirstBossNode.defaultAtlas, nomeImagens: "boss")
        TBFirstBossNode.animation = SKAction.animateWithTextures(monsterArray, timePerFrame: 0.15);
        
        let deathArray = TBUtils.getSprites(TBFirstBossNode.deathAtlas, nomeImagens: "bossimorte")
        TBFirstBossNode.deathAnimation = SKAction.animateWithTextures(deathArray, timePerFrame: 0.15);
        
        let turnOffArray = TBUtils.getSprites(TBFirstBossNode.turnOffAtlas, nomeImagens: "bossindoturnof")
        TBFirstBossNode.turnOffAnimation = SKAction.animateWithTextures(turnOffArray, timePerFrame: 0.15)
        
        let hittedOffArray = TBUtils.getSprites(TBFirstBossNode.hittedOffAtlas, nomeImagens: "hit")
        TBFirstBossNode.hittedOffAnimation = SKAction.animateWithTextures(hittedOffArray, timePerFrame: 0.15)
        
        let bossMegaLaserDownArray = TBUtils.getSprites(TBFirstBossNode.bossMegaLaserDownAtlas, nomeImagens: "bosslow")
        TBFirstBossNode.bossMegaLaserDownAnimation = SKAction.animateWithTextures(bossMegaLaserDownArray, timePerFrame: 0.2)
        
        let bossMegaLaserUpArray = TBUtils.getSprites(TBFirstBossNode.bossMegaLaserUpAtlas, nomeImagens: "bossup")
        TBFirstBossNode.bossMegaLaserUpAnimation = SKAction.animateWithTextures(bossMegaLaserUpArray, timePerFrame: 0.2)
        
        let bossHittedByBallArray = TBUtils.getSprites(TBFirstBossNode.bossHittedByBallAtlas, nomeImagens: "bosshit")
        TBFirstBossNode.bossHittedByBallAnimation = SKAction.animateWithTextures(bossHittedByBallArray, timePerFrame: 0.15)
        
        let bossTurnOnArray = TBUtils.getSprites(TBFirstBossNode.bossTurnOnAtlas, nomeImagens: "bossindoturnon")
        TBFirstBossNode.bossTurnOnAnimation = SKAction.animateWithTextures(bossTurnOnArray, timePerFrame: 0.15)
    }
    
    func updateVelocity(hero:TBPlayerNode) {
        if !isLowEnergy {
            self.physicsBody?.velocity = CGVectorMake((hero.physicsBody?.velocity.dx)!, 0)
        }
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
            time = 0.6
            break
        case "Insane":
            time = 0.6
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
                if(self.bossMode == "Hard") {
                    let diceRoll = Int(arc4random_uniform(4))
                    switch(diceRoll) {
                    case 0:
                        if(self.lastAttack != 0) {
                            self.ballAttackDown()
                        } else {
                            self.doubleAttack()
                        }
                    case 1:
                        if(self.lastAttack != 1) {
                            self.doubleAttack()
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
                } else if(self.bossMode == "Insane") {
                    let diceRoll = Int(arc4random_uniform(4))
                    switch(diceRoll) {
                    case 0:
                        if(self.lastAttack != 0) {
                            self.ballAttackDown()
                        } else {
                            self.tripleAttack()
                        }
                    case 1:
                        if(self.lastAttack != 1) {
                            self.tripleAttack()
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
    }
    
    func tripleAttack() {        // Ataque duplo da megaLaser + metal ball + metal ball
        self.attacksHappened+=1
        self.totalAttacks+=1
        self.lastAttack = 1
        let tripleAttackAction = SKAction.sequence([SKAction.runBlock({self.animationPlusCreateMLD()}), SKAction.waitForDuration(0.5), SKAction.runBlock({self.createAttackBallNoBack(2)}), SKAction.waitForDuration(1), SKAction.runBlock({self.createAttackBallNoBack(3)})])
        self.runAction(tripleAttackAction)
    }
    
    func doubleAttack() { // Ataque duplo da megaLaser + metal ball
        self.attacksHappened+=1
        self.totalAttacks+=1
        self.lastAttack = 1
        let doubleAttackAction = SKAction.sequence([SKAction.runBlock({self.animationPlusCreateMLD()}), SKAction.waitForDuration(0.5), SKAction.runBlock({self.createAttackBallNoBack(2)})])
        self.runAction(doubleAttackAction)
    }
    
    func createAttackBallNoBack(KindOfAttack: Int) {     // Cria a bola do ataque em precisar voltar a atacar(usado no ataque duplo e triplo)
        let ball = TBBallFirstBossNode(ballPosition: CGPointMake(-130, 0))
        ball.name = TBBallFirstBossNode.name
        ball.ataqueDuploTriplo = true
        if(KindOfAttack == 2) {
            ball.position = CGPointMake(-70, 0)
            ball.physicsBody?.velocity = CGVectorMake(-70, 0)
        } else if(KindOfAttack == 3) {
            ball.position = CGPointMake(-70, -65)
            ball.physicsBody?.velocity = CGVectorMake(-220, 0)
            ball.turnSpecialOff()   // Sempre que a bola vir no meio em um ataque triplo ela nao sera especial
        }
        self.addChild(ball)
    }
    
    func checkEnergy() -> Bool {   // Funcao para checar se a energia do boss está baixa
        var energyIsSlow = false
        if(self.attacksHappened == self.attacksToLowEnergy) {
            self.attacksHappened = 0
            self.bossLowEnergy()
            energyIsSlow = true
        }
        if(self.isDead) {
            runAction(SKAction.runBlock({self.physicsBody?.velocity.dx = 0}))
            energyIsSlow = true
        }
        return energyIsSlow
    }
    
    func ballAttackDown() { // Ataque da bola de metal em baixo
        self.attacksHappened+=1
        self.totalAttacks+=1
        self.lastAttack = 0
        self.createBallDown()
    }
    
    func createBallDown() { // Cria a bola de metal em baixo
        //let ball = TBBallFirstBossNode(ballPosition: CGPointMake(-130, -85))
        let ball = TBBallFirstBossNode(ballPosition: CGPointMake(-70, -85))
        ball.name = TBBallFirstBossNode.name
        // Seta a velocidade da bola de acordo com o modo do Boss
        var velocityMode = -200
        switch(self.bossMode) {
        case "Normal":
            velocityMode = -200
            break
        case "Hard":
            velocityMode = -250
            break
        case "Insane":
            velocityMode = -300
            break
        default:
            print("Error setting velocity")
        }
        ball.physicsBody?.velocity = CGVectorMake(CGFloat(velocityMode), 0)
        
        self.addChild(ball)
    }
    
    func ballAttackUp() { // Ataque da bola de metal em cima
        self.attacksHappened+=1
        self.totalAttacks+=1
        self.lastAttack = 3
        self.createBallUp()
    }
    
    func createBallUp() { // Cria a bola de metal em cima
        //let ball = TBBallFirstBossNode(ballPosition: CGPointMake(-130, 0))
        let ball = TBBallFirstBossNode(ballPosition: CGPointMake(-70, 0))
        ball.name = TBBallFirstBossNode.name
        ball.physicsBody?.velocity = CGVectorMake(-70, 0)
        self.addChild(ball)
    }
    
    func decreaseLifeMetalBall() { // Diminui a vida do boss quando receber dano da metalBall
        if(!self.isDead) {
            runAction(TBFirstBossNode.bossHittedByBallAnimation!)
            if(self.life >= 10) {      // Para nao mostrar a lifebar errada
                self.life -= 10
                self.checkBossMode()
            } else {
                self.life = 0
            }
        }
        if(self.life <= 0) {
            self.isDead = true
            self.bossDie()
        }
        self.updateSceneHpLabel()
    }
    
    func updateSceneHpLabel() {     // Atualiza o HP do boss na cena
        if let scene = self.parent as? FirstBossGameScene {
            scene.updateHPLabel()
        }
    }
    
    func decreaseLife() {       // Diminui a vida do boss quando receber dano
        if(!self.isDead) {
            if(!self.stateHittedOff) {
                runAction(SKAction.sequence([SKAction.runBlock({self.stateHittedOff = true}), TBFirstBossNode.hittedOffAnimation!, SKAction.runBlock({self.stateHittedOff = false})]))
            }
            self.life -= 2
        }
        if(self.life <= 0) {
            self.isDead = true
            self.bossDie()
        }
        self.updateSceneHpLabel()
    }
    
    func bossDie() {     // Funcao para a morte do boss
        if(!self.deathAnimationIsRunning) {
            self.deathAnimationIsRunning = true
            runAction(SKAction.sequence([TBFirstBossNode.deathAnimation!, SKAction.runBlock({
                self.removeFromParent()
                self.runAction(SKAction.waitForDuration(1.0))
                self.bossSceneDelegate?.bossDead()
            })
            ]))
        }
    }
    
    func bossLowEnergy() {    // Chamada quando a energia do boss estiver baixa
        self.isLowEnergy = true
        let slowDownAction = SKAction.sequence([SKAction.runBlock({self.physicsBody?.velocity.dx = 0}), SKAction.waitForDuration(self.rechargingTime)])
        // Pode se reposicionar de duas maneiras, a primeira e apenas acelerando pra frente
        let accelerateAction = SKAction.sequence([SKAction.runBlock({self.physicsBody?.velocity.dx = CGFloat(self.defaultSpeed+600)}), SKAction.waitForDuration(0.76), SKAction.runBlock({self.physicsBody?.velocity.dx = CGFloat(self.defaultSpeed)}), SKAction.waitForDuration(2), SKAction.runBlock({self.checkBossMode()}), SKAction.runBlock({self.startAttack()})])
        // A segunda e pulando
        let up = SKAction.moveBy(CGVectorMake(0, 130), duration: 0.38)
        let down = SKAction.moveBy(CGVectorMake(0, -130), duration: 0.38)
        
        let jumpAction = SKAction.sequence([SKAction.runBlock({self.physicsBody?.velocity.dx = CGFloat(self.defaultSpeed+600)}), up, down, SKAction.runBlock({self.physicsBody?.velocity = CGVectorMake(CGFloat(self.defaultSpeed), CGFloat(0))}), SKAction.waitForDuration(2), SKAction.runBlock({self.checkBossMode()}), SKAction.runBlock({self.startAttack()})])

        
        let standingTexture = SKTexture(imageNamed: "bossindoturnof5")
        let standingSit = SKAction.animateWithTextures([standingTexture], timePerFrame: 4.25)
        
        let diceRoll = Int(arc4random_uniform(2))
        switch(diceRoll) {
        case 0:
            runAction(SKAction.sequence([SKAction.group([slowDownAction, SKAction.sequence([TBFirstBossNode.turnOffAnimation!, standingSit])]), SKAction.group([TBFirstBossNode.bossTurnOnAnimation!, accelerateAction]), SKAction.runBlock({self.isLowEnergy = false})]))
        case 1:
            runAction(SKAction.sequence([SKAction.group([slowDownAction, SKAction.sequence([TBFirstBossNode.turnOffAnimation!, standingSit])]), SKAction.group([TBFirstBossNode.bossTurnOnAnimation!, jumpAction]), SKAction.runBlock({self.isLowEnergy = false})]))
        default:
            print("Error")
        }
    }
    
    func checkBossMode() {
        if(self.life >= 42 && self.life <= 70) {
            self.bossMode = "Hard"
        } else if(self.life < 40) {
            self.bossMode = "Insane"
            self.createSmokeParticle()

        }
    }
    
    func megaLaserAttackDown() {    // Ataque do megaLaser em baixo
        self.attacksHappened+=1
        self.totalAttacks+=1
        self.lastAttack = 1
        self.animationPlusCreateMLD()
    }
    
    func animationPlusCreateMLD() {     // Animacao + criacao do megaLaser
        runAction(SKAction.group([TBFirstBossNode.bossMegaLaserDownAnimation!, SKAction.runBlock({self.createMegaLaserDown()})]))
    }
    
    func createMegaLaserDown() {      // Cria o megaLaser em baixo
        let megaLaser = TBMegaLaserNode(laserPosition: CGPointMake(-540, -115))
        megaLaser.name = TBMegaLaserNode.name
        self.addChild(megaLaser)
    }
    
    func megaLaserAttackUp() {           // Ataque do megaLaser em cima
        self.attacksHappened+=1
        self.totalAttacks+=1
        self.lastAttack = 2
        runAction(SKAction.group([TBFirstBossNode.bossMegaLaserUpAnimation!, SKAction.runBlock({self.createMegaLaserUp()})]))
        //self.createMegaLaserUp()
    }
    
    func createMegaLaserUp() {      // Cria o megaLaser em cima
        let megaLaser = TBMegaLaserNode(laserPosition: CGPointMake(-540, -55))
        megaLaser.name = TBMegaLaserNode.name
        self.addChild(megaLaser)
    }
    
    func createBit() {     // Cria um bit
        let bit = TBBitNode()
        //bit.position = (node.position)
        bit.physicsBody?.pinned = false
        bit.position = CGPointMake(-130, 0)
        bit.physicsBody?.categoryBitMask = GameScene.MOEDA_NODE
        bit.physicsBody?.contactTestBitMask = GameScene.PLAYER_NODE
        bit.physicsBody?.velocity = CGVectorMake(-350, 0)
        bit.name  = "removable"
        self.currentBit+=1
        bit.num = self.currentBit
        self.addChild(bit)
        bit.runAction(SKAction.repeatActionForever( TBBitNode.animation!), withKey: "moedaBit")
    }
    
    func shotBit() {       // Atira um bit
        let shootingBit = SKAction.sequence([SKAction.waitForDuration(1), SKAction.runBlock({self.createBit()}), SKAction.waitForDuration(1.5), SKAction.runBlock({self.startAttack()})])
        runAction(shootingBit)
    }
    
    func checkBitTime() -> Bool {      // Funcao para saber se e o momento de atirar um bit
        var itsTime = false
        if(self.totalAttacks == 7) {
            self.totalAttacks+=1
            itsTime = true
        } else if(self.totalAttacks == 13) {
            self.totalAttacks+=1
            itsTime = true
        } else if(self.totalAttacks == 22) {
            self.totalAttacks+=1
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