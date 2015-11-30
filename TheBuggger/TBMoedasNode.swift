//
//  TBMoedasNode.swift
//  TheBuggger
//
//  Created by Allysson Lukas de Lima Andrade on 23/10/15.
//  Copyright © 2015 rfccg. All rights reserved.
//

import Foundation
import SpriteKit

class TBMoedasNode: SKSpriteNode {
    static let name = "Moeda"
    static var animation: SKAction?
    var picked = false
    
    init() {
        
        super.init(texture:SKTexture(), color: UIColor(), size: CGSizeMake(0, 0))
        
        self.size = CGSizeMake(30, 30)
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
        let coinsArray = TBUtils().getSprites("Moeda", nomeImagens: "coins-")
        TBMoedasNode.animation = SKAction.animateWithTextures(coinsArray, timePerFrame: 0.3);
    }
    
}
