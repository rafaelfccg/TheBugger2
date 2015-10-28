//
//  TBPlayerNode.swift
//  TheBuggger
//
//  Created by Rafael Gouveia on 10/2/15.
//  Copyright © 2015 rfccg. All rights reserved.
//

import UIKit
import SpriteKit

protocol TBPlayerNodeJointsDelegate{
    func addJoint(joint:SKPhysicsJoint)
    func addJointBody(bodyJoint:SKSpriteNode)
}

class TBPlayerNode: SKSpriteNode {
    static let name = "SpawnPlayer"

    var state:States //Slides states, gesture recognizer
    var weponType:Bool // 0 sword, 1 range
    var delegate :TBPlayerNodeJointsDelegate?
    
    let defaultSpeed = 350 // era 250
    let highSpeed = 550
    let slowSpeed = 100
    var speedBost:Bool
    var attackJoint:SKSpriteNode?
    
    static var defenceAction:SKAction?
    static var attackAction:SKAction?
    static var walkAction:SKAction?
    
    var defenceActionChangeState:SKAction?
    
    var score: Int = 0
    var monstersKilled: Int = 0
    var qtdMoedas: Int = 0
    
    
    var lives = 1
    var realSpeed:Int
    
    var powerUP:TBPowerUpsStates
    var jumpState:JumpState
    var attackState:AttackState
    
    //PlayTesting
    var method:Int?
    
    
    
    static func createPlayerWalkAnimation(){
        let walkArray = TBUtils().getSprites("PlayerRun", nomeImagens: "run-")
        let action = SKAction.animateWithTextures(walkArray, timePerFrame: 0.05);

        TBPlayerNode.walkAction = SKAction.repeatActionForever(action)
    }
    
    static func createPlayerAttack(){
        let atackArray = TBUtils().getSprites("PlayerAttack", nomeImagens: "attack-")
        TBPlayerNode.attackAction = SKAction.animateWithTextures(atackArray, timePerFrame: 0.07);
    }
    
    static func createPlayerDefense(){
        let defenceArray = TBUtils().getSprites("PlayerDefence", nomeImagens: "defend-")
         TBPlayerNode.defenceAction =  SKAction.animateWithTextures(defenceArray, timePerFrame: 0.065);
        
        

    }
    
    required init?(coder aDecoder: NSCoder) {
        state = States.Initial
        powerUP = TBPowerUpsStates.Normal
        self.weponType = false;
        self.realSpeed = defaultSpeed
        jumpState = JumpState.CanJump
        attackState = AttackState.Idle
        speedBost = false
        super.init(coder: aDecoder)
       
    }
    
    init(){
        state = States.Initial
        jumpState = JumpState.CanJump
        self.weponType = false;
        self.realSpeed = defaultSpeed
        powerUP = TBPowerUpsStates.Normal
        attackState = AttackState.Idle
        speedBost = false
        super.init(texture:SKTexture(), color: UIColor(), size: CGSizeMake(0, 0))
    }
    
