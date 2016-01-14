//
//  TBUtils.swift
//  TheBuggger
//
//  Created by Allysson Lukas de Lima Andrade on 21/10/15.
//  Copyright © 2015 rfccg. All rights reserved.
//

import Foundation
import SpriteKit
import AVFoundation

class TBUtils {
    
    static var paralaxAtlas = SKTextureAtlas(named:"Paralax2")
    
    static func getSprites(textureAtlas: SKTextureAtlas, nomeImagens: String) -> Array<SKTexture>
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
        let textureAtlas = TBUtils.paralaxAtlas
        let numImages = textureAtlas.textureNames.count
        let rand = Int(arc4random_uniform(100)) % (numImages+1)
        if rand == numImages{return nil}
        return textureAtlas.textureNamed(textureAtlas.textureNames[rand])
    }
}
//THIS IS A WORKARROUND FOR A BUG ON PRELOAD ALREADY IMPLEMENTED ON SPRITEKIT
func preLoadSprites(textureAtlas: [SKTextureAtlas]){
    for (var i=0; i < textureAtlas.count; i++)
    {
        
        let textNames = textureAtlas[i].textureNames
        for name in textNames {
            textureAtlas[i].textureNamed(name).size()
        }
    }
    
}

func playSound(inout backgroundMusicPlayer:AVAudioPlayer?,backgroundMusicURL:NSURL){
    
    if(backgroundMusicPlayer == nil){
        do {
            try  backgroundMusicPlayer = AVAudioPlayer(contentsOfURL: backgroundMusicURL)
            backgroundMusicPlayer!.numberOfLoops  = -1
            if(!backgroundMusicPlayer!.playing){
                backgroundMusicPlayer?.play()
            }
        }catch {
            print("MUSIC NOT FOUND")
        }
    }else{
        
        if(!backgroundMusicPlayer!.playing){
            backgroundMusicPlayer?.play()
        }
        
    }


}