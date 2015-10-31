//
//  TBFinalNode.swift
//  TheBuggger
//
//  Created by Allysson Lukas de Lima Andrade on 27/10/15.
//  Copyright © 2015 rfccg. All rights reserved.
//

import Foundation
import SpriteKit

class TBFinalNode: SKSpriteNode {
    
    static let name = "finalSprite"
    static let nameBack = "finalSprite2"
    static var animation: SKAction?
    static var animationBack: SKAction?
    
    init() {
        
        super.init(texture:SKTexture(), color: UIColor(), size: CGSizeMake(0, 0))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    static func createSKActionAnimation()
    {
        let finalArray = TBUtils().getSprites("ENDZONE", nomeImagens: "endzone-")
        TBFinalNode.animation = SKAction.animateWithTextures(finalArray, timePerFrame: 0.08);
        
        let finalBackArray = TBUtils().getSprites("EndzoneBack", nomeImagens: "endzoneback-")
        TBFinalNode.animationBack = SKAction.animateWithTextures(finalBackArray, timePerFrame: 0.08);
    }
    
}
