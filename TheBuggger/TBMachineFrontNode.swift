//
//  TBMachineFrontNode.swift
//  TheBuggger
//
//  Created by Rafael Gouveia on 11/3/15.
//  Copyright © 2015 rfccg. All rights reserved.
//

import Foundation
import SpriteKit


class TBMachineFrontNode:SKSpriteNode {
    static var machineFrontAnimation:SKAction?
    static var machineFrontAtlas:SKTextureAtlas = SKTextureAtlas(named: "Machine");
    
    static func createMachineFrontAnimation(){
        let pixelsArray = TBUtils.getSprites(machineFrontAtlas, nomeImagens: "machinefront-")
        TBMachineFrontNode.machineFrontAnimation = SKAction.repeatActionForever(SKAction.animateWithTextures(pixelsArray, timePerFrame: 0.05));
    }
}
