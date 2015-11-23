//
//  TBBrilhoNode.swift
//  TheBuggger
//
//  Created by Rafael Gouveia on 11/3/15.
//  Copyright © 2015 rfccg. All rights reserved.
//

import Foundation
import SpriteKit

class TBEspinhoSoltoNode :SKSpriteNode{
    static var animation:SKAction?
    
    static func createSKActionAnimation(){
        let pixelsArray = TBUtils().getSprites("EspinhoSolto", nomeImagens: "espinhosolto-")
        TBEspinhoSoltoNode.animation = SKAction.repeatActionForever( SKAction.animateWithTextures(pixelsArray, timePerFrame: 0.15));
        
    }
}