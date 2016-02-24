//
//  TBMegaLaserNode.swift
//  TheBuggger
//
//  Created by Victor Augusto Pereira Porciúncula on 12/28/15.
//  Copyright © 2015 rfccg. All rights reserved.
//

import UIKit
import SpriteKit

class TBMegaLaserNode: SKSpriteNode {
    
    static let name = "megaLaser"
    var jaAtirou = false
    var initialTime: CFTimeInterval = 0
    var entrouContato = false // Variavel auxiliar para o megaLaser nao mudar de estado mais vezes, quando o player voltar a entrar em contato com ele
    
    static var megaLaserAnimation1: SKAction?
    static var megaLaserAtlas1 = SKTextureAtlas(named: "megaLaser1")
    static var megaLaserAnimation2: SKAction?
    static var megaLaserAtlas2 = SKTextureAtlas(named: "megaLaser2")
    static var megaLaserAnimation3: SKAction?
    static var megaLaserAtlas3 = SKTextureAtlas(named: "laserEnd")
    
    init(laserPosition: CGPoint) {
        super.init(texture: nil, color: UIColor.whiteColor(), size: CGSizeMake(50, 50))
        
        self.jaAtirou = false
        self.position = CGPointMake(laserPosition.x, laserPosition.y)
        //self.color = UIColor.greenColor()
        self.hidden = true
        self.size = CGSizeMake(1000, 40)
        self.zPosition = 1000
        self.physicsBody = SKPhysicsBody(rectangleOfSize: self.size);
        self.physicsBody? = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.size.width, self.size.height))
        self.physicsBody?.velocity = CGVectorMake(430, 0) // Mesma velocidade do boss e do player
        self.physicsBody?.friction = CGFloat(0)
        self.physicsBody?.linearDamping = 0
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.affectedByGravity = false
        
        self.setNormalCategoryBitMask()
        //runAction(TBMegaLaserNode.megaLaserAnimation!)
    }
    
    func initFire(sender:GameSceneBase) {    // Comeca a mudanca de estado para o modo que mata
        self.entrouContato = true
        let changeToBusy = SKAction.sequence([SKAction.waitForDuration(0.5), SKAction.runBlock({self.hidden = false})])
        let changeToFire = SKAction.sequence([TBMegaLaserNode.megaLaserAnimation1!, SKAction.runBlock({self.setFireCategoryBitMask(); self.checkPlayerContact(sender);})])
        let backToBusy = SKAction.sequence([TBMegaLaserNode.megaLaserAnimation2!, SKAction.runBlock({self.color = UIColor.yellowColor(); self.setNormalCategoryBitMask()})])
        let backToNormal = SKAction.sequence([TBMegaLaserNode.megaLaserAnimation3!, SKAction.runBlock({self.color = UIColor.greenColor()})])
        let bossChangeAttack = SKAction.runBlock({if let boss = self.parent as? TBFirstBossNode {
            boss.startAttack(); self.removeFromParent()
            }})
        runAction(SKAction.group([SKAction.sequence([changeToBusy, changeToFire, backToBusy, backToNormal, bossChangeAttack]),SKAction.playSoundFileNamed("megaLaser.mp3", waitForCompletion: true)]))
    }
    
    static func createSKActionAnimation()
    {
        let megaLaserArray1 = TBUtils.getSprites(TBMegaLaserNode.megaLaserAtlas1, nomeImagens: "megalaser")
        TBMegaLaserNode.megaLaserAnimation1 = SKAction.animateWithTextures(megaLaserArray1, timePerFrame: 0.2);
        
        let megaLaserArray2 = TBUtils.getSprites(TBMegaLaserNode.megaLaserAtlas2, nomeImagens: "megalaserb")
        TBMegaLaserNode.megaLaserAnimation2 = SKAction.animateWithTextures(megaLaserArray2, timePerFrame: 0.1);
        
        let megaLaserArray3 = TBUtils.getSprites(TBMegaLaserNode.megaLaserAtlas3, nomeImagens: "laserend")
        TBMegaLaserNode.megaLaserAnimation3 = SKAction.animateWithTextures(megaLaserArray3, timePerFrame: 0.2);
    }
    
    func setNormalCategoryBitMask() {     // Categoria do laser que nao mata o player
        self.physicsBody?.categoryBitMask = GameScene.REFERENCIA_NODE
        self.physicsBody?.collisionBitMask = ~GameScene.MOEDA_NODE & ~GameScene.REFERENCIA_NODE & ~GameScene.MONSTER_NODE & ~GameScene.PLAYER_NODE & ~GameScene.OTHER_NODE & ~GameScene.BOSSONE_NODE & ~GameScene.METALBALL_NODE & ~GameScene.ESPINHOS_NODE
        self.physicsBody?.contactTestBitMask = GameScene.PLAYER_NODE & ~GameScene.BOSSONE_NODE & ~GameScene.METALBALL_NODE & ~GameScene.ESPINHOS_NODE
    }
    
    func setFireCategoryBitMask() {       // Categoria do laser que ira matar o player
        self.physicsBody?.categoryBitMask = GameScene.ESPINHOS_NODE
        self.physicsBody?.collisionBitMask = ~GameScene.MOEDA_NODE & ~GameScene.REFERENCIA_NODE & ~GameScene.MONSTER_NODE & ~GameScene.PLAYER_NODE & ~GameScene.OTHER_NODE & ~GameScene.BOSSONE_NODE & ~GameScene.METALBALL_NODE & ~GameScene.ESPINHOS_NODE
        self.physicsBody?.contactTestBitMask = GameScene.PLAYER_NODE & ~GameScene.BOSSONE_NODE & ~GameScene.METALBALL_NODE & ~GameScene.ESPINHOS_NODE
    }
    
    func checkPlayerContact(sender:GameSceneBase) {      // Checa se o player esta em contato com o megaLaser no modo que mata
        let bodies = self.physicsBody?.allContactedBodies()
        for body : SKPhysicsBody in bodies! {
            if let player = body.node as? TBPlayerNode {
                player.dangerCollision(self.physicsBody!, sender: sender)
            } else if (body.node?.name == "standNode") {
                if let player = body.node?.parent as? TBPlayerNode {
                    player.dangerCollision(self.physicsBody!, sender: sender)
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