    func setUpPlayer(){
        realSpeed = 0
        jumpState = JumpState.CanJump
        attackState = AttackState.Idle
        
        var walkArray = TBUtils().getSprites("PlayerRun", nomeImagens: "run-")
        
        let physicsTexture = SKTexture(imageNamed: "heroPhysicsBody")
        self.texture = walkArray[0];
        // initialize physics body
        self.size = (texture?.size())!
        let scale = CGFloat(130/self.size.height);
        self.xScale = scale
        self.yScale = scale
       
        //let phBody = CGSizeMake(self.size.width*0.8, self.size.height*0.8)
        self.physicsBody = SKPhysicsBody.init(texture: physicsTexture, size: CGSizeMake(self.size.width, self.size.height))
        self.physicsBody?.friction = 0;
        self.physicsBody?.linearDamping = 0;
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.dynamic = true
        self.physicsBody?.restitution = 0
        self.physicsBody?.velocity = CGVectorMake(CGFloat(realSpeed), 0);
        self.position = CGPointMake(216, 375)
        
        self.defenceActionChangeState = (SKAction.group([TBPlayerNode.defenceAction!, SKAction.sequence([SKAction.waitForDuration((TBPlayerNode.defenceAction!.duration)), SKAction.runBlock({
            self.attackState = AttackState.Idle
            
        })])]))
        
        runAction(TBPlayerNode.walkAction!)
        
        addAttackJoint()
        
        self.physicsBody?.categoryBitMask = GameScene.PLAYER_NODE
        self.physicsBody!.collisionBitMask = GameScene.CHAO_NODE | GameScene.MONSTER_NODE | GameScene.TIRO_NODE | GameScene.ESPINHOS_NODE | GameScene.OTHER_NODE | GameScene.CHAO_QUICK_NODE | GameScene.CHAO_SLOW_NODE | GameScene.TOCO_NODE
        
        self.physicsBody!.contactTestBitMask = GameScene.MONSTER_NODE | GameScene.TIRO_NODE | GameScene.ESPINHOS_NODE | GameScene.POWERUP_NODE | GameScene.CHAO_QUICK_NODE | GameScene.CHAO_SLOW_NODE | GameScene.CHAO_NODE | GameScene.TOCO_NODE

    }
    func runWalkingAction(){
        self.runAction(TBPlayerNode.walkAction!, withKey:"walk")
    }
    func addAttackJoint()
    {
        let atackJointSquare = SKSpriteNode(color: SKColor.clearColor(), size: CGSizeMake(600, 150))
        
        atackJointSquare.physicsBody = SKPhysicsBody(rectangleOfSize: atackJointSquare.size)
        atackJointSquare.physicsBody?.affectedByGravity = false;
        atackJointSquare.physicsBody?.linearDamping = 0;
        atackJointSquare.physicsBody?.friction = 0;
        atackJointSquare.physicsBody?.pinned = true
        atackJointSquare.physicsBody?.allowsRotation = false
        atackJointSquare.physicsBody?.restitution = 0
        atackJointSquare.physicsBody?.mass = 0.1
        atackJointSquare.physicsBody?.collisionBitMask = 0b0
        atackJointSquare.physicsBody?.categoryBitMask = GameScene.JOINT_ATTACK_NODE
        atackJointSquare.physicsBody?.contactTestBitMask = GameScene.MONSTER_NODE
        atackJointSquare.position = CGPointMake(130 , -70)
        self.attackJoint = atackJointSquare;
        self.addChild(atackJointSquare)
        
    }
    
    func updateVelocity(){
        //print(realSpeed)
        if( physicsBody?.velocity.dx != CGFloat(realSpeed)){
            physicsBody?.velocity = CGVectorMake(CGFloat(realSpeed), (physicsBody?.velocity.dy)!)
        }
    
    }
    
    func attack(){
        if( self.actionForKey("attack") == nil){
            let bodies =  self.attackJoint?.physicsBody?.allContactedBodies()
            
            for body : AnyObject in bodies! {
                if body.categoryBitMask == GameScene.MONSTER_NODE {
                    score += 5
                    monstersKilled++
                    body.node?!.removeFromParent()
                    
                }
            }
            
            runAction(SKAction.group([TBPlayerNode.attackAction!, SKAction.sequence([SKAction.waitForDuration(0.28), SKAction.runBlock({ self.attackState = AttackState.Idle})])]), withKey: "attack")
            
            self.attackState = AttackState.Attacking
            
        }

    }
    
    func jumpImpulse(){
        
        self.physicsBody?.applyImpulse(CGVectorMake(0.0, 130.0))
        
    }
    func jump(){
        if fabs((self.physicsBody?.velocity.dy)!) < 10 {
            switch(jumpState){
            case JumpState.CanJump:
                self.jumpImpulse()
                jumpState = JumpState.FirstJump
                break
            case JumpState.FirstJump:
                if(powerUP == TBPowerUpsStates.DoubleJumper){
                    self.jumpImpulse()
                    jumpState = JumpState.SecondJump
                }
                break
            case JumpState.SecondJump:
            
                break
            }
        }

    }
    
    func actionCall(){
        switch state {

        case States.SD:
            let dashArray = TBUtils().getSprites("PlayerDash", nomeImagens: "dash-")
            
        
            let action = SKAction.animateWithTextures(dashArray, timePerFrame: 0.09);
            runAction(action)

            
            break;
        case States.SU:
//            if(weponType){
//                self.color = UIColor.whiteColor()
//            }else{
//                self.color = UIColor.blueColor()
//            }
            if (method!) == 2 || method! == 3 {
                jump()
            }
            
            
            break;
        case States.SL:
            
            self.attackState = AttackState.Defending
            runAction(defenceActionChangeState!)

           
            break;
        case States.SR:
            if method! == 1  || method! == 3{
                attack()
            }
            
            
            
            break;
        case States.Tap:
            if method! == 1 {
                jump()
            }else if method! == 2{
                attack()
            }
            
            
        break;
            
        default: break
        
        }
    
    }
    

}

enum AttackState{
    case Idle
    case Attacking
    case Defending
}

enum JumpState{
    case CanJump
    case FirstJump
    case SecondJump
    
}


