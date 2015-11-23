//
//  TBPowerUpNode.swift
//  TheBuggger
//
//  Created by Rafael Gouveia on 11/15/15.
//  Copyright © 2015 rfccg. All rights reserved.
//

import Foundation
import SpriteKit

class TBPowerUpNode: SKSpriteNode {
    var powerUP:TBPowerUpsStates?
    var hadEffect = false
    static var frenesi:SKAction? = nil
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        self.size = CGSizeMake(40, 100)
        if(TBPowerUpNode.frenesi == nil){
            let arr = TBUtils().getSprites("FrenezyUpItem", nomeImagens: "PowerUpItem-")
            TBPowerUpNode.frenesi = SKAction.repeatActionForever(SKAction.animateWithTextures(arr, timePerFrame: 0.1))
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUP(type:TBPowerUpsStates){
        self.powerUP = type
        
        self.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(40, 100))
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.categoryBitMask = GameScene.POWERUP_NODE
        self.physicsBody?.collisionBitMask = 0b0
        self.physicsBody?.contactTestBitMask = GameScene.PLAYER_NODE
        
        switch type {
            case .Frenezy:
                self.runAction(TBPowerUpNode.frenesi!)
                break
            default:
                break
        }
    }
    
    
}