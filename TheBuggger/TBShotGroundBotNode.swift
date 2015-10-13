//
//  TBShotGroundBotNode.swift
//  TheBuggger
//
//  Created by Victor Augusto Pereira Porciúncula on 06/10/15.
//  Copyright © 2015 rfccg. All rights reserved.
//

import UIKit
import SpriteKit

class TBShotGroundBotNode: SKSpriteNode {
    
    static let name = "shot"
    
    init() {
        super.init(texture: nil, color: UIColor.blackColor(), size: CGSizeMake(50, 50))
        
        self.color = UIColor.blackColor()
        self.size = CGSizeMake(10, 10)
        self.physicsBody = SKPhysicsBody(rectangleOfSize: self.size);
        self.physicsBody?.velocity = CGVectorMake(-200, 0)
        self.physicsBody?.friction = CGFloat(0)
        self.physicsBody?.linearDamping = 0
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.affectedByGravity = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
