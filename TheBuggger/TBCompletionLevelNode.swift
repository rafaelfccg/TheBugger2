//
//  TBCompletionNode.swift
//  TheBuggger
//
//  Created by Rafael Gouveia on 11/26/15.
//  Copyright © 2015 rfccg. All rights reserved.
//

import Foundation
import SpriteKit

class TBCompletionLevelNode: SKNode {
    
    
    var animate:SKAction?
    var delegateChanger:SceneChangesDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    class func unarchiveFromFile(file : String) -> TBCompletionLevelNode? {
        if let path = NSBundle.mainBundle().pathForResource(file, ofType: ".sks") {
            do{
                let sceneData = try NSData(contentsOfFile: path, options: NSDataReadingOptions.DataReadingMappedIfSafe)
                let archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
                
                archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
                let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as! TBCompletionLevelNode
                archiver.finishDecoding()
                return scene
            } catch {
                return nil
            }
        } else {
            return nil
        }
    }
    
    func setUP(attempts:Int, bits:[Bool], coins:Int, monsters:Int, pontos:Int){
//        let arr = TBUtils.getSprites("FinalScreen", nomeImagens: "final_screen-")
//        let animateBack = SKAction.animateWithTextures(arr, timePerFrame: 1)
//        
        var bitCount = 0
        if bits[0]{ bitCount+=1}
        if bits[1]{ bitCount+=1}
        if bits[2]{ bitCount+=1}
        
        let attempt  = self.childNodeWithName("Attempts") as! SKLabelNode
        attempt.text =  "Attempts: \(attempts)"
        
        let bit  = self.childNodeWithName("Bits") as! SKLabelNode
        bit.text =  "Bits: \(bitCount)/3"
        
        let coin  = self.childNodeWithName("Coins") as! SKLabelNode
        coin.text =  "Coins: \(coins)"
        
        let monster  = self.childNodeWithName("Bugs") as! SKLabelNode
        monster.text =  "Bugs killed: \(monsters)"
        
        let pontuacao = self.childNodeWithName("Pontos") as! SKLabelNode
        pontuacao.text = "\(pontos) pts"
        
//        self.animate = animateBack
    
    }
    
    func animateBackground(){
        //let back = self.childNodeWithName("Back")
        //back!.runAction(animate!)
    }
    
}
