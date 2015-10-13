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
    
    
    
    static let CHAO_NODE:UInt32             = 0b000000000001
    static let PLAYER_NODE:UInt32           = 0b000000000010
    static let MONSTER_NODE:UInt32          = 0b000000000100
    static let POWERUP_NODE:UInt32          = 0b000000001000
    static let ESPINHOS_NODE:UInt32         = 0b000000010000
    static let TIRO_NODE:UInt32             = 0b000000100000
    static let JOINT_ATTACK_NODE:UInt32     = 0b000001000000
    static let CHAO_QUICK_NODE:UInt32       = 0b000010000000
    static let CHAO_SLOW_NODE:UInt32        = 0b000100000000
    static let TOCO_NODE:UInt32             = 0b001000000000
    static let OTHER_NODE:UInt32            = 0b010000000000
    static let END_LEVEL_NODE:UInt32        = 0b100000000000
    
    
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
        

        //self.addChild(hero)
       // self.physicsWorld.addJoint(hero.addMyJoint())
        
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
    
    
    
    func setUpLevel(){
        
        //set hero position
        let spanw = self.childNodeWithName("SpawnHero")
        self.hero.position = (spanw?.position)!
       
        
        //do something with the each child type
        self.enumerateChildNodesWithName("chao", usingBlock: {
            (node:SKNode! , stop:UnsafeMutablePointer <ObjCBool>)-> Void in
            node.physicsBody = SKPhysicsBody(rectangleOfSize: node.frame.size)
            self.setObstacleTypeHit(node)
            node.physicsBody!.categoryBitMask = GameScene.CHAO_NODE
            node.physicsBody?.contactTestBitMask = GameScene.PLAYER_NODE
        })
        
        self.enumerateChildNodesWithName("plataforma", usingBlock: {
            (node:SKNode! , stop:UnsafeMutablePointer <ObjCBool>)-> Void in
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
            node.physicsBody?.categoryBitMask = GameScene.OTHER_NODE
            self.setObstacleTypeHit(node)
            
        })
        self.enumerateChildNodesWithName("Teto", usingBlock: {
            (node:SKNode! , stop:UnsafeMutablePointer <ObjCBool>)-> Void in
            node.physicsBody  = SKPhysicsBody(rectangleOfSize: node.frame.size)
            node.physicsBody?.categoryBitMask = GameScene.OTHER_NODE
            self.setObstacleTypeHit(node)
            
        })
    
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
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
        
        for touch in touches {
            let location = touch.locationInView(self.view)
            let locationPrevious = touch.previousLocationInView(self.view)
            
            let sprite = SKSpriteNode(imageNamed:"Spaceship")
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
                sprite.xScale = 0.1
                sprite.yScale = 0.1
                sprite.position = location
                let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
                sprite.runAction(SKAction.sequence([action,SKAction.removeFromParent()]))
                self.addChild(sprite)
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.hero.state = nextStatefor(self.hero.state, andInput: Directions.END)
        self.hero.actionCall()
        
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        let position = CGPointMake(hero.position.x + 360, hero.position.y + 50)
        let action = SKAction.moveTo(position, duration: 0)
        self.camera!.runAction(action)
        self.hero.updateVelocity()
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
        
        if(bodyA.categoryBitMask == GameScene.PLAYER_NODE  && bodyB.categoryBitMask == (GameScene.MONSTER_NODE | GameScene.ESPINHOS_NODE)){
            //MORRE ou PERDE VIDA
        
        
        }else if(bodyA.categoryBitMask == GameScene.CHAO_NODE  && bodyB.categoryBitMask == GameScene.PLAYER_NODE ){
            //print("\(contact.contactNormal.dy) \n")
            if(contact.contactNormal.dy>0){
                self.hero.jumpState = JumpState.CanJump
            }
            
        }
        
    }
    
    }
