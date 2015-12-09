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
    
    func getSprites(textureAtlas: SKTextureAtlas, nomeImagens: String) -> Array<SKTexture>
    {
        //let textureAtlas = SKTextureAtlas(named: textureAtlasName)
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
    
    static func getNextBackground()->SKTexture?{
        let textureAtlas = SKTextureAtlas(named:"Paralax2")
        let numImages = textureAtlas.textureNames.count
        let rand = Int(arc4random_uniform(100)) % (numImages+1)
        if rand == numImages{return nil}
        return textureAtlas.textureNamed(textureAtlas.textureNames[rand])
    }
}