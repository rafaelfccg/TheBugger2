//
//  TBStoriesScene.swift
//  TheBuggger
//
//  Created by Rafael Gouveia on 2/1/16.
//  Copyright © 2016 rfccg. All rights reserved.
//
import SpriteKit
import Foundation

class TBStoriesScene: SKScene, TBSceneProtocol {
    
    var sceneMark = 0
    var delegateChanger:SceneChangesDelegate?
    var isMethodOne:Int?
    var levelSelected:Int?
    
    override func didMoveToView(view: SKView) {
        let width:CGFloat = 1000.5
        let height = (width / self.view!.frame.size.width) * self.view!.frame.size.height
        self.size = CGSizeMake(width, height)
        
        let cam = SKCameraNode()
        self.addChild(cam)
        
        self.camera = cam
        
        let tapSign = SKLabelNode(fontNamed: "Squares Bold")
        tapSign.text = "Tap to Skip"
        tapSign.zPosition = 100
        tapSign.fontColor = UIColor.lightGrayColor()
        tapSign.fontSize = 30
        
        self.camera?.addChild(tapSign)
        tapSign.position = CGPointMake((self.view!.frame.size.width)/2 + 30, (self.view!.frame.size.height)/2 + 30)
        tapSign.runAction(SKAction.repeatActionForever(
            SKAction.sequence([SKAction.fadeOutWithDuration(1), SKAction.fadeInWithDuration(1)]
            )))


        runFirstScene()
    }
    func runFirstScene(){
        //implement on subclasses
    }
    func prepFirstScene(){
        //implement on subclasses
    }
    func moveCameraToCenter(center:Int){
        let center = self.childNodeWithName("center\(center)")
        self.camera?.position = (center?.position)!
    }

   
   
}