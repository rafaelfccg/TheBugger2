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
    
    var num:Int? //index 0
    
    init() {
        
        super.init(texture:SKTexture(), color: UIColor(), size: CGSizeMake(0, 0))
        
        self.size = CGSizeMake(50, 50)
        self.physicsBody = SKPhysicsBody(rectangleOfSize: self.size)
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.pinned = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    static func createSKActionAnimation()
    {
        let coinsArray = TBUtils().getSprites("bits", nomeImagens: "bit-")
        TBBitNode.animation = SKAction.animateWithTextures(coinsArray, timePerFrame: 0.15);
    }
    
}
