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
    
    init(){
        super.init(texture:SKTexture(), color: UIColor.clearColor(), size: CGSizeMake(40, 40))
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setUP(type:TBPowerUpsStates){
        self.color = UIColor.whiteColor()
        self.size = CGSizeMake(40, 40)
        self.powerUP = type
        self.physicsBody = SKPhysicsBody(rectangleOfSize:self.size)
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.categoryBitMask = GameScene.POWERUP_NODE
        self.physicsBody?.collisionBitMask = 0b0
        self.physicsBody?.contactTestBitMask = GameScene.PLAYER_NODE
    }
    
}