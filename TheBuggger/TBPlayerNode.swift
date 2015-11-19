//
//  TBPlayerNode.swift
//  TheBuggger
//
//  Created by Rafael Gouveia on 10/2/15.
//  Copyright © 2015 rfccg. All rights reserved.
//
import UIKit
import SpriteKit

class TBPlayerNode: SKSpriteNode {
    static let name = "SpawnPlayer"

    var state:States //Slides states, gesture recognizer
    var weponType:Bool // 0 sword, 1 range
    
    let defaultSpeed = 430 // era 250
    //AJUSTAR HIGH E LOW
    let highSpeed = 12*30 + 430 // use multiples of 12 for diff
    let slowSpeed = 430 - 12*20
    
    var speedBost:Bool
    var attackJoint:SKSpriteNode?
    var standJoint:SKSpriteNode?
    static var deathAnimation: SKAction?
    
    static var defenceAction:SKAction?
    static var attackActionAnimation1:SKAction?
    static var attackActionAnimation2:SKAction?
    static var walkAction:SKAction?
    static var standActionAnimation:SKAction?
    static var airActionAnimation:SKAction?
    static var fallActionAnimation:SKAction?
    
    var defenceActionChangeState:SKAction?
    var attackActionChangeState1:SKAction?
    var attackActionChangeState2:SKAction?
    var dashActionModifier:SKAction?
    
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

