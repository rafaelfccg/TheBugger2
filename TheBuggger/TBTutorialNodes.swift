//
//  TBTutorialNodes.swift
//  TheBuggger
//
//  Created by Rafael Gouveia on 10/28/15.
//  Copyright © 2015 rfccg. All rights reserved.
//

import Foundation
import SpriteKit

class TBTutorialNodes: NSObject {
    static var tapTutorialAction:SKAction?
    static var jumpTutorialAction:SKAction?
    static var slideRightTutorialAction:SKAction?
    static var slideBackTutorialAction:SKAction?
    static var slideUpTutorialAction:SKAction?
    static var attackTutorialAction:SKAction?
    static var blockTutorialAction:SKAction?
    
    static func createTapTutorialAction(){
        let coinsArray = TBUtils.getSprites(SKTextureAtlas(named: "TapTutorial"), nomeImagens: "tap")
        TBTutorialNodes.tapTutorialAction = SKAction.animateWithTextures(coinsArray, timePerFrame: 0.5);
    }
    static func createJumpTutorialAction(){
        let coinsArray = TBUtils.getSprites(SKTextureAtlas(named:"JumpTutorial"), nomeImagens: "jump")
        TBTutorialNodes.jumpTutorialAction = SKAction.animateWithTextures(coinsArray, timePerFrame: 0.5);
    }
    static func createSlideRightTutorialAction(){
        let coinsArray = TBUtils.getSprites(SKTextureAtlas(named:"SlideFrontTutorial"), nomeImagens: "slidefront")
        TBTutorialNodes.slideRightTutorialAction = SKAction.animateWithTextures(coinsArray, timePerFrame: 0.5);
    }
    
    static func createSlideBackTutorialAction(){
        let coinsArray = TBUtils.getSprites(SKTextureAtlas(named:"SlideBackTutorial"), nomeImagens: "slideback-")
        TBTutorialNodes.slideBackTutorialAction = SKAction.animateWithTextures(coinsArray, timePerFrame: 0.5);
    }
    
    static func createAttackTutorialAction(){
        let coinsArray = TBUtils.getSprites(SKTextureAtlas(named:"AttackTutorial"), nomeImagens: "attak")
        TBTutorialNodes.attackTutorialAction = SKAction.animateWithTextures(coinsArray, timePerFrame: 0.5);
    }
    
    static func createBlockTutorialAction(){
        let coinsArray = TBUtils.getSprites(SKTextureAtlas(named:"BlockTutorial"), nomeImagens: "block")
        TBTutorialNodes.blockTutorialAction = SKAction.animateWithTextures(coinsArray, timePerFrame: 0.5);
    }
    
    static func createSlideUpTutorialAction(){
        let coinsArray = TBUtils.getSprites(SKTextureAtlas(named:"SlideUpTutorial"), nomeImagens: "slideup")
        TBTutorialNodes.slideUpTutorialAction = SKAction.animateWithTextures(coinsArray, timePerFrame: 0.5);
    }
}