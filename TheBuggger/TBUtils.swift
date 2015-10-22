//
//  TBUtils.swift
//  TheBuggger
//
//  Created by Allysson Lukas de Lima Andrade on 21/10/15.
//  Copyright © 2015 rfccg. All rights reserved.
//

import Foundation
import SpriteKit

class TBUtils {
    
    func getSprites(textureAtlasName: String, nomeImagens: String) -> Array<SKTexture>
    {
        let textureAtlas = SKTextureAtlas(named: textureAtlasName)
        var spriteArray = Array<SKTexture>();
        
        let numImages = textureAtlas.textureNames.count
        //        print("\(numImages)")
        for (var i=1; i <= numImages; i++)
        {
            let playerTextureName = "\(nomeImagens)\(i)"
            spriteArray.append(textureAtlas.textureNamed(playerTextureName))
        }
        
        return spriteArray;
    }
}