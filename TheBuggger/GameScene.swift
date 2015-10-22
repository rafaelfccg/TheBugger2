//
//  GameScene.swift
//  TheBuggger
//
//  Created by Rafael Gouveia on 9/28/15.
//  Copyright (c) 2015 rfccg. All rights reserved.
//

import SpriteKit

protocol SceneChangesDelegate{
    
    func mudaScene(nomeSKS: String)
}

class GameScene: SKScene, SKPhysicsContactDelegate, TBPlayerNodeJointsDelegate {

    
    var state :States = States.Initial
    var lastTouch: UITouch = UITouch()
    let kDistanceThreshold:Double = 10
    var hero: TBPlayerNode = TBPlayerNode()
    let limitTimeAction:Double = 0.1
    var touchStartedAt:Double?
    var delegateChanger: SceneChangesDelegate?
    var hudSprite:SKSpriteNode?
    var dx:CGFloat?;
    var labelScore:SKLabelNode?
    var score:Int = 0
    var count = 0
    let numFormatter = NSNumberFormatter()
    
    
    static let CHAO_NODE:UInt32             = 0b000000000010
    static let PLAYER_NODE:UInt32           = 0b000000000001
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
        numFormatter.minimumIntegerDigits = 7
        hero.setUpPlayer()
        self.addChild(hero)
        self.size = CGSizeMake(self.view!.frame.size.width * 1.5, self.view!.frame.height * 1.5)
        print(self.size)
        print(self.view!.frame.size)
        let camera = SKCameraNode();
        self.addChild(camera)
        self.camera = camera
       
        camera.position = hero.position
        setUpLevel()
        
        self.physicsWorld.gravity = CGVectorMake(0.0, -35.0) // Diminuindo a gravidade para o personagem cair mais rapido
        
        self.physicsWorld.contactDelegate = self
        