        TBPlayerNode.walkAction = SKAction.group([SKAction.repeatActionForever(action)])
        //SKAction.repeatActionForever(SKAction.playSoundFileNamed("Run.mp3", waitForCompletion: false))
    }
    
    static func createPlayerAttack(){
        let atackArray = TBUtils().getSprites("PlayerAttack", nomeImagens: "attack-")
        let atackArray2 = TBUtils().getSprites("PlayerAttack2", nomeImagens: "attack-")
        TBPlayerNode.attackActionAnimation1  = SKAction.group([SKAction.animateWithTextures(atackArray2, timePerFrame: 0.07), SKAction.playSoundFileNamed("attack_2.mp3", waitForCompletion: false)])
        
        
        TBPlayerNode.attackActionAnimation2 = SKAction.group([SKAction.animateWithTextures(atackArray, timePerFrame: 0.07), SKAction.playSoundFileNamed(("attack_1.mp3"), waitForCompletion: false)])
    }
    
    static func createPlayerDefense(){
        let defenceArray = TBUtils().getSprites("PlayerDefence", nomeImagens: "defend-")
         TBPlayerNode.defenceAction =  SKAction.animateWithTextures(defenceArray, timePerFrame: 0.065);
    }
    
    static func createPlayerAirAnimation(){
        let defenceArray = TBUtils().getSprites("PlayerAir", nomeImagens: "air-")
        TBPlayerNode.airActionAnimation =  SKAction.animateWithTextures(defenceArray, timePerFrame: 0.12);
    }
    static func createPlayerFallingAnimation(){
        let defenceArray = TBUtils().getSprites("PlayerFall", nomeImagens: "fall-")
        TBPlayerNode.fallActionAnimation =  SKAction.animateWithTextures(defenceArray, timePerFrame: 0.03);
    }
    
    static func createDeathAnimation()
    {
        let deathArray = TBUtils().getSprites("PlayerDeath", nomeImagens: "death")
        TBPlayerNode.deathAnimation = SKAction.animateWithTextures(deathArray, timePerFrame: 0.1);
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
        
        self.texture = walkArray[0];
        
        self.size = (texture?.size())!
        let scale = CGFloat(130/self.size.height);
        self.xScale = scale
        self.yScale = scale
        
        self.anchorPoint.y = 0.18
        //init body
        self.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(30, 45))
        self.physicsBody?.friction = 0;
        self.physicsBody?.linearDamping = 0;
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.dynamic = true
        self.physicsBody?.restitution = 0
        self.physicsBody?.velocity = CGVectorMake(CGFloat(realSpeed), 0);
        self.position = CGPointMake(216, 375)
        self.physicsBody?.mass = 0.069672822603786
      
        configDefence()
        configAttack()
        configDash()

        self.runStandingAction()
        
        self.physicsBody?.categoryBitMask = GameScene.PLAYER_NODE
        self.physicsBody!.collisionBitMask = GameScene.CHAO_NODE | GameScene.MONSTER_NODE | GameScene.TIRO_NODE | GameScene.ESPINHOS_NODE | GameScene.OTHER_NODE | GameScene.TOCO_NODE
        
        self.physicsBody!.contactTestBitMask = GameScene.MONSTER_NODE | GameScene.TIRO_NODE | GameScene.ESPINHOS_NODE | GameScene.POWERUP_NODE | GameScene.CHAO_QUICK_NODE | GameScene.CHAO_SLOW_NODE | GameScene.CHAO_NODE | GameScene.TOCO_NODE
        
        createAttackJoint()
        addAttackJoint()
        createStandingJoint()
        addStandingJoint()

    }
    
    func configDefence(){
        self.defenceActionChangeState = (SKAction.group([TBPlayerNode.defenceAction!, SKAction.sequence([SKAction.waitForDuration((TBPlayerNode.defenceAction!.duration)), SKAction.runBlock({
            self.attackState = AttackState.Idle
            
        })])]))
    }
    
    func configAttack(){
        self.attackActionChangeState1 = SKAction.group([TBPlayerNode.attackActionAnimation1!,
            SKAction.sequence([SKAction.waitForDuration(0.28), SKAction.runBlock({
                self.attackState = AttackState.Idle}
                )])])
        
        self.attackActionChangeState2 = SKAction.group([TBPlayerNode.attackActionAnimation2!,
            SKAction.sequence([SKAction.waitForDuration(0.28), SKAction.runBlock({
                self.attackState = AttackState.Idle}
                )])])
    }
    
    func configDash(){
        let dashArray = TBUtils().getSprites("PlayerDash", nomeImagens: "dash-")
        let action = SKAction.animateWithTextures(dashArray, timePerFrame: 0.09);
        self.dashActionModifier = SKAction.sequence([action, SKAction.runBlock({
            self.addStandingJoint()
        })])
    }
    
    func runWalkingAction(){
        self.removeActionForKey("stand")
        if actionForKey("walk") == nil {
            self.runAction(TBPlayerNode.walkAction!, withKey:"walk")
        }
    }
    func runStandingAction(){
        removeActionWalk()
        if actionForKey("stand") == nil{
            self.runAction(TBPlayerNode.standActionAnimation!, withKey:"stand")
        }
    }
    func removeActionWalk(){
        if(self.actionForKey("walk") != nil){
            self.removeActionForKey("walk")
        }
    }
    func runAirAction()
    {
        removeActionForKey("walk")
        if(self.actionForKey("air") == nil && self.actionForKey("attack") == nil)
        {
            self.runAction(TBPlayerNode.airActionAnimation!, withKey:"air")
        }
        
    }
    func runFallAction()
    {
        removeActionForKey("walk")
        if(self.actionForKey("fall") == nil && self.actionForKey("attack") == nil)
        {
            self.removeActionForKey("air")
            self.runAction(TBPlayerNode.fallActionAnimation!, withKey:"fall")
        }
    }

    func createStandingJoint(){
        self.standJoint = SKSpriteNode(color: SKColor.clearColor(), size: CGSizeMake(130,120))
        self.standJoint?.physicsBody = SKPhysicsBody(rectangleOfSize: (standJoint?.size)!)
        self.standJoint!.physicsBody?.affectedByGravity = false
        self.standJoint!.physicsBody?.linearDamping = 0;
        self.standJoint!.physicsBody?.friction = 0;
        self.standJoint!.physicsBody?.pinned = true
        self.standJoint!.physicsBody?.allowsRotation = false
        self.standJoint!.physicsBody?.restitution = 0
        self.standJoint!.physicsBody?.mass = 0.1
        self.standJoint!.physicsBody?.categoryBitMask = GameScene.PLAYER_NODE
        self.standJoint!.physicsBody?.collisionBitMask = self.physicsBody!.collisionBitMask
        self.standJoint!.physicsBody?.contactTestBitMask = self.physicsBody!.contactTestBitMask
        self.standJoint?.name = "standNode"
    }
    func addStandingJoint(){
        standJoint?.zRotation = 0
        self.addChild(standJoint!)
        standJoint?.position = CGPointMake(0, 145)
    }
    func removeStandingNode(){
        self.standJoint?.removeFromParent()
    }
    
    func createAttackJoint()
    {
        let atackJointSquare = SKSpriteNode(color: SKColor.clearColor(), size: CGSizeMake(570, 150))
        
        atackJointSquare.physicsBody = SKPhysicsBody(rectangleOfSize: atackJointSquare.size)
        atackJointSquare.physicsBody?.affectedByGravity = false;
        atackJointSquare.physicsBody?.linearDamping = 0;
        atackJointSquare.physicsBody?.friction = 0;
        atackJointSquare.physicsBody?.pinned = true
        atackJointSquare.physicsBody?.allowsRotation = false
        atackJointSquare.physicsBody?.restitution = 0
        atackJointSquare.physicsBody?.mass = 0.0000001
        atackJointSquare.physicsBody?.collisionBitMask = 0b0
        atackJointSquare.physicsBody?.categoryBitMask = GameScene.JOINT_ATTACK_NODE
        atackJointSquare.physicsBody?.contactTestBitMask = GameScene.MONSTER_NODE
        self.attackJoint = atackJointSquare
        
    }
    func addAttackJoint(){
        self.attackJoint?.position = CGPointMake(120 , 70)
        self.addChild(self.attackJoint!)
        self.attackJoint?.zRotation = 0

    }
    func removeAttackJoint(){
        self.attackJoint?.removeFromParent()
    }
    
    func updateVelocity(){
        if( physicsBody?.velocity.dx != CGFloat(realSpeed)){
            physicsBody?.velocity = CGVectorMake(CGFloat(realSpeed), (physicsBody?.velocity.dy)!)
        }
        //subindo
        if(self.physicsBody?.velocity.dy > 1){
            self.runAirAction()
        }
        //caindo
        if(self.physicsBody?.velocity.dy < -1){
            self.runFallAction()
        }
    }
    func resetHero(){
        self.attackState = AttackState.Idle
        self.powerUP = TBPowerUpsStates.Normal
        self.physicsBody?.pinned = false
        self.zRotation = 0
        self.score = 0
        self.addAttackJoint()
        self.runStandingAction()
    }
    func dangerCollision(bodyB:SKPhysicsBody, sender:GameScene){
        
        if(self.powerUP == TBPowerUpsStates.Frenezy){
            //Dont die
            //kill?
            
        }else if bodyB.categoryBitMask == GameScene.MONSTER_NODE && self.attackState == AttackState.Defending {
            bodyB.applyImpulse(CGVectorMake(100, 30))
            self.runAction(SKAction.playSoundFileNamed("defence", waitForCompletion: false))
            
        }else if (bodyB.categoryBitMask == GameScene.TIRO_NODE && self.attackState == AttackState.Defending) {
            
            
            if let gbotmonste = bodyB.node as? TBShotNode{
                gbotmonste.defendeAnimation()
                
            }
            //bodyB.node?.removeFromParent()
            
            
        } else{
            
            if(bodyB.categoryBitMask == GameScene.TIRO_NODE) {
                bodyB.node?.removeFromParent()
            }
            
            bodyB.collisionBitMask = GameScene.CHAO_NODE | GameScene.CHAO_SLOW_NODE | GameScene.CHAO_QUICK_NODE
            self.physicsBody?.pinned = true
            sender.stopParalax = true
            // para a animação do ataque caso ele morra
            if((self.actionForKey("attack")) != nil) {
                self.removeActionForKey("attack")
            }
            if self.actionForKey("die") == nil{
                self.runAction((SKAction.sequence([TBPlayerNode.deathAnimation!, SKAction.runBlock({
                    self.removeAttackJoint()
                    self.removeFromParent()
                    
                    sender.restartLevel()
                })])), withKey: "die")
            }
        }
    }
    
    func quickFloorCollision(bodyB:SKPhysicsBody, sender:GameScene){
        if let node  = bodyB.node as? TBChangeSpeedGround{
            if node.hadEffect! {
                return;
            }else{
                node.hadEffect = true
            }
        }
        realSpeed = max(realSpeed, defaultSpeed)
        let diff = (self.highSpeed - defaultSpeed)
        let acc = diff/12
        let accSpeed = SKAction.repeatAction( SKAction.sequence(
            [SKAction.waitForDuration(0.02), SKAction.runBlock({
                self.realSpeed = min(self.highSpeed, self.realSpeed + acc)
                }
                )]), count: 12)
        
        let deacc = diff/120
        let actSlow = SKAction.repeatAction( SKAction.sequence(
            [SKAction.waitForDuration(0.02), SKAction.runBlock({
                self.realSpeed = max(self.defaultSpeed, self.realSpeed-deacc)}
                )]), count: 120)
        runAction(SKAction.sequence([accSpeed, actSlow, SKAction.runBlock({
            self.realSpeed =  self.defaultSpeed
        })]))
    }
    
    func slowFloorCollision(bodyB:SKPhysicsBody, sender:GameScene){
        self.realSpeed = min(self.realSpeed, self.defaultSpeed)
        let diff = (self.highSpeed - defaultSpeed)
        let acc = diff/12
        let accSpeed = SKAction.repeatAction( SKAction.sequence(
            [SKAction.waitForDuration(0.02), SKAction.runBlock({
                self.realSpeed = max(self.slowSpeed, self.realSpeed - acc)
                }
                )]), count: 10)
        
        let deacc = diff/120
        let actSlow = SKAction.repeatAction( SKAction.sequence(
            [SKAction.waitForDuration(0.02), SKAction.runBlock({
                self.realSpeed = min(self.defaultSpeed, self.realSpeed+deacc)}
                )]), count: 120)
        
        runAction(SKAction.sequence([accSpeed, actSlow, SKAction.runBlock({
                self.realSpeed =  self.defaultSpeed
        })]))
    }
    func attack(){
        if( self.actionForKey("attack") == nil && self.actionForKey("die") == nil){
            let bodies =  self.attackJoint?.physicsBody?.allContactedBodies()
            
            self.attackState = AttackState.Attacking
            if rand() % 2 == 0 {
                self.runAction(SKAction.sequence([attackActionChangeState1! , SKAction.runBlock({self.runWalkingAction()})]),withKey: "attack")
            }else {
                self.runAction(SKAction.sequence([attackActionChangeState2!, SKAction.runBlock({self.runWalkingAction()})]),withKey: "attack")
            }
            
            for body : SKPhysicsBody in bodies! {
                
                if body.categoryBitMask == GameScene.MONSTER_NODE {
                    let gbotmonste = body.node as? TBMonsterProtocol
                    gbotmonste!.dieAnimation(self)
                }
            }
        }
     
    }
    
    func defence(){
        if( self.actionForKey("defence") == nil){
            self.attackState = AttackState.Defending
            runAction(SKAction.sequence([defenceActionChangeState!, SKAction.runBlock({self.runWalkingAction()})]), withKey:"defence")
            
        }
    
    }
    
    func jumpImpulse(){
        
        self.physicsBody?.applyImpulse(CGVectorMake(0.0, 130.0))
        
    }
    func jump(){
        let dashAction = self.actionForKey("dash")
        if(dashAction != nil){
            self.removeActionForKey("dash")
            self.addStandingJoint()
        }
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
    
    func dash(){
        if self.actionForKey("defence") == nil && self.actionForKey("attack") == nil && self.actionForKey("dash") == nil {
            self.removeStandingNode()
            self.runAction(self.dashActionModifier!,withKey: "dash")
        }
    }
    
    func actionCall(){
        switch state {

        case States.SD:
            dash()
            break;
        case States.SU:
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
            
        default:
            break
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


