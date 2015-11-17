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
    
    func setUP(type:TBPowerUpsStates){
        self.powerUP = type
        self.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(40, 40))
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.categoryBitMask = GameScene.POWERUP_NODE
        self.physicsBody?.collisionBitMask = 0b0
        self.physicsBody?.contactTestBitMask = GameScene.PLAYER_NODE
    }
    
}