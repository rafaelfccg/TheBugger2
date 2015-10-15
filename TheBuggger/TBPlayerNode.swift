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
    
    let defaultSpeed = 250
    let highSpeed = 550
    let slowSpeed = 100
    var speedBost:Bool
    
    var attackJoint:SKSpriteNode?
    
    var lives = 1
    var realSpeed:Int
    
    var powerUP:TBPowerUpsStates
    var jumpState:JumpState
    var attackState:AttackState
    
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
        super.init(texture:SKTexture(), color: UIColor(), size: CGSizeMake(0, 0) )
    }
    
    func setUpPlayer(){
        realSpeed = defaultSpeed
        jumpState = JumpState.CanJump
        attackState = AttackState.Idle
        var walkArray = self.getSprites("PlayerWalk", nomeImagens: "walk")
    
        self.texture = walkArray[0];
        // initialize physics body
        self.size = (texture?.size())!

        let phBody = CGSizeMake(self.size.width*0.8, self.size.height*0.8)
        self.physicsBody = SKPhysicsBody.init(texture: texture!, size: phBody)
        self.physicsBody?.friction = 0;
        self.physicsBody?.linearDamping = 0;
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.dynamic = true
        self.physicsBody?.restitution = 0
        self.physicsBody?.velocity = CGVectorMake(CGFloat(realSpeed), 0);
        self.position = CGPointMake(216, 375)
        
        let action = SKAction.animateWithTextures(walkArray, timePerFrame: 0.12);
        runAction(SKAction.repeatActionForever(action));
        
        addAttackJoint()
        
        self.physicsBody?.categoryBitMask = GameScene.PLAYER_NODE
        self.physicsBody!.collisionBitMask = GameScene.CHAO_NODE | GameScene.MONSTER_NODE | GameScene.TIRO_NODE | GameScene.ESPINHOS_NODE | GameScene.OTHER_NODE | GameScene.CHAO_QUICK_NODE | GameScene.CHAO_SLOW_NODE | GameScene.TOCO_NODE
        
        self.physicsBody!.contactTestBitMask = GameScene.MONSTER_NODE | GameScene.TIRO_NODE | GameScene.ESPINHOS_NODE | GameScene.POWERUP_NODE | GameScene.CHAO_QUICK_NODE | GameScene.CHAO_SLOW_NODE | GameScene.CHAO_NODE | GameScene.TOCO_NODE

        
    }
    
    func addAttackJoint()
    {
        let atackJointSquare = SKSpriteNode(color: SKColor.greenColor(), size: CGSizeMake(50, 20))
        
        atackJointSquare.physicsBody = SKPhysicsBody(rectangleOfSize: atackJointSquare.size)
        atackJointSquare.physicsBody?.affectedByGravity = false;
        atackJointSquare.physicsBody?.linearDamping = 0;
        atackJointSquare.physicsBody?.friction = 0;
        atackJointSquare.physicsBody?.pinned = true
        atackJointSquare.physicsBody?.allowsRotation = false
        atackJointSquare.physicsBody?.mass = 0.1
        atackJointSquare.physicsBody?.collisionBitMask = 0b0
        atackJointSquare.physicsBody?.categoryBitMask = GameScene.JOINT_ATTACK_NODE
        atackJointSquare.physicsBody?.contactTestBitMask = GameScene.MONSTER_NODE
        atackJointSquare.position = CGPointMake(30 , 0)
        
        self.attackJoint = atackJointSquare
        self.addChild(atackJointSquare)
        
    }
    
    
    func getSprites(textureAtlasName: String, nomeImagens: String) -> Array<SKTexture>
    {
        let textureAtlas = SKTextureAtlas(named: textureAtlasName)
        var spriteArray = Array<SKTexture>();
        
        let numImages = textureAtlas.textureNames.count
//        print("\(numImages)")
        for (var i=1; i <= numImages; i++)
        {
            let playerTextureName = "\(nomeImagens)\(i)"
            spriteArray.append(textureAtlas.textureNamed(playerTextureName))
        }

        return spriteArray;
    }
    
    func updateVelocity(){
        print(realSpeed)
        if( physicsBody?.velocity.dx != CGFloat(realSpeed)){
            physicsBody?.velocity = CGVectorMake(CGFloat(realSpeed), (physicsBody?.velocity.dy)!)
        }
    
    }
    
    func jump(){
        let jumpArray = self.getSprites("PlayerJump", nomeImagens: "jump")
        self.physicsBody?.applyImpulse(CGVectorMake(0, (self.physicsBody?.mass)! * 1000))
        let action = SKAction.animateWithTextures(jumpArray, timePerFrame: 0.2);
        runAction(action)
        

    }
    
    func anotherJump(){
        let jumpArray = self.getSprites("PlayerJump", nomeImagens: "jump")
        self.physicsBody?.applyForce(CGVectorMake(0, 9.8*(self.physicsBody?.mass)!), atPoint: self.position)
        self.physicsBody?.applyImpulse(CGVectorMake(0, (self.physicsBody?.mass)! * 1000))
        let action = SKAction.animateWithTextures(jumpArray, timePerFrame: 0.2);
        runAction(action)
        
        
    }
    
    func actionCall(){
        switch state{

        case States.SD:
            let dashArray = self.getSprites("PlayerDash", nomeImagens: "dash")
            
//            self.size = dashArray[0].size();
//            self.texture = dashArray[0];
//            self.physicsBody = SKPhysicsBody.init(texture: dashArray[0], size: dashArray[0].size())
//            self.physicsBody?.friction = 0;
//            self.physicsBody?.linearDamping = 0;
//            self.physicsBody?.allowsRotation = false
//            self.physicsBody?.velocity = CGVectorMake(CGFloat(constantSpeed), 0);
            
            let action = SKAction.animateWithTextures(dashArray, timePerFrame: 1);
            runAction(action)

            
            break;
        case States.SU:
//            if(weponType){
//                self.color = UIColor.whiteColor()
//            }else{
//                self.color = UIColor.blueColor()
//            }
            
            break;
        case States.SL:
            let act1 = SKAction.fadeInWithDuration(0.1)
            let act2 = SKAction.fadeOutWithDuration(0.1)
            let blink = SKAction.sequence([act2,act1])
            self.runAction(SKAction.repeatAction(blink, count: 4))
            
            let defenceArray = self.getSprites("PlayerDefence", nomeImagens: "defence")
            
            let action = SKAction.animateWithTextures(defenceArray, timePerFrame: 1.2);
            runAction(action)
           
            break;
        case States.SR:

            let atackArray = self.getSprites("PlayerAtack", nomeImagens: "atack")
            
            let action = SKAction.animateWithTextures(atackArray, timePerFrame: 0.12);
            runAction(action)
            
            self.attackState = AttackState.Attacking
            
            
            let bodies =  self.attackJoint?.physicsBody?.allContactedBodies()
            
            for body : AnyObject in bodies! {
                if body.categoryBitMask == GameScene.MONSTER_NODE {
                    body.node?!.removeFromParent()
                    
                }
            }
            
            self.runAction(SKAction.sequence ([SKAction.waitForDuration(0.36), SKAction.runBlock({ self.attackState = AttackState.Idle})]))
            
            //checkEnemy()
            
            break;
        case States.Tap:

            
            switch(jumpState){
                case JumpState.CanJump:
                    self.jump()
                    jumpState = JumpState.FirstJump
                break
                case JumpState.FirstJump:
                    if(powerUP == TBPowerUpsStates.DoubleJumper){
                        self.jump()
                        jumpState = JumpState.SecondJump
                    }
                break
                case JumpState.SecondJump:
                    
                break
                case .trampJump:
                    self.anotherJump()
                break
            }

        break;
            
        default: break
        
        }
    
    }
    

}

enum AttackState{
    case Idle
    case Attacking
}

enum JumpState{
    case CanJump
    case FirstJump
    case SecondJump
    case trampJump
    
}


