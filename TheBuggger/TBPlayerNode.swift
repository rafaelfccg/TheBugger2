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
    let highSpeed = 790 // use multiples of 12 for diff
    let slowSpeed = 430 - 12*20
    static let frenezyTime:NSTimeInterval = 10
    
    var speedBost:Bool
    var attackJoint:SKSpriteNode?
    var standJoint:SKSpriteNode?
    var reference: SKSpriteNode?
    static var deathAnimation: SKAction?
    static var frenezyAnimation: SKAction?
    
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
    var heroStopped = false // checar se o heroi deve ficar parado ou nao
    
    var score: Int = 0
    var monstersKilled: Int = 0
    var qtdMoedas: Int = 0
    
    var lives = 1
    var realSpeed:Int
    
    var powerUP:TBPowerUpsStates
    var jumpState:JumpState
    var actionState:ActionState
    
    var method:Int?
    
    static let frenezyAnimationAtlas = SKTextureAtlas(named: "FrenezyAnimation")
    static let playerRunAtlas = SKTextureAtlas(named: "PlayerRun")
    static let playerDashAtlas = SKTextureAtlas(named: "PlayerDash")
    
    static func createFrenezyAnimation(){
        let frenezy = TBUtils.getSprites(frenezyAnimationAtlas, nomeImagens: "powerup-")
        let action = SKAction.animateWithTextures(frenezy, timePerFrame: 0.15);
        
        let startFrenezy = TBUtils.getSprites(SKTextureAtlas(named: "FrenezyStart"), nomeImagens: "powerupstart-")
        let start =  SKAction.animateWithTextures(startFrenezy, timePerFrame: 0.09);
        
        let endFrenezy = TBUtils.getSprites(SKTextureAtlas(named: "FrenezyEnd"), nomeImagens: "powerupend-")
        let end =  SKAction.animateWithTextures(endFrenezy, timePerFrame: 0.09);
        
        let time = TBPlayerNode.frenezyTime  - (start.duration + end.duration)
        let frenezyRepetition = Int(floor(time / action.duration))
        
        TBPlayerNode.frenezyAnimation = SKAction.sequence([start,SKAction.repeatAction(action, count: frenezyRepetition ),end])
    }
    
    static func createPlayerStandAnimation(){
        let walkArray = TBUtils.getSprites(SKTextureAtlas(named: "PlayerStop"), nomeImagens: "stop")
        let action = SKAction.animateWithTextures(walkArray, timePerFrame: 0.15);
        
        TBPlayerNode.standActionAnimation = SKAction.repeatActionForever(action)
    }
    
    static func createPlayerWalkAnimation(){
        let walkArray = TBUtils.getSprites(TBPlayerNode.playerRunAtlas, nomeImagens: "run-")
        let action = SKAction.animateWithTextures(walkArray, timePerFrame: 0.05);
        
        TBPlayerNode.walkAction = SKAction.group([SKAction.repeatActionForever(action)])
        //SKAction.repeatActionForever(SKAction.playSoundFileNamed("Run.mp3", waitForCompletion: false))
    }
    
    static func createPlayerAttack(){
        let atackArray = TBUtils.getSprites(SKTextureAtlas(named: "PlayerAttack"), nomeImagens: "attack-")
        let atackArray2 = TBUtils.getSprites(SKTextureAtlas(named:"PlayerAttack22"), nomeImagens: "attack-")
        TBPlayerNode.attackActionAnimation1  = SKAction.group([SKAction.animateWithTextures(atackArray2, timePerFrame: 0.07), SKAction.playSoundFileNamed("attack_2.mp3", waitForCompletion: false)])
        
        
        TBPlayerNode.attackActionAnimation2 = SKAction.group([SKAction.animateWithTextures(atackArray, timePerFrame: 0.07), SKAction.playSoundFileNamed(("attack_1.mp3"), waitForCompletion: false)])
    }
    
    static func createPlayerDefense(){
        let defenceArray = TBUtils.getSprites(SKTextureAtlas(named:"PlayerDefence"), nomeImagens: "defend-")
        TBPlayerNode.defenceAction =  SKAction.animateWithTextures(defenceArray, timePerFrame: 0.065);
    }
    
    static func createPlayerAirAnimation(){
        let defenceArray = TBUtils.getSprites(SKTextureAtlas(named: "PlayerAir"), nomeImagens: "air-")
        TBPlayerNode.airActionAnimation =  SKAction.animateWithTextures(defenceArray, timePerFrame: 0.12);
    }
    static func createPlayerFallingAnimation(){
        let defenceArray = TBUtils.getSprites(SKTextureAtlas(named: "PlayerFall"), nomeImagens: "fall-")
        TBPlayerNode.fallActionAnimation =  SKAction.animateWithTextures(defenceArray, timePerFrame: 0.03);
    }
    
    static func createDeathAnimation()
    {
        let deathArray = TBUtils.getSprites(SKTextureAtlas(named: "PlayerDeath"), nomeImagens: "death")
        TBPlayerNode.deathAnimation = SKAction.animateWithTextures(deathArray, timePerFrame: 0.1);
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        state = States.Initial
        powerUP = TBPowerUpsStates.Normal
        self.weponType = false;
        self.realSpeed = defaultSpeed
        jumpState = JumpState.CanJump
        actionState = ActionState.Idle
        speedBost = false
        super.init(coder: aDecoder)
    }
    
    init(){
        state = States.Initial
        jumpState = JumpState.CanJump
        self.weponType = false;
        self.realSpeed = defaultSpeed
        powerUP = TBPowerUpsStates.Normal
        actionState = ActionState.Idle
        speedBost = false
        super.init(texture:SKTexture(), color: UIColor(), size: CGSizeMake(0, 0))
    }
    
    func setUpPlayer(){
        realSpeed = 0
        jumpState = JumpState.CanJump
        actionState = ActionState.Idle
        var walkArray = TBUtils.getSprites(TBPlayerNode.playerRunAtlas, nomeImagens: "run-")
        
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
        configDash()
        
        self.runStandingAction()
        
        self.physicsBody?.categoryBitMask = GameScene.PLAYER_NODE
        self.physicsBody!.collisionBitMask = GameScene.BOSSONE_NODE | GameScene.CHAO_NODE | GameScene.MONSTER_NODE | GameScene.ESPINHOS_NODE | GameScene.TOCO_NODE
    
        self.physicsBody!.contactTestBitMask = GameScene.MONSTER_NODE | GameScene.TIRO_NODE | GameScene.ESPINHOS_NODE | GameScene.POWERUP_NODE | GameScene.CHAO_QUICK_NODE | GameScene.CHAO_SLOW_NODE | GameScene.CHAO_NODE | GameScene.TOCO_NODE | GameScene.METALBALL_NODE | GameScene.REVIVE_NODE
        
        createAttackJoint()
        addAttackJoint()
        createStandingJoint()
        addStandingJoint()
        self.createPlayerReference()
        self.addPlayerReference()
    }
    
    func createPlayerReference() { // Criando uma referencia para que quando o player pule a bola de metal, ela continue fazendo as acoes
        let referencia:SKSpriteNode! = SKSpriteNode()
        referencia.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(40, 1000))
        referencia.physicsBody?.affectedByGravity = false;
        referencia.physicsBody?.linearDamping = 0;
        referencia.physicsBody?.friction = 0;
        referencia.physicsBody?.pinned = true
        referencia.physicsBody?.allowsRotation = false
        referencia.physicsBody?.restitution = 0
        referencia.physicsBody?.mass = 0.0000001
        referencia.physicsBody?.collisionBitMask = 0b0
        referencia.physicsBody?.categoryBitMask = GameScene.REFERENCIA_NODE
        referencia.physicsBody?.collisionBitMask = 0b0
        referencia.physicsBody?.contactTestBitMask = GameScene.METALBALL_NODE
        self.reference = referencia
    }
    
    func addPlayerReference() {   // Adicionando a referencia
        self.reference?.position = CGPointMake(-750 , 0)
        self.reference?.zRotation = 0
        self.addChild(self.reference!)
    }
    
    func removePlayerReference() {   // Removendo a referencia
        self.reference?.removeFromParent()
    }
    
    func configDash(){
        let dashArray = TBUtils.getSprites(TBPlayerNode.playerDashAtlas, nomeImagens: "dash-")
        let action = SKAction.animateWithTextures(dashArray, timePerFrame: 0.09);
        self.dashActionModifier = SKAction.sequence([action, SKAction.runBlock({
            self.addStandingJoint()
            if(self.actionState == .Dashing)
            {
                self.actionState = .Idle
                self.runWalkingAction()
            }
        })])
    }
    
    func runWalkingAction(){
        self.removeActionForKey("stand")
        if actionForKey("walk") == nil  && self.actionState != .Dying {
            self.runAction(TBPlayerNode.walkAction!, withKey:"walk")
        }
    }
    func runStandingAction(){
        removeActionWalk()
        if actionForKey("stand") == nil && self.checkVerticalVelocity() == .floor {
            self.runAction(TBPlayerNode.standActionAnimation!, withKey:"stand")
        }
    }
    
    func removeStandingAction(){
        if(self.actionForKey("stand") != nil){
            self.removeActionForKey("stand")
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
        if standJoint?.parent == nil{
            self.addChild(standJoint!)
        }
        standJoint?.position = CGPointMake(0, 145)
    }
    func removeStandingNode(){
        self.standJoint?.removeFromParent()
    }
    
    func createAttackJoint()
    {
        let atackJointSquare = SKSpriteNode(color: SKColor.clearColor(), size: CGSizeMake(550, 290))
        
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
        atackJointSquare.physicsBody?.contactTestBitMask = GameScene.MONSTER_NODE | GameScene.BOSSONE_NODE
        self.attackJoint = atackJointSquare
        
    }
    func addAttackJoint(){
        self.attackJoint?.position = CGPointMake(140 , 120)
        self.addChild(self.attackJoint!)
        self.attackJoint?.zRotation = 0
        
    }
    func removeAttackJoint(){
        self.attackJoint?.removeFromParent()
    }
    
    func checkVerticalVelocity() -> AirState
    {
        var airState: AirState
        
        if(self.physicsBody?.velocity.dy > 3) //subindo
        {
            airState = .air
        }
        else if(self.physicsBody?.velocity.dy < -3) //caindo
        {
            airState = .falling
        }
        else //no chão
        {
            airState = .floor
        }
        
        return airState
    }
    
    func updateVelocity(){
        if self.actionForKey("dash") == nil  && actionForKey("defence") == nil && self.actionForKey("attack") == nil && actionForKey("die") == nil{
            //subindo
            if(checkVerticalVelocity() == .air)
            {
                self.removeActionWalk()
                self.runAirAction()
            }
            //caindo
            else if(checkVerticalVelocity() == .falling)
            {
                self.removeActionWalk()
                self.runFallAction()
            }
            //no chão
            else
            {
                if (self.physicsBody?.velocity.dx > 3)
                {
                    self.removeStandingAction()
                    self.runWalkingAction()
                }
            }
        }
        if( physicsBody?.velocity.dx != CGFloat(realSpeed)){
            physicsBody?.velocity = CGVectorMake(CGFloat(realSpeed), (physicsBody?.velocity.dy)!)
        }
        
    }
    func resetHero(){
        self.actionState = ActionState.Idle
        self.powerUP = TBPowerUpsStates.Normal
        self.state = .Initial
        self.physicsBody?.pinned = false
        self.zRotation = 0
        self.score = 0
        self.qtdMoedas = 0
        self.monstersKilled = 0
        self.removeStandingNode()
        self.addStandingJoint()
        self.addAttackJoint()
        self.addPlayerReference()
        self.runStandingAction()
    }
    func activatePowerUp(type:TBPowerUpsStates){
        switch type{
        case TBPowerUpsStates.Frenezy:
            self.enterFrenezy()
            break;
        default:
            break
        }
    }
    
    func enterFrenezy(){
        self.powerUP = TBPowerUpsStates.Frenezy
        
        let powerUPnode = SKSpriteNode(imageNamed: "powerupstart-1")
        powerUPnode.size = CGSizeMake(self.size.width*4, self.size.height*4)
        self.addChild(powerUPnode)
        powerUPnode.zPosition = 1
        powerUPnode.position = CGPointMake(0, 110)
        let stateAction = SKAction.sequence([SKAction.waitForDuration(TBPlayerNode.frenezyTime), SKAction.runBlock({
            self.powerUP  = TBPowerUpsStates.Normal
            
        })])
        
        powerUPnode.runAction(SKAction.sequence([TBPlayerNode.frenezyAnimation!, SKAction.runBlock({
            powerUPnode.removeFromParent()
        })]))
        self.runAction(stateAction)
        
    }
    
    func dangerCollision(bodyB:SKPhysicsBody, sender:GameSceneBase){
        
        if(self.powerUP == TBPowerUpsStates.Frenezy){
            if let gbotmonste = bodyB.node as? TBMonsterProtocol{
                gbotmonste.dieAnimation(self)
                if ((gbotmonste as? TBGroundBotNode) != nil){
                    score+=5
                } else if ((gbotmonste as? TBShotBotNode) != nil) {
                    score+=10
                }
            }
            
        }else if bodyB.categoryBitMask == GameScene.MONSTER_NODE && self.actionState == ActionState.Defending {
            if(bodyB.node?.physicsBody?.velocity.dx == 0 && bodyB.node?.physicsBody?.velocity.dy == 0) {
                bodyB.applyImpulse(CGVectorMake(90, 75))
                print("IMPULSO")
            }
            self.runAction(SKAction.playSoundFileNamed("defence", waitForCompletion: false))
            
        }else if (bodyB.categoryBitMask == GameScene.TIRO_NODE && self.actionState == ActionState.Defending) {
            
            
            if let gbotmonste = bodyB.node as? TBShotNode{
                gbotmonste.defendeAnimation()
                
            }
            
            
        } else if (bodyB.categoryBitMask == GameScene.METALBALL_NODE && self.actionState == ActionState.Defending){
            
            if let gbotmonste2 = bodyB.node as? TBBallFirstBossNode{
                gbotmonste2.defendeAnimation()
                
            }
            
        } else{
            
            if(bodyB.categoryBitMask == GameScene.TIRO_NODE) {
                bodyB.node?.removeFromParent()
            }
            
            if(bodyB.categoryBitMask == GameScene.METALBALL_NODE) {
                if let metalBall = bodyB.node as? TBBallFirstBossNode {
                    metalBall.heroDamaged()
                }
            }
            
            bodyB.collisionBitMask = GameScene.CHAO_NODE | GameScene.CHAO_SLOW_NODE | GameScene.CHAO_QUICK_NODE
            self.physicsBody?.pinned = true
            sender.stopParalax = true
            // para a animação do ataque caso ele morra
            
            if((self.actionForKey("attack")) != nil) {
                self.removeActionForKey("attack")
            }
            if self.actionForKey("die") == nil{
                self.actionState = .Dying
                removeActionWalk()
                self.runAction(SKAction.group([(SKAction.sequence([TBPlayerNode.deathAnimation!, SKAction.runBlock({
                    self.removeAttackJoint()
                    self.removePlayerReference()
                    self.removeFromParent()
                    
                    sender.restartLevel()
                    sender.checkAd()
                    
                })])), SKAction.playSoundFileNamed("EXPLOSION_HERO", waitForCompletion: false)]), withKey: "die")
                
                
            }
        }
    }
    
    func checkHeroFloorContact(){
//        let bodies = self.physicsBody?.allContactedBodies()
//        var floorContact:Bool = false
//        
//        for body in bodies! {
//            if (body.categoryBitMask == GameScene.CHAO_SLOW_NODE ||
//                body.categoryBitMask == GameScene.CHAO_QUICK_NODE ||
//                body.categoryBitMask == GameScene.CHAO_NODE){
//                    floorContact = true
//            }
//        }
//        
//        if !floorContact && self.jumpState == .CanJump {
//            self.jumpState = .FirstJump
//        }
    
    }
    
    func quickFloorCollisionOff(bodyB: SKPhysicsBody, sender: GameSceneBase) {    // Desliga o speed
        self.realSpeed = self.defaultSpeed
    }
    func slowFloorCollisionOff(bodyB: SKPhysicsBody, sender: GameSceneBase) {      // Desliga o slow
        self.realSpeed = self.defaultSpeed
    }
    func quickFloorCollision(bodyB:SKPhysicsBody, sender:GameSceneBase){
        
        self.realSpeed = self.highSpeed
    }
    
    func slowFloorCollision(bodyB:SKPhysicsBody, sender:GameSceneBase){
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
            
            self.actionState = ActionState.Attacking
            removeActionWalk()
            if rand() % 2 == 0 {
                self.runAction(SKAction.sequence([TBPlayerNode.attackActionAnimation1! , SKAction.runBlock({self.checkPlayerTocoContact(ActionState.Attacking)})]),withKey: "attack")
            }else {
                self.runAction(SKAction.sequence([TBPlayerNode.attackActionAnimation2!, SKAction.runBlock({self.checkPlayerTocoContact(ActionState.Attacking)})]),withKey: "attack")
            }
            
            for body : SKPhysicsBody in bodies! {
                
                if body.categoryBitMask == GameScene.MONSTER_NODE {
                    let gbotmonste = body.node as? TBMonsterProtocol
                    gbotmonste!.dieAnimation(self)
                } else if body.categoryBitMask == GameScene.BOSSONE_NODE {
                    let boss = body.node as? TBFirstBossNode
                    boss?.decreaseLife()
                }
            }
        }
        
    }
    
    func checkPlayerTocoContact(estado: ActionState) {    // Checa se o player esta em contato com o toco_node, caso esteja, ele volta a ficar parado
        var encontrouToco = false
        let bodies = self.standJoint?.physicsBody?.allContactedBodies()
        
        for body: SKPhysicsBody in bodies! {
            if body.categoryBitMask == GameScene.TOCO_NODE {
                encontrouToco = true
            }
        }
        if(encontrouToco) {
            self.stopWalk()
        } else if (actionState == estado) {
            self.actionState = .Idle
            self.runWalkingAction()
        }
    }
    
    func defence(){
        if( self.actionForKey("defence") == nil && self.actionForKey("die") == nil){
            self.actionState = ActionState.Defending
            removeActionWalk()
            runAction(SKAction.sequence([TBPlayerNode.defenceAction!, SKAction.runBlock({self.checkPlayerTocoContact(ActionState.Defending)})]), withKey:"defence")
        }
    }
    
    func jumpImpulse(){
        
        self.physicsBody?.applyImpulse(CGVectorMake(0.0, 130.0))
        runAction(SKAction.playSoundFileNamed("jump.wav", waitForCompletion: true))
        
    }
    func jump(){
        self.heroStopped = false
        let dashAction = self.actionForKey("dash")
        if(dashAction != nil){
            self.removeActionForKey("dash")
            self.addStandingJoint()
        }
        switch(jumpState){
        case JumpState.CanJump:
            if checkVerticalVelocity() == .floor && actionForKey("die") == nil {
                self.jumpImpulse()
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
        if self.actionForKey("defence") == nil && self.actionForKey("attack") == nil && self.actionForKey("dash") == nil  && self.actionForKey("die") == nil{
            self.actionState = .Dashing
            self.removeStandingNode()
            self.removeActionWalk()
            if jumpState == JumpState.CanJump{
                let dashGroup = SKAction.group([self.dashActionModifier!, SKAction.playSoundFileNamed("dash", waitForCompletion: false)])
                self.runAction(dashGroup ,withKey: "dash")
            }else {
                self.runAction(self.dashActionModifier! ,withKey: "dash")
            }
        }
    }
    
    func stopWalk() {
        self.runStandingAction()
        self.heroStopped = true
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


