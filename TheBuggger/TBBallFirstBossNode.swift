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
    var specialChance = 15   // Chance da bola ser especial
    var isSpecial = false
    var initialTime: CFTimeInterval = 0
    var ataqueDuploTriplo = false    // Variavel que sera true apenas quando for do ataque duplo ou triplo do boss
    
    let bombred = SKTexture(imageNamed: "bomb")
    let bomboff = SKTexture(imageNamed: "bomboff")
    let bombon = SKTexture(imageNamed: "bombon")
    
    static var bombExplosionAnimation: SKAction?
    static var bombExplosionAtlas = SKTextureAtlas(named: "bombaExplosion")
    
    init(ballPosition: CGPoint) {
        super.init(texture: nil, color: UIColor.whiteColor(), size: CGSizeMake(50, 50))
        
        self.position = CGPointMake(ballPosition.x, ballPosition.y)
        self.size = CGSizeMake(50, 50)
        self.physicsBody = SKPhysicsBody(rectangleOfSize: self.size)
        self.physicsBody? = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.size.width, self.size.height))
        self.physicsBody?.friction = CGFloat(0)
        self.physicsBody?.linearDamping = 0
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.velocity = CGVectorMake(-200, 0)
        self.zPosition = -1
        self.setSpecialOrNot()
        self.setCategories()
        self.rotateBall()
    }
    
    func changeExplosionSize() {   // Altera o tamanho da explosao no impacto contra o escudo ou o boss
        self.size = CGSizeMake(85, 85)
    }
    
    func rotateBall() {     // A bola ira sempre girar
        let rotateBall = SKAction.rotateByAngle(30, duration: 0.1)
        runAction(SKAction.repeatActionForever(rotateBall))
    }
    
    func setCategories() {      // Como a bola vai sair do boss, ela nao pode chocar com ele de inicio
        runAction(SKAction.sequence([SKAction.runBlock({self.setNullCategory()}), SKAction.waitForDuration(0.4), SKAction.runBlock({self.setNormalCategory()})]))
    }
    
    func setNullCategory() {
        self.physicsBody?.categoryBitMask = GameScene.ESPINHOS_NODE
        self.physicsBody?.collisionBitMask = ~GameScene.MOEDA_NODE & ~GameScene.REFERENCIA_NODE & ~GameScene.MONSTER_NODE & ~GameScene.OTHER_NODE & ~GameScene.BOSSONE_NODE & ~GameScene.METALBALL_NODE & ~GameScene.ESPINHOS_NODE
        self.physicsBody?.contactTestBitMask = GameScene.PLAYER_NODE & ~GameScene.BOSSONE_NODE & ~GameScene.METALBALL_NODE & ~GameScene.ESPINHOS_NODE
    }
    
    func setNormalCategory() {
        self.physicsBody?.categoryBitMask = GameScene.METALBALL_NODE
        self.physicsBody?.collisionBitMask = ~GameScene.MOEDA_NODE & ~GameScene.REFERENCIA_NODE & ~GameScene.MONSTER_NODE & ~GameScene.OTHER_NODE & ~GameScene.METALBALL_NODE & ~GameScene.ESPINHOS_NODE
        self.physicsBody?.contactTestBitMask = GameScene.PLAYER_NODE | GameScene.BOSSONE_NODE & ~GameScene.METALBALL_NODE & ~GameScene.ESPINHOS_NODE
    }
    
    static func createSKActionAnimation()
    {
        let bombExplosionArray = TBUtils.getSprites(TBBallFirstBossNode.bombExplosionAtlas, nomeImagens: "hit")
        TBBallFirstBossNode.bombExplosionAnimation = SKAction.animateWithTextures(bombExplosionArray, timePerFrame: 0.02)
    }
    
    func defendeAnimation() { //  Quando o heroi defender a bola, ela voltara contra o boss se for especial
        if(self.ataqueDuploTriplo) {
            if(self.isSpecial) {
                runAction(SKAction.repeatActionForever(SKAction.animateWithTextures([bombon], timePerFrame: 10)))
                self.physicsBody?.velocity = CGVectorMake(1500, 0)
            } else {
                let defendedNoSpecialBall = SKAction.sequence([SKAction.runBlock({self.changeExplosionSize()}) ,TBBallFirstBossNode.bombExplosionAnimation!,SKAction.runBlock({self.removeFromParent()})])
                runAction(defendedNoSpecialBall)
            }
        } else {
            if(self.isSpecial) {
                runAction(SKAction.repeatActionForever(SKAction.animateWithTextures([bombon], timePerFrame: 10)))
                self.physicsBody?.velocity = CGVectorMake(1500, 0)
            } else {
                let defendedNoSpecialBall = SKAction.sequence([SKAction.runBlock({self.changeExplosionSize()}) ,TBBallFirstBossNode.bombExplosionAnimation!,SKAction.runBlock({self.bossWaitBackToAttack(); self.removeFromParent()})])
                runAction(defendedNoSpecialBall)
            }
        }
    }
    
    func turnSpecialOff() {      // Deixa a bola nao especial
        self.isSpecial = false
        runAction(SKAction.repeatActionForever(SKAction.animateWithTextures([bombred], timePerFrame: 10)))
    }
    
    func setSpecialOrNot() {     // Diferenca nas cores, animacoes e afins entre uma bola especial e nao especial
        if(getSpecial()) {
            self.color = UIColor.blueColor()
        } else {
            self.color = UIColor.whiteColor()
        }
    }
    
    func getSpecial() -> Bool {        // Saber se a bola sera especial ou nao
        let diceRoll = Int(arc4random_uniform(100))
        if(diceRoll > 99 - self.specialChance) {
            self.isSpecial = true
            runAction(SKAction.repeatActionForever(SKAction.animateWithTextures([bomboff], timePerFrame: 10)))
        } else {
            runAction(SKAction.repeatActionForever(SKAction.animateWithTextures([bombred], timePerFrame: 10)))
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
        runAction(SKAction.sequence([SKAction.runBlock({self.changeExplosionSize()}) ,TBBallFirstBossNode.bombExplosionAnimation!, SKAction.runBlock({self.bossBackToAttack(); self.removeFromParent()})]))
    }
    
    func bossDamagedDontBackAttack() {  // Acao chamada no ataque duplo para o boss nao voltar a atacar 2 vezes
        self.removeFromParent()
    }
    
    func heroDamaged() {  // Acao que remove o no metalBall quando acertar o heroi
        self.removeFromParent()
    }
    
    func ballMissed() {    // Acao que remove o no metalBall quando o heroi desviar
        if(!self.ataqueDuploTriplo) {      // Ele so vai voltar a atacar caso nao seja uma bola de ataque duplo ou triplo
            self.bossBackToAttack()
        }
        self.removeFromParent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

