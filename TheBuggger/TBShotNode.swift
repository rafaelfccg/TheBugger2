//
//  TBShotNode.swift
//  TheBuggger
//
//  Created by Victor Augusto Pereira Porciúncula on 06/10/15.
//  Copyright © 2015 rfccg. All rights reserved.
//

import UIKit
import SpriteKit

class TBShotNode: SKSpriteNode {
    
    static let name = "shot"
    var jaAtirou = false
    var initialTime: CFTimeInterval = 0
    static var shotAnimation: SKAction?
    static var defendedAnimation: SKAction?
    static var shotAtlas:SKTextureAtlas = SKTextureAtlas(named: "Shot")
    static var shotDefendedAtlas:SKTextureAtlas = SKTextureAtlas(named: "ShotDefended")
    
    init(shotPosition: CGPoint) {
        super.init(texture: nil, color: UIColor.whiteColor(), size: CGSizeMake(50, 50))
        
        self.jaAtirou = false
        self.position = CGPointMake(shotPosition.x, shotPosition.y+5)
        self.color = UIColor.whiteColor()
        self.size = CGSizeMake(30, 150)
        self.physicsBody = SKPhysicsBody(rectangleOfSize: self.size);
        self.physicsBody? = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.size.width, self.size.height-132))
        self.physicsBody?.velocity = CGVectorMake(-200, 0)
        self.physicsBody?.friction = CGFloat(0)
        self.physicsBody?.linearDamping = 0
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.affectedByGravity = false
        
        self.runAction(SKAction.repeatActionForever(TBShotNode.shotAnimation!))
        self.runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.waitForDuration(3), SKAction.removeFromParent()])))
        self.physicsBody?.categoryBitMask = GameScene.TIRO_NODE
        self.physicsBody?.collisionBitMask = ~GameScene.MOEDA_NODE & ~GameScene.REFERENCIA_NODE & ~GameScene.MONSTER_NODE
        self.physicsBody?.contactTestBitMask = GameScene.PLAYER_NODE
    }
    
    static func createSKActionAnimation()
    {
        let shotArray = TBUtils.getSprites(shotAtlas, nomeImagens: "shot-")
        TBShotNode.shotAnimation = SKAction.animateWithTextures(shotArray, timePerFrame: 0.5);
        
        let defendedShotArray = TBUtils.getSprites(shotDefendedAtlas, nomeImagens: "shotDefended-")
        TBShotNode.defendedAnimation = SKAction.animateWithTextures(defendedShotArray, timePerFrame: 0.05);
    }
    
    func defendeAnimation() {
        runAction(SKAction.sequence([TBShotNode.defendedAnimation!, SKAction.removeFromParent()]))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
