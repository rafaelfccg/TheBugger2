//
//  GameScene.swift
//  TheBuggger
//
//  Created by Rafael Gouveia on 9/28/15.
//  Copyright (c) 2015 rfccg. All rights reserved.
//

import SpriteKit


class GameScene: SKScene, SKPhysicsContactDelegate, TBPlayerNodeJointsDelegate {

    
    var state :States = States.Initial
    var lastTouch: UITouch = UITouch()
    let kDistanceThreshold:Double = 10
    var hero: TBPlayerNode = TBPlayerNode()
    let limitTimeAction:Double = 0.1
    var touchStartedAt:Double?
    
    
    
    static let CHAO_NODE:UInt32             = 0b0000000000001
    static let PLAYER_NODE:UInt32           = 0b0000000000010
    static let MONSTER_NODE:UInt32          = 0b0000000000100
    static let POWERUP_NODE:UInt32          = 0b0000000001000
    static let ESPINHOS_NODE:UInt32         = 0b0000000010000
    static let TIRO_NODE:UInt32             = 0b0000000100000
    static let JOINT_ATTACK_NODE:UInt32     = 0b0000001000000
    static let CHAO_QUICK_NODE:UInt32       = 0b0000010000000
    static let CHAO_SLOW_NODE:UInt32        = 0b0000100000000
    static let TOCO_NODE:UInt32             = 0b0001000000000
    static let OTHER_NODE:UInt32            = 0b0010000000000
    static let END_LEVEL_NODE:UInt32        = 0b0100000000000
    static let TRAMPOLIM:UInt32             = 0b1000000000000
    
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */

        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.text = "Hello, World!";
        myLabel.fontSize = 45;
        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));
        
        self.addChild(myLabel)
        hero.setUpPlayer()
        self.addChild(hero)
       
                
        let camera = SKCameraNode();
        self.addChild(camera)
        self.camera = camera
        
        camera.position = hero.position
        setUpLevel()
        
        self.physicsWorld.contactDelegate = self
        
    }
    
    func addJoint(joint: SKPhysicsJoint) {
        self.scene!.physicsWorld.addJoint(joint)
    }
    
    func setObstacleTypeHit(node: SKNode){
        node.physicsBody?.affectedByGravity = false
        node.physicsBody?.allowsRotation = false
        node.physicsBody?.dynamic = true
        node.physicsBody?.pinned = true
        //node.physicsBody?.contactTestBitMask =

    }
    
    func setTrampolimTypeHit(node: SKNode){
        //node.physicsBody?.affectedByGravity = false
        node.physicsBody?.allowsRotation = false
        //node.physicsBody?.dynamic = true
        node.physicsBody?.pinned = true
        //node.physicsBody?.contactTestBitMask =
        
    }
    
    
    
    func setUpLevel(){
        
        //set hero position
        let spanw = self.childNodeWithName("SpawnHero")
        self.hero.position = (spanw?.position)!
       
        self.enumerateChildNodesWithName(TBGroundBotNode.name , usingBlock: {(node, ponter)->Void in
            
            let groundBoti = TBGroundBotNode()
            groundBoti.position = node.position
            groundBoti.name = "Monster"
            groundBoti.physicsBody?.allowsRotation = false
            groundBoti.physicsBody?.categoryBitMask = GameScene.MONSTER_NODE
            groundBoti.physicsBody?.collisionBitMask = GameScene.CHAO_NODE | GameScene.PLAYER_NODE | GameScene.CHAO_QUICK_NODE | GameScene.CHAO_SLOW_NODE | GameScene.OTHER_NODE
            groundBoti.physicsBody?.contactTestBitMask = GameScene.PLAYER_NODE | GameScene.JOINT_ATTACK_NODE
            self.addChild(groundBoti)
            
        })
        
        //do something with the each child type
        self.enumerateChildNodesWithName("chao", usingBlock: {
            (node:SKNode! , stop:UnsafeMutablePointer <ObjCBool>)-> Void in
            node.physicsBody = SKPhysicsBody(rectangleOfSize: node.frame.size)
            self.setObstacleTypeHit(node)
            node.physicsBody!.categoryBitMask = GameScene.CHAO_NODE
            node.physicsBody?.contactTestBitMask = GameScene.PLAYER_NODE
        })
        
        self.enumerateChildNodesWithName("chao_quick", usingBlock: {
            (node:SKNode! , stop:UnsafeMutablePointer <ObjCBool>)-> Void in
            node.physicsBody = SKPhysicsBody(rectangleOfSize: node.frame.size)
            self.setObstacleTypeHit(node)
            node.physicsBody!.categoryBitMask = GameScene.CHAO_QUICK_NODE
            node.physicsBody?.contactTestBitMask = GameScene.PLAYER_NODE
        })
        
        self.enumerateChildNodesWithName("chao_slow", usingBlock: {
            (node:SKNode! , stop:UnsafeMutablePointer <ObjCBool>)-> Void in
            node.physicsBody = SKPhysicsBody(rectangleOfSize: node.frame.size)
            self.setObstacleTypeHit(node)
            node.physicsBody!.categoryBitMask = GameScene.CHAO_SLOW_NODE
            node.physicsBody?.contactTestBitMask = GameScene.PLAYER_NODE
        })
        
        self.enumerateChildNodesWithName("plataforma", usingBlock: {
            (node:SKNode! , stop:UnsafeMutablePointer <ObjCBool>)-> Void in
            
            node.physicsBody  = SKPhysicsBody(rectangleOfSize: node.frame.size)
            node.physicsBody?.categoryBitMask = GameScene.CHAO_NODE
            node.physicsBody!.contactTestBitMask = GameScene.PLAYER_NODE
            self.setObstacleTypeHit(node)
            
        })
        self.enumerateChildNodesWithName("espinhos", usingBlock: {
            (node:SKNode! , stop:UnsafeMutablePointer <ObjCBool>)-> Void in
            node.physicsBody  = SKPhysicsBody(rectangleOfSize: node.frame.size)
            node.physicsBody?.categoryBitMask = GameScene.ESPINHOS_NODE
             self.setObstacleTypeHit(node)
            
        })
        self.enumerateChildNodesWithName("parede", usingBlock: {
            (node:SKNode! , stop:UnsafeMutablePointer <ObjCBool>)-> Void in
            node.physicsBody  = SKPhysicsBody(rectangleOfSize: node.frame.size)
            node.physicsBody?.categoryBitMask = GameScene.TOCO_NODE
            self.setObstacleTypeHit(node)
            
        })
        self.enumerateChildNodesWithName("Teto", usingBlock: {
            (node:SKNode! , stop:UnsafeMutablePointer <ObjCBool>)-> Void in
            node.physicsBody  = SKPhysicsBody(rectangleOfSize: node.frame.size)
            node.physicsBody?.categoryBitMask = GameScene.OTHER_NODE
            self.setObstacleTypeHit(node)
            
        })
        self.enumerateChildNodesWithName("trampolim", usingBlock: {
            (node:SKNode! , stop:UnsafeMutablePointer <ObjCBool>)-> Void in
            node.physicsBody = SKPhysicsBody(rectangleOfSize: node.frame.size)
            self.setTrampolimTypeHit(node)
            node.physicsBody!.categoryBitMask = GameScene.TRAMPOLIM
            node.physicsBody?.contactTestBitMask = GameScene.PLAYER_NODE
        })
    
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        self.touchStartedAt  = CACurrentMediaTime()
        for touch in touches {
            //let location = touch.locationInNode(self)
            self.hero.state = States.Initial
            self.lastTouch = touch
        }
    }
    func addJointBody(bodyJoint: SKSpriteNode) {
        self.addChild(bodyJoint)
    }
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.touchStartedAt  = CACurrentMediaTime()
        for touch in touches {
            let location = touch.locationInView(self.view)
            let locationPrevious = touch.previousLocationInView(self.view)
            
           
            //Calculate movement
            let dx = Double(location.x - locationPrevious.x)
            let dy = -Double(location.y - locationPrevious.y)
            //Movement Threshold
            if (sqrt(dx*dx + dy*dy) > self.kDistanceThreshold){
                //Find movement direction
                let direc = findDirection(Double(dx), y: Double(dy))
                self.hero.state = nextStatefor(self.hero.state, andInput: direc)
                print(self.hero.state)
                // gambiarra pra ver movimento
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.hero.state = nextStatefor(self.hero.state, andInput: Directions.END)
        
       
        
        self.hero.actionCall()
        self.touchStartedAt = nil
        
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        let position = CGPointMake(hero.position.x + 360, hero.position.y + 50)
        let action = SKAction.moveTo(position, duration: 0)
        self.camera!.runAction(action)
        self.hero.updateVelocity()
        let current =  CACurrentMediaTime()
        if(self.touchStartedAt != nil &&  self.touchStartedAt! + self.limitTimeAction < current){
            self.hero.state = nextStatefor(self.hero.state, andInput: Directions.END)
            self.hero.actionCall()
            self.touchStartedAt = current
            self.hero.state = States.Initial
        }
        
        //hero.physicsBody?.velocity = CGVectorMake(100, 0)
        
       
        
        
    }
    
    //MARK -- CONTACT
    func didBeginContact(contact: SKPhysicsContact) {
        var bodyA = contact.bodyA
        var bodyB = contact.bodyB
        
        //ordena para que bodyA tenha sempre a categoria "menor"
        if(bodyA.categoryBitMask > bodyB.categoryBitMask){
            let aux = bodyB
            bodyB = bodyA
            bodyA = aux
        }
        
        if(bodyA.categoryBitMask == GameScene.PLAYER_NODE  &&
          ((bodyB.categoryBitMask == GameScene.MONSTER_NODE) ||
          (bodyB.categoryBitMask == GameScene.ESPINHOS_NODE) ||
          (bodyB.categoryBitMask == GameScene.TIRO_NODE))){
            //MORRE ou PERDE VIDA
            print("oohhh damange")
        
        
        }else if(bodyA.categoryBitMask == GameScene.CHAO_NODE  && bodyB.categoryBitMask == GameScene.PLAYER_NODE ){
            print("chao \n")
            if(contact.contactNormal.dy>0){
                self.hero.jumpState = JumpState.CanJump
            }
            if bodyB.categoryBitMask == GameScene.CHAO_QUICK_NODE {
                //hero.realSpeed += 100
                hero.realSpeed = max(hero.realSpeed, hero.defaultSpeed)
                let accSpeed = SKAction.repeatAction( SKAction.sequence(
                    [SKAction.waitForDuration(0.02), SKAction.runBlock({
                        self.hero.realSpeed = min(self.hero.highSpeed, self.hero.realSpeed + 20)
                        }
                        )]), count: 12)
                
                
                let actSlow = SKAction.repeatAction( SKAction.sequence(
                    [SKAction.waitForDuration(0.02), SKAction.runBlock({
                        self.hero.realSpeed = max(self.hero.defaultSpeed, self.hero.realSpeed-1)}
                        )]), count: 240)
                hero.runAction(SKAction.sequence([accSpeed, actSlow]))
                
            }else if bodyB.categoryBitMask == GameScene.CHAO_SLOW_NODE{
                
                hero.realSpeed = min(hero.realSpeed, hero.defaultSpeed)
                let accSpeed = SKAction.repeatAction( SKAction.sequence(
                    [SKAction.waitForDuration(0.02), SKAction.runBlock({
                        self.hero.realSpeed = max(self.hero.slowSpeed, self.hero.realSpeed - 20)
                        }
                        )]), count: 10)
                
                
                let actSlow = SKAction.repeatAction( SKAction.sequence(
                    [SKAction.waitForDuration(0.02), SKAction.runBlock({
                        self.hero.realSpeed = min(self.hero.defaultSpeed, self.hero.realSpeed+1)}
                        )]), count: 200)
                hero.runAction(SKAction.sequence([accSpeed, actSlow]))
            }
            
            
        }else if(bodyA.categoryBitMask == GameScene.MONSTER_NODE  && bodyB.categoryBitMask == (GameScene.JOINT_ATTACK_NODE )){
            if(hero.attackState == AttackState.Attacking){
                //hit monster
                bodyA.node?.removeFromParent()
                print("kill monster")
            }else{
                //hero took damange
            }
            
        } else if(bodyA.categoryBitMask == GameScene.PLAYER_NODE  && bodyB.categoryBitMask == GameScene.TRAMPOLIM ){
            print("Trampolim touched\n")
            self.hero.jumpState = JumpState.trampJump
        }
        
    }
    
    }
