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
        
        // adicionando referencias
        let referencia:SKSpriteNode! = SKSpriteNode()
        referencia?.name = "referencia"
        referencia?.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(10, 1000))
        referencia?.position = CGPointMake(-750, 0)
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
        referencia2?.position = CGPointMake(0, 0)
        referencia2.physicsBody?.pinned = true
        referencia2.physicsBody?.affectedByGravity = false
        referencia2.physicsBody?.allowsRotation = false
        referencia2.physicsBody?.friction = 0
        referencia2.physicsBody?.dynamic = false
        referencia2.physicsBody?.categoryBitMask = GameScene.REFERENCIA_NODE
        referencia2.physicsBody?.contactTestBitMask = GameScene.PLAYER_NODE
        self.addChild(referencia2!)
        
    }
    
    static func createSKActionAnimation()
    {
        //        let monsterArray = TBUtils().getSprites("GroundMonster", nomeImagens: "groundMonster-")
        //        TBGroundBotNode.animation = SKAction.animateWithTextures(monsterArray, timePerFrame: 0.1);
        
        let monsterArray = TBUtils().getSprites("RepousoShotBot", nomeImagens: "repousoShotBot-")
        TBShotBotNode.animation = SKAction.animateWithTextures(monsterArray, timePerFrame: 0.15);
        
        let deathArray = TBUtils().getSprites("DieShooterBot", nomeImagens: "dieShooterBot-")
        TBShotBotNode.deathAnimation = SKAction.group([SKAction.animateWithTextures(deathArray, timePerFrame: 0.1), SKAction.playSoundFileNamed("robotExplosion.mp3", waitForCompletion: true)]);
        
        let shootingArray = TBUtils().getSprites("ShooterBot", nomeImagens: "shooterBot-")
        TBShotBotNode.shootingAnimation = SKAction.group([SKAction.animateWithTextures(shootingArray, timePerFrame: 0.05), SKAction.playSoundFileNamed("shot.mp3", waitForCompletion: false)])
        
        let shootingArray2 = TBUtils().getSprites("ShooterBot2", nomeImagens: "shooterBot2-")
        TBShotBotNode.shootingAnimation2 = SKAction.animateWithTextures(shootingArray2, timePerFrame: 0.15)
        
        
    }
    
    func dieAnimation(hero: TBPlayerNode)
    {
        //adicionando score ao heroi
        stopShotMode()
        hero.score += 10
        hero.monstersKilled++
        //tirando corpo fisico e contato
        self.physicsBody?.categoryBitMask = 0
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.pinned = true
        self.removeAllChildren()
        runAction(SKAction.sequence([TBShotBotNode.deathAnimation!, SKAction.runBlock({
            self.removeFromParent()
        })]), withKey: "dieMonster")
    }
    
    // Cria um tiro a partir do bot
    func startAttack() {
        self.runAction(SKAction.repeatActionForever((SKAction.sequence([TBShotBotNode.shootingAnimation!, SKAction.runBlock({self.createShot()}), TBShotBotNode.shootingAnimation2!, SKAction.waitForDuration(1.5)]))), withKey: "attack")
        
    }
    
    // o shooterBot comeca a tirar
    func activeShotMode() {
            if(self.shooted == false) {
                self.shooted = true
                self.startAttack()
            }
    }
    
    // o shooter bot para de atirar
    func stopShotMode() {
            if(self.shootedStopped == false) {
                self.removeActionForKey("attack")
                runAction(TBShotBotNode.animation!)
                self.shootedStopped = true
                print("stopped")
            }
    }
    
    // cria os tiros
    func createShot() {
        let shot = TBShotNode(shotPosition: CGPointMake(-12, -2))
        shot.name = TBShotNode.name
        shot.physicsBody?.categoryBitMask = GameScene.TIRO_NODE
        shot.physicsBody?.collisionBitMask = ~GameScene.MOEDA_NODE & ~GameScene.REFERENCIA_NODE
        shot.physicsBody?.contactTestBitMask = GameScene.PLAYER_NODE
        self.addChild(shot)
    }
    
    // animação de ataque 1
    func shooting() {
        runAction(TBShotBotNode.shootingAnimation!)
        print("entrou")
    }
    
    // animação de ataque 2
    func shooting2() {
        runAction(SKAction.sequence([TBShotBotNode.shootingAnimation2!, TBShotBotNode.animation!]))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
