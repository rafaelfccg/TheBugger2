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
    
    let numberOfLevels:Int = 3
    var delegateChanger: SceneChangesDelegate?
    var stageSelect:SKAction?
    
    override func didMoveToView(view: SKView) {
        //self.size = self.view!.frame.size
        let camera = SKCameraNode();
        self.addChild(camera)
        self.camera = camera
        setUpLevelSelect()
        
        let selectionArray = TBUtils().getSprites("estagioSelect", nomeImagens: "estagio-")
        stageSelect = SKAction.animateWithTextures(selectionArray, timePerFrame: 0.1)
        
    }
    
    func setUpLevelSelect(){
        let startCameraNode = self.childNodeWithName("cameraStartCenter")
        self.camera?.position = startCameraNode!.position
        
        self.enumerateChildNodesWithName("levelLabel", usingBlock: {
            (node:SKNode?, stop:UnsafeMutablePointer <ObjCBool>) in
                node?.zPosition = 5
        })
        
        for (var i = 1 ; i <= numberOfLevels ; i++) {
            let name = "//selectStage\(i)"
            let node:SKSpriteNode = childNodeWithName(name) as! SKSpriteNode
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
            var level = ""
            let defaults = NSUserDefaults.standardUserDefaults()
            let method = defaults.integerForKey("method")
            print("\(name) + \(level)")
            if (name == "Back"){
                self.delegateChanger?.backToMenu()
            }else if name!.containsString("select") {
                level = (name?.substringFromIndex((name?.startIndex.advancedBy(11))!))!
            }
            
            if( level == "1" ){
                //touchedNode.runAction(stageSelect!)
                touchedNode.runAction(SKAction.group([stageSelect!,SKAction.sequence([SKAction.waitForDuration(0.6),SKAction.runBlock({
                    
                    self.delegateChanger?.mudaScene("Level1Scene", withMethod: method)
                })])]))
                
            }else if ( level == "2" ) {
                
                touchedNode.runAction(SKAction.group([stageSelect!,SKAction.sequence([SKAction.waitForDuration(0.6),SKAction.runBlock({
                    
                    self.delegateChanger?.mudaScene("Level2Scene", withMethod: method)
                })])]))
            }else if( level == "3"){

                touchedNode.runAction(SKAction.group([stageSelect!,SKAction.sequence([SKAction.waitForDuration(0.6),SKAction.runBlock({
                    
                    self.delegateChanger?.mudaScene("Level3SceneFinal", withMethod: method)
                })])]))
                
            }
            
            
        }
        
        
    }
    override func update(currentTime: CFTimeInterval) {
    
    }

}
