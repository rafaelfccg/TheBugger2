//
//  TBMachineFrontNode.swift
//  TheBuggger
//
//  Created by Rafael Gouveia on 11/3/15.
//  Copyright © 2015 rfccg. All rights reserved.
//

import Foundation
import SpriteKit


class TBGreenLedsNode:SKSpriteNode {
    static var greenLedsAnimation:SKAction?
    
    static func createGreenLedsAnimation(){
        let pixelsArray = TBUtils().getSprites("GreenLeds", nomeImagens: "greenleds-")
        TBGreenLedsNode.greenLedsAnimation = SKAction.repeatActionForever(SKAction.animateWithTextures(pixelsArray, timePerFrame: 0.5));
    }
}
