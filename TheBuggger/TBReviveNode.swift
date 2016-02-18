//
//  TBReviveNode.swift
//  TheBuggger
//
//  Created by Allysson Lukas de Lima Andrade on 02/02/16.
//  Copyright © 2016 rfccg. All rights reserved.
//

import Foundation
import SpriteKit

class TBReviveNode: SKSpriteNode {
    static let name = "revive"
    static var animation: SKAction?
    var picked = false
    
    init(size: CGSize) {
        
        super.init(texture:SKTexture(), color: UIColor(), size: size)
        
        self.physicsBody = SKPhysicsBody(rectangleOfSize: self.size)
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.pinned = true
        self.physicsBody?.categoryBitMask = GameScene.REVIVE_NODE
        self.physicsBody?.contactTestBitMask = GameScene.PLAYER_NODE
        self.texture = SKTexture(imageNamed: "postoff1")
//        self.physicsBody?.collisionBitMask = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func createSKActionAnimation()
    {
        let coinsArray = TBUtils.getSprites(SKTextureAtlas(named: "postOff"), nomeImagens: "postoff")
        TBReviveNode.animation = SKAction.animateWithTextures(coinsArray, timePerFrame: 0.1);
    }
    
}