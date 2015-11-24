//
//  SelectLevelScene.swift
//  TheBuggger
//
//  Created by Rafael Gouveia on 11/9/15.
//  Copyright © 2015 rfccg. All rights reserved.
//

import UIKit
import SpriteKit


class SelectLevelScene: SKScene {
    
    let numberOfLevels:Int = 4
    var delegateChanger: SceneChangesDelegate?
    var stageSelect:SKAction?
    var minX:CGFloat?
    var maxX:CGFloat?
    let spaceBot = 0.03645
    
    
    override func didMoveToView(view: SKView) {
//        switch UIDevice.currentDevice().userInterfaceIdiom {
//        case .Phone:
//            //self.size = CGSizeMake(self.view!.frame.size.width * 1.5, self.view!.frame.size.height * 1.5)
//            break
//        default :
//            break
//        }
        
        
        //self.size = self.frame.size
        let camera = SKCameraNode();
        self.addChild(camera)
        
        self.camera = camera
        
        setUpLevelSelect()
        print(self.size)
        print(self.view!.frame.size)
        let selectionArray = TBUtils().getSprites("estagioSelect", nomeImagens: "estagio-")
        stageSelect = SKAction.animateWithTextures(selectionArray, timePerFrame: 0.1)
        
    }
    
    func setUpLevelSelect(){
        let startCameraNode = self.childNodeWithName("cameraStartCenter")
        self.camera?.position = startCameraNode!.position
        minX = startCameraNode!.position.x
        maxX = startCameraNode!.position.x
        
        let efeitoBaixo = self.childNodeWithName("efeitoBaixo")
                //let offset = CGRectGetMinY(self.frame)
        
        if max(UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height) < 568 {
            efeitoBaixo?.removeFromParent();
            camera?.addChild(efeitoBaixo!);
            
            efeitoBaixo?.position = CGPointMake(0 , (-self.size.height/2) + CGFloat(0.145) * self.size.height )
        }
        
        switch UIDevice.currentDevice().userInterfaceIdiom {
        case .Phone:
            
            break
        default :
            efeitoBaixo?.removeFromParent();
            camera?.addChild(efeitoBaixo!);

            efeitoBaixo?.position = CGPointMake(0 , (-self.view!.frame.size.height/2) + CGFloat(self.spaceBot) * self.view!.frame.size.height )
            break
        }
        
        
        
        //efeitoBaixo?.position = CGPointMake(0,)
        
        self.enumerateChildNodesWithName("levelLabel", usingBlock: {
            (node:SKNode?, stop:UnsafeMutablePointer <ObjCBool>) in
                node?.zPosition = 5
        })
        let defaults = NSUserDefaults.standardUserDefaults()
        let inLevel =  defaults.integerForKey("level")
        let openLevel = SKTexture(imageNamed: "estagio-1")
        let closedLevel = SKTexture(imageNamed: "estagio-5")
        for (var i = 1 ; i <= numberOfLevels ; i++) {
            let name = "//selectStage\(i)"
            let node:SKSpriteNode = childNodeWithName(name) as! SKSpriteNode
            if(i > inLevel){
                node.texture = closedLevel
            }else{
                node.texture = openLevel
            }
            let backgroundNode = SKShapeNode(circleOfRadius:(node.frame.size.width)/2 )
            backgroundNode.position = (node.position)
            backgroundNode.antialiased = true
            backgroundNode.fillColor = UIColor.grayColor()
            backgroundNode.zPosition = 2
            self.addChild(backgroundNode)
            node.zPosition = 10
        }
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let location = touch.locationInNode(self)
            let touchedNode = self.nodeAtPoint(location)
            let name = touchedNode.name
            var level = "-1"
            let defaults = NSUserDefaults.standardUserDefaults()
            let method = defaults.integerForKey("method")
            let inLevel =  defaults.integerForKey("level")
            print("\(name) + \(level)")
            if (name == "Back"){
                self.delegateChanger?.backToMenu()
            }else if name!.containsString("select") {
                level = (name?.substringFromIndex((name?.startIndex.advancedBy(11))!))!
            }
            if level != "-1" {
                if inLevel >= Int(level) {
                    touchedNode.runAction(SKAction.group([stageSelect!,SKAction.sequence([SKAction.waitForDuration(0.6),SKAction.runBlock({
                    
                        let levelInt = Int(level);
                        self.delegateChanger?.mudaScene("Level\(level)Scene", withMethod: method, andLevel: levelInt!)
                   
                    })])]))
                }
            }
        }
        
        
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let location = touch.locationInView(self.view)
            let locationPrevious = touch.previousLocationInView(self.view)
            //Calculate movement
            let dx = -(location.x - locationPrevious.x)
            //Movement Threshold
            if (abs(dx) > 2){
                //Find movement direction
                self.camera!.position = CGPointMake(min(max(camera!.position.x + dx,minX!), maxX! ),camera!.position.y)
            }
        }
    }
    override func update(currentTime: CFTimeInterval) {
    
    }

}
