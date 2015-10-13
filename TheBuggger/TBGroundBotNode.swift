//
//  TBGroundBotNode.swift
//  TheBuggger
//
//  Created by Victor Augusto Pereira Porciúncula on 02/10/15.
//  Copyright © 2015 rfccg. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class TBGroundBotNode: SKSpriteNode {
    static let name = "SpawnMonsterType1"
    
    var jaAtacou = false // Variavel auxiliar para o bot atacar apenas uma vez
    
    init() {
        super.init(texture: nil, color: UIColor.blackColor(), size: CGSizeMake(50, 50))
        
        self.color = UIColor.whiteColor()
        self.size = CGSizeMake(50, 50)
        self.physicsBody = SKPhysicsBody(rectangleOfSize: self.size)
        self.physicsBody?.friction = CGFloat(0)
        self.physicsBody?.linearDamping = 0
        self.physicsBody?.allowsRotation = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startAttack() {
        let tempoInvestida = CGVectorMake(-100, 0)
        let investida = SKAction.moveBy(tempoInvestida, duration: 0.2)
        self.runAction(investida)
    }

}
