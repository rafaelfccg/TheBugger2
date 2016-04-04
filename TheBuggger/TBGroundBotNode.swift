//
//  TBGroundBotNode.swift
//  TheBuggger
//
//  Created by Victor Augusto Pereira Porciúncula on 02/10/15.
//  Copyright © 2015 rfccg. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class TBGroundBotNode: SKSpriteNode, TBMonsterProtocol {
    static let name = "SpawnMonsterType1"
    static var animation: SKAction?
    static var deathAnimation: SKAction?
    
    static let groundMonsterAtlas = SKTextureAtlas(named: "GroundMonster")
    static let monsterDeathAtlas = SKTextureAtlas(named: "MonsterDeath")
    
    var jaAtacou = false // Variavel auxiliar para o bot atacar apenas uma vez
    
    init() {
        
        super.init(texture:SKTexture(), color: UIColor.clearColor(), size: CGSizeMake(0, 0))
        
        //self.color = UIColor.whiteColor()
        self.size = CGSizeMake(100, 100)

        self.physicsBody = SKPhysicsBody(circleOfRadius: self.size.height/3.2, center: CGPointMake(-5, -10))
        self.physicsBody?.friction = CGFloat(0)
        self.physicsBody?.linearDamping = 0
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.friction = 0.8
        self.physicsBody?.categoryBitMask = GameScene.MONSTER_NODE
        self.physicsBody?.collisionBitMask = ~GameScene.JOINT_ATTACK_NODE & ~GameScene.MOEDA_NODE & ~GameScene.REFERENCIA_NODE & ~GameScene.TIRO_NODE & ~GameScene.PLAYER_NODE
        self.physicsBody?.contactTestBitMask = GameScene.PLAYER_NODE | GameScene.JOINT_ATTACK_NODE
        self.runAnimationWithTime()
        
    }
    
    func runAnimationWithTime() {   // Comeca a animacao depois de um delay aleatorio para os bots ficarem dessincronizados
        let diceRoll = Int(arc4random_uniform(6))
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
        default:
            print("Error")
        }
        self.runAction(SKAction.sequence([SKAction.waitForDuration(delay), SKAction.repeatActionForever(TBGroundBotNode.animation!)]))
    }
    
    static func createSKActionAnimation()
    {
        let monsterArray = TBUtils.getSprites(TBGroundBotNode.groundMonsterAtlas, nomeImagens: "groundMonster-")
        TBGroundBotNode.animation = SKAction.animateWithTextures(monsterArray, timePerFrame: 0.1);
        
        let deathArray = TBUtils.getSprites(TBGroundBotNode.monsterDeathAtlas, nomeImagens: "explosao-")
        TBGroundBotNode.deathAnimation = SKAction.group([SKAction.animateWithTextures(deathArray, timePerFrame: 0.07), SKAction.playSoundFileNamed("bolha.mp3", waitForCompletion: true)]);
    }
    
    func dieAnimation(hero: TBPlayerNode)
    {
        //adicionando score ao heroi
        hero.score += 5
        hero.monstersKilled+=1
        //tirando corpo fisico e contato
        self.physicsBody?.categoryBitMask = 0
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.pinned = true
        runAction(SKAction.sequence([TBGroundBotNode.deathAnimation!, SKAction.runBlock({
            self.removeFromParent()
        })]), withKey: "dieMonster")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startAttack() {
        let tempoInvestida = CGVectorMake(-100, 0)
        let investida = SKAction.moveBy(tempoInvestida, duration: 0.2)
        self.runAction(investida)
    }

}
