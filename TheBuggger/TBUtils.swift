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
    static let spaceBotTablet = 0.03645
    static let spaceBotPhone = 0.060
    static let spaceTopTablet = 0.0375
    static let spaceTopPhone = 0.05
    
    static func getSprites(textureAtlas: SKTextureAtlas, nomeImagens: String) -> Array<SKTexture>
    {
        //let textureAtlas = SKTextureAtlas(named: textureAtlasName)
        var spriteArray = Array<SKTexture>();
        
        let numImages = textureAtlas.textureNames.count
        //        print("\(numImages)")
        for (var i=1; i <= numImages; i+=1)
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
    for (var i=0; i < textureAtlas.count; i+=1)
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

func addBottonEffects(inout camera:SKCameraNode, inout efeitoBaixo:SKNode, scene:SKScene){
    efeitoBaixo.removeFromParent();
    camera.addChild(efeitoBaixo);
    if max(UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height) < 568 {
        
        
        efeitoBaixo.position = CGPointMake(0 , (-scene.size.height/2) + CGFloat(0.145) * scene.size.height )
    }
    
    switch UIDevice.currentDevice().userInterfaceIdiom {
    case .Phone:
        efeitoBaixo.position = CGPointMake(0 , (-scene.view!.frame.size.height/2) + CGFloat(TBUtils.spaceBotPhone) * scene.view!.frame.size.height )
        break
    default :
       efeitoBaixo.position = CGPointMake(0 , (-scene.view!.frame.size.height/2) + CGFloat(TBUtils.spaceBotTablet) * scene.view!.frame.size.height )
        break
    }
    
}
func addTopEffects(inout camera:SKCameraNode, inout efeitoBaixo:SKNode, scene:SKScene){
    efeitoBaixo.removeFromParent();
    camera.addChild(efeitoBaixo);
    if max(UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height) < 568 {
        
        
        efeitoBaixo.position = CGPointMake(0 , (scene.size.height/2) - CGFloat(0.145) * scene.size.height )
    }
    
    switch UIDevice.currentDevice().userInterfaceIdiom {
    case .Phone:
        efeitoBaixo.position = CGPointMake(0 , (scene.view!.frame.size.height) - CGFloat(TBUtils.spaceTopPhone) * scene.view!.frame.size.height )
        break
    default :
       
        efeitoBaixo.position = CGPointMake(0 , (scene.view!.frame.size.height/2) - CGFloat(TBUtils.spaceTopTablet) * scene.view!.frame.size.height )
        break
    }
    
}


