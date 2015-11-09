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
    
    let defaultSpeed = 430 // era 250
    //AJUSTAR HIGH E LOW
    let highSpeed = 550
    let slowSpeed = 100
    var speedBost:Bool
    var attackJoint:SKSpriteNode?
    static var deathAnimation: SKAction?
    
    static var defenceAction:SKAction?
    static var attackActionAnimation1:SKAction?
    static var attackActionAnimation2:SKAction?
    static var walkAction:SKAction?
    static var standActionAnimation:SKAction?
    
    
    var defenceActionChangeState:SKAction?
    var attackActionChangeState1:SKAction?
    var attackActionChangeState2:SKAction?
    
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
    
    
    static func createPlayerStandAnimation(){
        let walkArray = TBUtils().getSprites("PlayerStop", nomeImagens: "stop")
        let action = SKAction.animateWithTextures(walkArray, timePerFrame: 0.15);
        
        TBPlayerNode.standActionAnimation = SKAction.repeatActionForever(action)
    }
    
    static func createPlayerWalkAnimation(){
        let walkArray = TBUtils().getSprites("PlayerRun", nomeImagens: "run-")
        let action = SKAction.animateWithTextures(walkArray, timePerFrame: 0.05);

        TBPlayerNode.walkAction = SKAction.repeatActionForever(action)
    }
    
    static func createPlayerAttack(){
        let atackArray = TBUtils().getSprites("PlayerAttack", nomeImagens: "attack-")
        let atackArray2 = TBUtils().getSprites("PlayerAttack2", nomeImagens: "attack-")
        TBPlayerNode.attackActionAnimation1  = SKAction.animateWithTextures(atackArray2, timePerFrame: 0.07)
        
        
        TBPlayerNode.attackActionAnimation2 = SKAction.animateWithTextures(atackArray, timePerFrame: 0.07)
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
        
        
        self.attackActionChangeState1 = SKAction.group([TBPlayerNode.attackActionAnimation1!,
            SKAction.sequence([SKAction.waitForDuration(0.28), SKAction.runBlock({
                self.attackState = AttackState.Idle}
            )])])
        
        self.attackActionChangeState2 = SKAction.group([TBPlayerNode.attackActionAnimation2!,
            SKAction.sequence([SKAction.waitForDuration(0.28), SKAction.runBlock({
                self.attackState = AttackState.Idle}
                )])])
        
        
        
        //runAction(TBPlayerNode.standActionAnimation!)
        self.runStandingAction()
        
        addAttackJoint()
        
        self.physicsBody?.categoryBitMask = GameScene.PLAYER_NODE
        self.physicsBody!.collisionBitMask = GameScene.CHAO_NODE | GameScene.MONSTER_NODE | GameScene.TIRO_NODE | GameScene.ESPINHOS_NODE | GameScene.OTHER_NODE | GameScene.CHAO_QUICK_NODE | GameScene.CHAO_SLOW_NODE | GameScene.TOCO_NODE
        
        self.physicsBody!.contactTestBitMask = GameScene.MONSTER_NODE | GameScene.TIRO_NODE | GameScene.ESPINHOS_NODE | GameScene.POWERUP_NODE | GameScene.CHAO_QUICK_NODE | GameScene.CHAO_SLOW_NODE | GameScene.CHAO_NODE | GameScene.TOCO_NODE

    }
    func runWalkingAction(){
        self.removeActionForKey("stand")
        self.runAction(TBPlayerNode.walkAction!, withKey:"walk")
    }
    func runStandingAction(){
        self.removeActionForKey("walk")
        self.runAction(TBPlayerNode.standActionAnimation!, withKey:"stand")
    }
    
    static func createDeathAnimation()
    {
        let deathArray = TBUtils().getSprites("PlayerDeath", nomeImagens: "death")
        TBPlayerNode.deathAnimation = SKAction.animateWithTextures(deathArray, timePerFrame: 0.1);
    }
    
    func addAttackJoint()
    {
        let atackJointSquare = SKSpriteNode(color: SKColor.clearColor(), size: CGSizeMake(570, 150))
        
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
        atackJointSquare.position = CGPointMake(120 , -70)
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
        if( self.actionForKey("attack") == nil && self.actionForKey("die") == nil){
            let bodies =  self.attackJoint?.physicsBody?.allContactedBodies()
            
            self.attackState = AttackState.Attacking
            if rand() % 2 == 0 {
                self.runAction(attackActionChangeState1!,withKey: "attack")
            }else {
                self.runAction(attackActionChangeState2!,withKey: "attack")
            }
            
            for body : SKPhysicsBody in bodies! {
                
                if body.categoryBitMask == GameScene.MONSTER_NODE {
                    let gbotmonste = body.node as? TBGroundBotNode
                    gbotmonste!.dieAnimation()
                    score += 5
                    monstersKilled++
                }
            }
//            runAction(SKAction.group([TBPlayerNode.attackActionAnimation!, SKAction.sequence([SKAction.waitForDuration(0.28), SKAction.runBlock({
//                self.attackState = AttackState.Idle})])]), withKey: "attack")
//            
//            self.attackState = AttackState.Attacking
        }
    }
    
    func defence(){
        if( self.actionForKey("defence") == nil){
            self.attackState = AttackState.Defending
            runAction(defenceActionChangeState!, withKey:"defence")
            
        }
    
    }
    
    func jumpImpulse(){
        
        self.physicsBody?.applyImpulse(CGVectorMake(0.0, 130.0))
        
    }
    func jump(){
        
            switch(jumpState){
            case JumpState.CanJump:
                if (self.physicsBody?.velocity.dy)! > -10 {
                    self.jumpImpulse()
                    jumpState = JumpState.FirstJump
                }
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
        
            defence()

           
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


