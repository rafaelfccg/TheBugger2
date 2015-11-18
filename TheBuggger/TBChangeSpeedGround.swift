//
//  TBChangeSpeedGround.swift
//  TheBuggger
//
//  Created by Rafael Gouveia on 10/13/15.
//  Copyright © 2015 rfccg. All rights reserved.
//

import Foundation
import SpriteKit

class TBChangeSpeedGround: SKSpriteNode {
    var speedAdded:Int?
    var hadEffect:Bool?
    var type:Int?
    static var accelareteAnimation:SKAction?
    static var slowAnimation:SKAction?
    
    static func createAccelerateAnimation(){
        let arr = TBUtils().getSprites("speedBooster", nomeImagens: "speedBooster-")
        TBChangeSpeedGround.accelareteAnimation = SKAction.repeatActionForever( SKAction.animateWithTextures(arr, timePerFrame: 0.1))
    }
    static func createSlowAnimation(){
        let arr = TBUtils().getSprites("slow", nomeImagens: "slow-")
        TBChangeSpeedGround.slowAnimation = SKAction.repeatActionForever(SKAction.animateWithTextures(arr, timePerFrame: 0.1))
    }
    
    
    init(type:Int){
        var texture:SKTexture? 
        self.type = type
        self.hadEffect = false
        if(type == 0){
            texture = SKTexture(imageNamed: "speedBoster-1")
        }else{
            texture = SKTexture(imageNamed: "slow-1")
        }
        super.init(texture: texture, color: UIColor.clearColor(), size: texture!.size())
        
    }
    func setUPChao(){
        self.physicsBody = SKPhysicsBody(rectangleOfSize: self.size)
        self.physicsBody?.contactTestBitMask = GameScene.PLAYER_NODE
        self.physicsBody?.pinned = true
        self.physicsBody?.collisionBitMask = 0b0
        self.zPosition = 10;
        if(type == 0){
            self.runAction(TBChangeSpeedGround.accelareteAnimation!)
            self.physicsBody!.categoryBitMask = GameScene.CHAO_QUICK_NODE
            
        }else{
            self.runAction(TBChangeSpeedGround.slowAnimation!)
            self.physicsBody!.categoryBitMask = GameScene.CHAO_SLOW_NODE
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}