        setupHUD()
        
    }
    
    func setupHUD()
    {   
        let backTexture = SKTexture(imageNamed: "voltar")
        let back = SKSpriteNode(texture: backTexture, size: CGSizeMake(60, 60))
        back.name = "restartButton"
        self.camera!.addChild(back)
        
        back.position = CGPoint(x: -self.size.width/2 + back.size.width/2, y: self.size.height/2 - back.size.height/2)
        back.zPosition =  1000
        labelScore = SKLabelNode(text: numFormatter.stringFromNumber(0))
        labelScore?.name  = "scoreLabel"
        self.camera!.addChild(labelScore!)
        labelScore?.position = CGPointMake(back.position.x + back.size.width/2 + (labelScore?.frame.size.width)! - 10, back.position.y - 5)
        labelScore?.zPosition = 1000
        
        let powerTexture = SKTexture(imageNamed: "power1")
        let powerNode = SKSpriteNode(texture: powerTexture, size: CGSizeMake( 85, 85) )
        powerNode.name = "powerNode"
        self.camera!.addChild(powerNode)
        powerNode.position = CGPoint(x: self.size.width/2 - powerNode.size.width/2 - 15, y: -self.size.height/2 + powerNode.size.height/2 + 10)
        powerNode.zPosition = CGFloat(1000)
    }
    
    func addJoint(joint: SKPhysicsJoint) {
        self.scene!.physicsWorld.addJoint(joint)
    }
    
    func setObstacleTypeHit(node: SKNode){
        node.physicsBody?.affectedByGravity = false
        node.physicsBody?.allowsRotation = false
        node.physicsBody?.dynamic = false
        node.physicsBody?.pinned = false
        node.physicsBody?.restitution = 0
        //node.physicsBody?.contactTestBitMask =

    }
    
    func restartLevel()
    {
        delegateChanger?.mudaScene("Level1Scene")
    }
    
    
    func setUpLevel(){
        
        //set hero position
        let spanw = self.childNodeWithName("SpawnHero")
        self.hero.position = (spanw?.position)!
        self.camera?.position = CGPointMake(hero.position.x, (camera?.position.y)! - 100)
        self.hero.zPosition = 100
        
        dx = hero.position.x
        self.enumerateChildNodesWithName(TBGroundBotNode.name , usingBlock: {(node, ponter)->Void in
            
            let groundBoti = TBGroundBotNode()
            groundBoti.position = node.position
            groundBoti.name = "Monster"
            groundBoti.physicsBody?.allowsRotation = false
            node.physicsBody?.pinned = false
            groundBoti.physicsBody?.categoryBitMask = GameScene.MONSTER_NODE
            groundBoti.physicsBody?.collisionBitMask = ~GameScene.JOINT_ATTACK_NODE
            groundBoti.physicsBody?.contactTestBitMask = GameScene.PLAYER_NODE | GameScene.JOINT_ATTACK_NODE
            groundBoti.zPosition = 100
            self.addChild(groundBoti)
            
        })
        
        //do something with the each child type
        self.enumerateChildNodesWithName("chao", usingBlock: {
            (node:SKNode! , stop:UnsafeMutablePointer <ObjCBool>)-> Void in
            node.physicsBody = SKPhysicsBody(rectangleOfSize: node.frame.size)
            self.setObstacleTypeHit(node)
            node.physicsBody?.pinned = true
            node.physicsBody!.categoryBitMask = GameScene.CHAO_NODE
            node.physicsBody?.contactTestBitMask = GameScene.PLAYER_NODE
        })
        
        self.enumerateChildNodesWithName("chao_quick", usingBlock: {
            (node:SKNode! , stop:UnsafeMutablePointer <ObjCBool>)-> Void in
            node.physicsBody = SKPhysicsBody(rectangleOfSize: node.frame.size)
            self.setObstacleTypeHit(node)
            node.physicsBody?.pinned = true
            node.physicsBody!.categoryBitMask = GameScene.CHAO_QUICK_NODE
            node.physicsBody?.contactTestBitMask = GameScene.PLAYER_NODE
        })
        
        self.enumerateChildNodesWithName("chao_slow", usingBlock: {
            (node:SKNode! , stop:UnsafeMutablePointer <ObjCBool>)-> Void in
            node.physicsBody = SKPhysicsBody(rectangleOfSize: node.frame.size)
            self.setObstacleTypeHit(node)
            node.physicsBody?.pinned = true
            node.physicsBody!.categoryBitMask = GameScene.CHAO_SLOW_NODE
            node.physicsBody?.contactTestBitMask = GameScene.PLAYER_NODE
        })
        
        self.enumerateChildNodesWithName("plataforma", usingBlock: {
            (node:SKNode! , stop:UnsafeMutablePointer <ObjCBool>)-> Void in
            
            node.physicsBody  = SKPhysicsBody(rectangleOfSize: node.frame.size)
            node.physicsBody?.categoryBitMask = GameScene.CHAO_NODE
            node.physicsBody!.contactTestBitMask = GameScene.PLAYER_NODE
            node.physicsBody?.pinned = true
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
            node.physicsBody?.contactTestBitMask = GameScene.PLAYER_NODE
            node.physicsBody?.pinned = true
            self.setObstacleTypeHit(node)
            
        })
        self.enumerateChildNodesWithName("Teto", usingBlock: {
            (node:SKNode! , stop:UnsafeMutablePointer <ObjCBool>)-> Void in
            node.physicsBody  = SKPhysicsBody(rectangleOfSize: node.frame.size)
            node.physicsBody?.categoryBitMask = GameScene.OTHER_NODE
            self.setObstacleTypeHit(node)
            node.physicsBody?.pinned = true
            
        })
    
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        self.touchStartedAt  = CACurrentMediaTime()
        for touch in touches {
            //let location = touch.locationInNode(self)
            let location = touch.locationInNode(self)
            //print(location)
            let touchedNode = self.nodeAtPoint(location)
            let name = touchedNode.name
            if (name == "restartButton")
            {
                self.restartLevel()
            }
            else
            {
                self.hero.state = States.Initial
                self.lastTouch = touch
            }
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
                //print(self.hero.state)
                // gambiarra pra ver movimento
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.hero.state = nextStatefor(self.hero.state, andInput: Directions.END)
        self.hero.actionCall()
        self.touchStartedAt = nil
        
    }
    
    func updateScore(){
        labelScore!.text = numFormatter.stringFromNumber(self.score)
        
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        //let heroy = self.hero.position.y
        
        let position = CGPointMake(hero.position.x + 360, (camera?.position.y)!)
        let action = SKAction.moveTo(position, duration: 0)
        self.camera!.runAction(action)
        
        //print(CGRectGetMaxY(self.frame))
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
        var flagTrocou = false
        
        //ordena para que bodyA tenha sempre a categoria "menor"
        if(bodyA.categoryBitMask > bodyB.categoryBitMask){
            let aux = bodyB
            bodyB = bodyA
            bodyA = aux
            flagTrocou = true
        }
        
        if(bodyA.categoryBitMask == GameScene.PLAYER_NODE  &&
          (bodyB.categoryBitMask == GameScene.MONSTER_NODE) ||
          (bodyB.categoryBitMask == GameScene.ESPINHOS_NODE) ||
          (bodyB.categoryBitMask == GameScene.TIRO_NODE)){
            //MORRE ou PERDE VIDA
            restartLevel()
            print("oohhh damange")
        
        }else if(bodyA.categoryBitMask == GameScene.PLAYER_NODE &&
                (bodyB.categoryBitMask == GameScene.CHAO_SLOW_NODE ||
                 bodyB.categoryBitMask == GameScene.CHAO_QUICK_NODE ||
                 bodyB.categoryBitMask ==  GameScene.TOCO_NODE ||
                 bodyB.categoryBitMask == GameScene.CHAO_NODE)){
            //print(flagTrocou)
            var norm = sqrt(contact.contactNormal.dx * contact.contactNormal.dx +
                        contact.contactNormal.dy * contact.contactNormal.dy)
            
            if(!flagTrocou) {norm = -norm}
                    print(self.count)
                    count++
                    //print("dy  \(contact.contactNormal.dy)/\(norm) ")
            if(contact.contactNormal.dy/norm > 0.5){
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
            
        }
        
    }
    
    }
