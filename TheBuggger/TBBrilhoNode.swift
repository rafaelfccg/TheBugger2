//
//  TBBrilhoNode.swift
//  TheBuggger
//
//  Created by Rafael Gouveia on 11/3/15.
//  Copyright © 2015 rfccg. All rights reserved.
//

import Foundation
import SpriteKit

class TBBrilhoNode {
    static var brilhoAnimation:SKAction?
    
    static func createBrilhoAnimation(){
        let pixelsArray = TBUtils().getSprites("pixels", nomeImagens: "pixels")
        TBMoedasNode.animation = SKAction.animateWithTextures(pixelsArray, timePerFrame: 0.05);
        
    }
}