//
//  GameSceneTestEnemy.swift
//  TheBuggger
//
//  Created by Victor Augusto Pereira Porciúncula on 02/10/15.
//  Copyright © 2015 rfccg. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameSceneTestEnemy: SKScene {
    var state :States = States.Initial
    var lastTouch: UITouch = UITouch()
    let kDistanceThreshold:Double = 10
    
    var player = TBPlayerNode()
    var voou = false
    
    var lastShot:CFTimeInterval = 0 // Variavel auxiliar para dar o tiro no tempo correto
    
    override func didMoveToView(view: SKView) {
        let camera = SKCameraNode();
        self.addChild(camera)
        self.camera = camera
        
        camera.position = self.player.position
        
        // Add player
        let spawn = self.childNodeWithName(TBPlayerNode.name)
        
        self.player.position = (spawn?.position)!
        self.addChild(self.player)
        
        // Add ground bots
        self.enumerateChildNodesWithName(TBGroundBotNode.name , usingBlock: {(node, ponter)->Void in

            let groundBoti = TBGroundBotNode()
            groundBoti.position = node.position
            groundBoti.name = "Monster"
            self.addChild(groundBoti)
        
        })
        
        // Add flying bots
        self.enumerateChildNodesWithName(TBFlyingBotNode.name , usingBlock: {(node, ponter)->Void in
            
            let groundBoti = TBFlyingBotNode()
            groundBoti.position = node.position
            groundBoti.name = "FlyingMonster"
            self.addChild(groundBoti)
            
        })
        
        // Add ground bot que atira
        self.enumerateChildNodesWithName(TBGroundBotNode.name+"Shot" , usingBlock: {(node, ponter)->Void in
            
            let groundBoti = TBGroundBotNode()
            groundBoti.position = node.position
            groundBoti.name = "MosterShot"
            self.addChild(groundBoti)
            
        })
        
        // Add tiro
//        self.enumerateChildNodesWithName(TBShotGroundBotNode.name , usingBlock: {(node, ponter)->Void in
//            
//            let shot = TBShotGroundBotNode()
//            shot.position = node.position
//            shot.name = "ShotBot"
//            self.addChild(shot)
//            
//        })
        
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
            self.player.physicsBody?.applyImpulse(CGVectorMake(0, 230))
            
    }
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        let position = CGPointMake(self.player.position.x + 360, self.player.position.y + 50)
        let action = SKAction.moveTo(position, duration: 0)
        self.camera!.runAction(action)
        
        checkBotAttack()
        checkBotFly()
        
        // O tempo para o tiro é a cada 5 segundos
        let delta: CFTimeInterval = currentTime - self.lastShot
        
        if(delta>5.0) {
            self.lastShot = currentTime
           // self.shooting()
        }
        
    }
    
    func checkBotAttack() {
     
        self.enumerateChildNodesWithName("Monster") { (node, ponter) -> Void in
            
            let myBot:TBGroundBotNode   = node as! TBGroundBotNode
//            print("\(myBot.position.x)  -- player \(self.player.position.x)\n")
            if(((myBot.position.x)-250 < (self.player.position.x)) && myBot.jaAtacou == false) {
                myBot.startAttack()
                myBot.jaAtacou = true
            }
            
            
        }
        
    }
    
    func checkBotFly() {
        self.enumerateChildNodesWithName("FlyingMonster") { (node, ponter) -> Void in
            
            let myBot:TBFlyingBotNode   = node as! TBFlyingBotNode
//            print("\(myBot.position.x)  -- player \(self.player.position.x)\n")
            if(((myBot.position.x)-600 < (self.player.position.x)) && myBot.jaVoou == false) {
                myBot.flying()
                myBot.jaVoou = true
            }
            
            
        }
    }
    
//    func shooting() {
//        self.enumerateChildNodesWithName(TBShotGroundBotNode.name , usingBlock: {(node, ponter)->Void in
//            
//            let shot = TBShotGroundBotNode()
//            shot.position = node.position
//            shot.name = "ShotBot"
//            self.addChild(shot)
//            
//        })
//    }
}
