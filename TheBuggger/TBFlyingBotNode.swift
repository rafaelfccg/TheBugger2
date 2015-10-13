//
//  TBFlyingBotNode.swift
//  TheBuggger
//
//  Created by Victor Augusto Pereira Porciúncula on 06/10/15.
//  Copyright © 2015 rfccg. All rights reserved.
//

import UIKit
import SpriteKit

class TBFlyingBotNode: SKSpriteNode {

    static var name = "SpawnFlyingBot"
    var jaVoou = false
    
    init() {
        super.init(texture: nil, color: UIColor.blackColor(), size: CGSizeMake(50, 50))
        
        self.color = UIColor.whiteColor()
        self.size = CGSizeMake(50, 50)
        self.position = position
        self.physicsBody = SKPhysicsBody(rectangleOfSize: self.size)
        self.physicsBody?.friction = CGFloat(0)
        self.physicsBody?.linearDamping = 0
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.affectedByGravity = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func flying() {
        let tempoDecida = CGVectorMake(-20, -200)
        let decida = SKAction.moveBy(tempoDecida, duration: 0.5)
        
        let tempoSubida = CGVectorMake(-20, 200)
        let subida = SKAction.moveBy(tempoSubida, duration: 0.5)
        
        let group = SKAction.sequence([decida, subida, decida, subida, decida, subida, decida, subida, decida, subida, decida, subida])
        self.runAction(group)
    }
}
