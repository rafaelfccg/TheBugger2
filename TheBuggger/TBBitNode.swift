//
//  TBBitNode.swift
//  TheBuggger
//
//  Created by Rafael Gouveia on 11/13/15.
//  Copyright © 2015 rfccg. All rights reserved.
//

import Foundation
import SpriteKit

class TBBitNode: SKSpriteNode {
    static let name = "bit"
    static var animation: SKAction?
    static var bitAtlas:SKTextureAtlas = SKTextureAtlas(named: "bits")
    
    
    var picker:Bool = false
    var num:Int? //index 0
    
    init() {
        
        super.init(texture:SKTexture(), color: UIColor(), size: CGSizeMake(0, 0))
        
        self.size = CGSizeMake(50, 50)
        self.physicsBody = SKPhysicsBody(rectangleOfSize: self.size)
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.pinned = true
        self.physicsBody?.categoryBitMask = GameScene.MOEDA_NODE
        self.physicsBody?.contactTestBitMask = GameScene.PLAYER_NODE
        self.physicsBody?.collisionBitMask = ~GameScene.OTHER_NODE
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    static func createSKActionAnimation(){
    
        let coinsArray = TBUtils.getSprites(bitAtlas, nomeImagens: "bit-")
        TBBitNode.animation = SKAction.animateWithTextures(coinsArray, timePerFrame: 0.15);
    }
    func gotMe(sender:GameSceneBase){
        let myTexture = SKTexture(imageNamed: "contador-\(num! + 1)");
        let sprite = SKSpriteNode(texture: myTexture)
        sprite.size = sender.contadorNode!.size
        sprite.position = sender.contadorNode!.position
        sprite.name = sender.removable
        sender.camera?.addChild(sprite)
    }
    
}
