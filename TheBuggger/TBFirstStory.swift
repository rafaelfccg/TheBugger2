//
//  TBFirstStory.swift
//  TheBuggger
//
//  Created by Rafael Gouveia on 2/1/16.
//  Copyright © 2016 rfccg. All rights reserved.
//

import Foundation
import SpriteKit

class TBFirstStory: TBStoriesScene{

    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
                
    }
    
    override func prepFirstScene(){
        let action = SKAction.hide()
        for(var i = 0; i < 11 ;i+=1){
            let node = self.childNodeWithName("\(i)")
            node?.runAction(action)
        }
        
    }
    override func runFirstScene(){
        sceneMark = 1
        self.runAction(SKAction.sequence([SKAction.waitForDuration(0.1),SKAction.runBlock({
                self.moveCameraToCenter(1)
            })]))

        let action = SKAction.unhide()
        var time = 0.7
        for(var i = 0; i < 11 ;i+=1){
            let node = self.childNodeWithName("\(i)")
            let unhide = SKAction.sequence([SKAction.waitForDuration(time),action])
            if i == 10 {
                
                node?.runAction(SKAction.sequence(
                    [unhide, SKAction.repeatActionForever(
                            SKAction.sequence([SKAction.fadeOutWithDuration(0.2), SKAction.fadeInWithDuration(0.2)]
                        ))]))
            } else {
                node?.runAction(unhide)
            }
            time +=  0.3
        }
    }
   
    func runSecondScene(){
        sceneMark = 2
        delegateChanger?.stopAnimations()
        moveCameraToCenter(2)
    
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if sceneMark == 1 {
            self.runSecondScene()
        }else if sceneMark == 2{
            self.runThirdScene()
        }else if sceneMark == 3 {
            self.runAction(SKAction.sequence([SKAction.waitForDuration(0.1), SKAction.runBlock({
                self.runFourthScene()
            })]))
        }else if sceneMark == 4{
            self.runAction(SKAction.sequence([SKAction.waitForDuration(0.1), SKAction.runBlock({
                self.runFifthScene()
            })]))
        }else if sceneMark == 5{
            self.runAction(SKAction.sequence([SKAction.waitForDuration(0.1), SKAction.runBlock({
                self.runSixthScene()
            })]))
        }else{
            self.endScene()
        }
    }
    
    func runThirdScene(){
        sceneMark = 3
        delegateChanger?.startAnimations()
        moveCameraToCenter(3)
        prepFourthScene()
        let node = self.childNodeWithName("load")
        let posInitial = node?.position
        let posFinal = CGPointMake(posInitial!.x + 280, (posInitial?.y)!)
        node?.runAction(SKAction.repeatAction(SKAction.sequence([
            SKAction.moveTo( posFinal, duration: 1.0),
            SKAction.moveTo(posInitial!, duration: 0.01)]), count: 10))
        

        self.runAction(SKAction.sequence([SKAction.waitForDuration(2.5), SKAction.runBlock({
                if self.sceneMark <= 3 {
                    self.runFourthScene()
                }
            })
        ]))
        
    }
    
    func prepFourthScene(){
        let hero = self.childNodeWithName("hero")
        hero?.runAction(SKAction.hide())
        let luz = self.childNodeWithName("luz")
        luz?.runAction(SKAction.hide())
    }
    
    func runFourthScene(){
        sceneMark = 4
        delegateChanger?.stopAnimations()
        moveCameraToCenter(4)
        let raio = self.childNodeWithName("raio")
        let textures = TBUtils.getSprites(SKTextureAtlas(named: "raio"), nomeImagens: "raio")
        raio?.runAction( SKAction.sequence(
            [SKAction.animateWithTextures(textures, timePerFrame: 0.15),
                SKAction.runBlock({
                    let hero = self.childNodeWithName("hero")
                    hero?.runAction(SKAction.unhide())
                    let luz = self.childNodeWithName("luz")
                    luz?.runAction(SKAction.unhide())
                    luz?.runAction(SKAction.repeatAction(
                        SKAction.sequence([SKAction.fadeOutWithDuration(0.7), SKAction.fadeInWithDuration(0.7)]
                        ), count: 14))
                    raio?.runAction(SKAction.hide())
            
                })
            ]))
    }
    
    func runFifthScene(){
        sceneMark = 5
        moveCameraToCenter(5)
        let eye = self.childNodeWithName("eye")
        eye?.runAction(SKAction.repeatAction(
            SKAction.sequence([SKAction.fadeOutWithDuration(0.4), SKAction.fadeInWithDuration(0.4)]
            ), count: 14))
//        self.runAction(SKAction.sequence([SKAction.waitForDuration(3),SKAction.runBlock({
//            if self.sceneMark <= 5 {
//                self.runSixthScene()
//            }
//        })]))
    }
    
    func runSixthScene(){
        sceneMark = 6
        moveCameraToCenter(6)
        let para1 = self.childNodeWithName("parallax1")
        let para2 = self.childNodeWithName("parallax2")
        
        let para1FPos = CGPointMake((para1?.position.x)! , (para1?.position.y)! + 250)
        let para2FPos = CGPointMake((para2?.position.x)! , (para2?.position.y)! + 250)
        self.camera?.runAction(SKAction.scaleBy(0.5, duration: 4))
        para1?.runAction(SKAction.moveTo(para1FPos, duration: 4))
        para2?.runAction(SKAction.moveTo(para2FPos, duration: 4))
        self.runAction(SKAction.sequence([SKAction.waitForDuration(1.5),SKAction.runBlock({
            self.endScene()
        })]))
        
    }
    func endScene(){
        delegateChanger?.mudaScene("Level1Scene", withMethod: self.isMethodOne!, andLevel: self.levelSelected!)
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(true, forKey: "story1")
    
    }
    
    
}




