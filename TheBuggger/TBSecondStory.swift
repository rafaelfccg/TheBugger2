//
//  TBSecondStory.swift
//  TheBuggger
//
//  Created by Rafael Gouveia on 3/1/16.
//  Copyright © 2016 rfccg. All rights reserved.
//

import Foundation
import Foundation
import SpriteKit

class TBSecondStory: TBStoriesScene{
    
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        delegateChanger?.startAnimations()
    }
    
    override func prepFirstScene(){
        let action = SKAction.hide()
        let error = self.childNodeWithName("error1")
        error?.runAction(action)
    }
    override func runFirstScene() {
        sceneMark = 1
        self.moveCameraToCenter(1)
        let bar = self.childNodeWithName("barra") as? SKSpriteNode
        let scaleDif = CGFloat(1.265)
        let deltaX = (bar?.size.width)! * (scaleDif - 1 )/2
        let actionScale = SKAction.scaleXBy(scaleDif, y: 1, duration: 1)
        let actionMove = SKAction.moveByX(deltaX, y: 0, duration: 1)
        bar?.runAction(SKAction.sequence([SKAction.group([actionMove, actionScale]),SKAction.waitForDuration(0.2),SKAction.runBlock({
                let error = self.childNodeWithName("error1")
                error?.runAction(SKAction.unhide())
            
                let label = SKLabelNode(fontNamed: "Squares Bold")
                label.text = "ERROR!"
                label.zPosition  = 100
                label.fontColor = UIColor.redColor()
                label.fontSize = 60
                error?.addChild(label)
            
                label.runAction(SKAction.repeatActionForever(
                SKAction.sequence([SKAction.fadeOutWithDuration(0.3), SKAction.fadeInWithDuration(0.3)])))
        })]))
        
    }
    func runSecondScene(){
        sceneMark = 2
        self.moveCameraToCenter(2)
    }
    func runThirdScene(){
        sceneMark = 3
        self.moveCameraToCenter(3)
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if sceneMark == 1 {
            self.runSecondScene()
        }else if sceneMark == 2{
            self.runThirdScene()
        }else{
            self.endScene()
        }
    }
    func endScene(){
        self.delegateChanger?.selectLevel("SelectLevelScene")
    }
    
}
