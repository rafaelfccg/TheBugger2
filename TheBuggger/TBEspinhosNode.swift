//
//  TBEspinhosNode.swift
//  TheBuggger
//
//  Created by Allysson Lukas de Lima Andrade on 21/10/15.
//  Copyright © 2015 rfccg. All rights reserved.
//

import Foundation
import SpriteKit

class TBEspinhosNode: SKSpriteNode {
    static let name = "espinhos"
    static var animation: SKAction?
    static let espinhosAtlas  = SKTextureAtlas(named: "Espinhos")
    
    init() {
        
        super.init(texture:SKTexture(), color: UIColor(), size: CGSizeMake(0, 0))
        
//        self.size = CGSizeMake(60, 65)
//        self.physicsBody = SKPhysicsBody(rectangleOfSize: self.size)
//        self.physicsBody?.affectedByGravity = false
//        self.physicsBody?.allowsRotation = false
//        self.physicsBody?.dynamic = true
//        self.physicsBody?.pinned = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    static func createSKActionAnimation()
    {
        let espinhosArray = TBUtils.getSprites(TBEspinhosNode.espinhosAtlas, nomeImagens: "espinho-")
        //self.texture = espinhosArray[0]
        TBEspinhosNode.animation = SKAction.animateWithTextures(espinhosArray, timePerFrame: 0.1);
    }
    
}
