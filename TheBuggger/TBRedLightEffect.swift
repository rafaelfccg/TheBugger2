//
//  TBBrilhoNode.swift
//  TheBuggger
//
//  Created by Rafael Gouveia on 11/3/15.
//  Copyright © 2015 rfccg. All rights reserved.
//

import Foundation
import SpriteKit

class TBRedLightEffect :SKSpriteNode{
    static var redLight:SKAction?
    
    static func createRedLightAnimation(){
        let pixelsArray = TBUtils().getSprites("redlight2", nomeImagens: "redlight-")
        print(pixelsArray.count)
        TBRedLightEffect.redLight = SKAction.repeatActionForever( SKAction.animateWithTextures(pixelsArray, timePerFrame: 0.15));
        
    }
}