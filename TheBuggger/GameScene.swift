//
//  GameScene.swift
//  TheBuggger
//
//  Created by Rafael Gouveia on 9/28/15.
//  Copyright (c) 2015 rfccg. All rights reserved.
//

import SpriteKit
import AVFoundation

protocol SceneChangesDelegate{
    
    func mudaScene(nomeSKS: String, withMethod:Int)
    func backToMenu()
}

class GameScene: SKScene, SKPhysicsContactDelegate, TBPlayerNodeJointsDelegate {

    
    var state :States = States.Initial
    let kDistanceThreshold:Double = 10
    var hero: TBPlayerNode = TBPlayerNode()
    let limitTimeAction:Double = 0.1
    var touchStartedAt:Double?
    var delegateChanger: SceneChangesDelegate?
    var hudSprite:SKSpriteNode?
    var dx:CGFloat?;
    var labelScore:SKLabelNode?
    
    var tapToStartLabel:SKLabelNode?
    var hasBegan:Bool = false
    
    let removable = "removable"
    
    var count = 0
    
    let numFormatter = NSNumberFormatter()
    //parallax
    var skyNode:SKSpriteNode?
    var skyNodeNext:SKSpriteNode?
    
    var deltaTime : NSTimeInterval = 0
    var lastFrameTime :NSTimeInterval  = 0
    //camera
    var cameraPosition:CGPoint = CGPoint()
    var cameraAction:SKAction = SKAction()
    
    var cameraPostionUp:CGPoint = CGPoint()
    var cameraActionUp:SKAction = SKAction()
    
    var topLimit:CGPoint = CGPointMake(0, 430)
    // count number of deaths
    var numberOfDeath:Int = 0
    
    var firstHeroPosition:CGPoint = CGPoint()
    
    var firstCameraPos:CGPoint = CGPointMake(0, 220)
    
    var upDone = false
    
    var stateCamera = "normal"
    
    var backgroundMusicPlayer:AVAudioPlayer?
    
    //PlayTesting
    var isMethodOne:Int?
    
    static let CHAO_NODE:UInt32             = 0b0000000000010
    static let PLAYER_NODE:UInt32           = 0b0000000000001
    static let MONSTER_NODE:UInt32          = 0b0000000000100
    static let POWERUP_NODE:UInt32          = 0b0000000001000
    static let ESPINHOS_NODE:UInt32         = 0b0000000010000
    static let TIRO_NODE:UInt32             = 0b0000000100000
    static let JOINT_ATTACK_NODE:UInt32     = 0b0000001000000
    static let CHAO_QUICK_NODE:UInt32       = 0b0000010000000
    static let CHAO_SLOW_NODE:UInt32        = 0b0000100000000
    static let TOCO_NODE:UInt32             = 0b0001000000000
    static let MOEDA_NODE:UInt32            = 0b0010000000000
    static let OTHER_NODE:UInt32            = 0b0100000000000
    static let END_LEVEL_NODE:UInt32        = 0b1000000000000

    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        hero.method = isMethodOne
        self.addChild(hero)
        hero.setUpPlayer()
        self.size = CGSizeMake(self.view!.frame.size.width * 1.5, self.view!.frame.height * 1.5)
        let camera = SKCameraNode();
        self.addChild(camera)
        self.camera = camera
        
        numFormatter.minimumIntegerDigits = 9
        
        skyNode = SKSpriteNode(imageNamed: "sky")
        skyNode?.size = self.size
        skyNodeNext = SKSpriteNode(imageNamed: "sky")
        skyNodeNext?.size = self.size
        camera.position = hero.position
        setUpLevel()
        
        camera.addChild(skyNode!)
        camera.addChild(skyNodeNext!)
        skyNode?.position = CGPoint(x: 0,y: 0)
        skyNode?.zPosition = -100
        skyNodeNext?.position = CGPoint(x: (skyNode?.position.x)! + (skyNode?.frame.size.width)!,y: 0)
        skyNodeNext?.zPosition = -99
        
        self.physicsWorld.gravity = CGVectorMake(0.0, -35.0) // Diminuindo a gravidade para o personagem cair mais rapido
        
        self.physicsWorld.contactDelegate = self
        
        
        setupHUD()
        
        tapToStartLabel = SKLabelNode(text: "TAP TO START")
        self.camera!.addChild(tapToStartLabel!)

        
        if(backgroundMusicPlayer == nil){
        
            let backgroundMusicURL = NSBundle.mainBundle().URLForResource("Move_Ya", withExtension: ".mp3")
            
            do {
              try  backgroundMusicPlayer = AVAudioPlayer(contentsOfURL: backgroundMusicURL!)
              backgroundMusicPlayer!.numberOfLoops  = -1
                if(backgroundMusicPlayer!.playing){
                    self.backgroundMusicPlayer?.play()
                }
            }catch {
                print("MUSIC NOT FOUND")
            }
        }
        

    }
    
    func startGame(){
        hero.realSpeed = hero.defaultSpeed
        hero.runWalkingAction() 
        tapToStartLabel?.removeFromParent()
    }
    
    func moveSprite(sprite : SKSpriteNode,
        nextSprite : SKSpriteNode, speed : Float) -> Void {
            var newPosition = CGPointZero
            // Shift the sprite leftward based on the speed
            newPosition = sprite.position
            newPosition.x -= CGFloat(speed * Float(deltaTime))
            sprite.position = newPosition
            // If this sprite is now offscreen (i.e., its rightmost edge is
            // farther left than the scene's leftmost edge):
            if (sprite.position.x <= -sprite.frame.size.width) {
                // Shift it over so that it's now to the immediate right
                // of the other sprite.
                // This means that the two sprites are effectively
                // leap-frogging each other as they both move.
                sprite.position =
                    CGPoint(x:
                        nextSprite.position.x + nextSprite.frame.size.width - 3.5,
                        y: sprite.position.y)
                sprite.zPosition = -99
                nextSprite.zPosition = -100
                
            }
            
            newPosition = nextSprite.position
            newPosition.x -= CGFloat(speed * Float(deltaTime))
            nextSprite.position = newPosition
            // If this sprite is now offscreen (i.e., its rightmost edge is
            // farther left than the scene's leftmost edge):
            if (nextSprite.position.x <= -nextSprite.frame.size.width ) {
                // Shift it over so that it's now to the immediate right
                // of the other sprite.
                // This means that the two sprites are effectively
                // leap-frogging each other as they both move.
                nextSprite.position =
                    CGPoint(x:
                        sprite.position.x + sprite.frame.size.width - 3.5 ,
                        y: nextSprite.position.y)
                sprite.zPosition = -100
                nextSprite.zPosition = -99
            }

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
        //delegateChanger?.mudaScene("Level1SceneFinal", withMethod: self.isMethodOne!)
        self.numberOfDeath++
        
        self.enumerateChildNodesWithName(self.removable, usingBlock: {
            (node, ponter)->Void in
            
            node.removeFromParent()

            })
        let method = hero.method
        setHeroPosition()
        self.hero.score = 0;
        
        self.addChild(hero)
        
        hero.method = method
        
        skyNode?.position = CGPoint(x: 0,y: 0)
        skyNodeNext?.position = CGPoint(x: (skyNode?.position.x)! + (skyNode?.frame.size.width)!,y: 0)

        if(tapToStartLabel?.parent == nil){
            self.camera!.addChild(tapToStartLabel!)
        }
        
        spawnMoedas()
        spawnMonstros()
        
        
    }
    
    func spawnMonstros(){
        self.enumerateChildNodesWithName(TBGroundBotNode.name , usingBlock: {(node, ponter)->Void in
            
            let groundBoti = TBGroundBotNode()
            
            groundBoti.position = node.position
            groundBoti.name = self.removable
            groundBoti.physicsBody?.allowsRotation = false
            node.physicsBody?.pinned = false
            groundBoti.physicsBody?.categoryBitMask = GameScene.MONSTER_NODE
            groundBoti.physicsBody?.collisionBitMask = ~GameScene.JOINT_ATTACK_NODE
            groundBoti.physicsBody?.contactTestBitMask = GameScene.PLAYER_NODE | GameScene.JOINT_ATTACK_NODE
            groundBoti.zPosition = 100
            self.addChild(groundBoti)
            
        })
        
    }
    func spawnMoedas(){
        self.enumerateChildNodesWithName("moeda", usingBlock: {
            (node:SKNode! , stop:UnsafeMutablePointer <ObjCBool>)-> Void in
            let moeda = TBMoedasNode()
            moeda.position = node.position
            moeda.physicsBody?.categoryBitMask = GameScene.MOEDA_NODE
            moeda.physicsBody?.contactTestBitMask = GameScene.PLAYER_NODE
            moeda.name  = self.removable
            self.addChild(moeda)
            
            moeda.runAction(SKAction.repeatActionForever( TBMoedasNode.animation! ))
            
        })
    }
    
    func backtToMenu(){
        delegateChanger?.backToMenu()   
    }
    
    func setHeroPosition(){
        let spanw = self.childNodeWithName("SpawnHero")
        
        self.hero.position = (spanw!.position)
        self.hero.realSpeed = 0
        hero.updateVelocity()
        print(hero.position)
        self.camera?.position = CGPointMake(hero.position.x, (camera?.position.y)! - 100)
        self.hero.zPosition = 100
        hasBegan = false
        
        

    }
    
    func setUpLevel(){
        
        //set hero position
        setHeroPosition()
        
        dx = hero.position.x
        
        spawnMonstros()
        
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
        
        self.enumerateChildNodesWithName(TBEspinhosNode.name, usingBlock: {
            (node:SKNode! , stop:UnsafeMutablePointer <ObjCBool>)-> Void in
        
            node.physicsBody  = SKPhysicsBody(rectangleOfSize: node.frame.size)
            node.physicsBody?.categoryBitMask = GameScene.ESPINHOS_NODE
            node.zPosition = 1
             self.setObstacleTypeHit(node)
            
            node.runAction(SKAction.repeatActionForever(TBEspinhosNode.animation!))
            
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
        
        spawnMoedas()
        
        self.enumerateChildNodesWithName("FINAL", usingBlock: {
            (node:SKNode! , stop:UnsafeMutablePointer <ObjCBool>)-> Void in
            node.physicsBody  = SKPhysicsBody(rectangleOfSize: node.frame.size)
            node.physicsBody?.categoryBitMask = GameScene.END_LEVEL_NODE
            node.physicsBody?.contactTestBitMask = GameScene.PLAYER_NODE
            node.physicsBody?.pinned = true
            self.setObstacleTypeHit(node)
            
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
                if (name == "restartButton"){
                    self.backtToMenu()
                }else{
                    
                    if(hasBegan){
                        self.hero.state = States.Initial
                    }else{
                        hasBegan = true
                        startGame()
                        self.hero.state = States.FAIL
            
                    }
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
        labelScore!.text = numFormatter.stringFromNumber(hero.score)
        
    }
    
    override func update(currentTime: CFTimeInterval) {
        
        /* Called before each frame is rendered */
        
        //let heroy = self.hero.position.y
        
        updateScore()
        cameraState()
        //print(self.firstCameraPos)
        //print(CGRectGetMaxY(self.frame))
        
        if(hasBegan) {
            self.hero.updateVelocity()
            if(lastFrameTime == 0) {lastFrameTime = currentTime}
            
            deltaTime = currentTime - lastFrameTime
            lastFrameTime = currentTime
            self.moveSprite(skyNode!, nextSprite: skyNodeNext!, speed: 100)

        }
        
        if(self.touchStartedAt != nil &&  self.touchStartedAt! + self.limitTimeAction < currentTime ){
            self.hero.state = nextStatefor(self.hero.state, andInput: Directions.END)
            self.hero.actionCall()
            self.touchStartedAt = currentTime
            self.hero.state = States.Initial
            
        }
        
    }
    
    
    
    func cameraState() {
        
        if(self.hero.position.y < self.topLimit.y) {
            
            stateCamera = "normal"
            
        } else if(self.hero.position.y > self.topLimit.y && self.hero.position.y < self.topLimit.y+150) {
            
            stateCamera = "up1"
            
        } else if(self.hero.position.y > self.topLimit.y+100 && self.hero.position.y < self.topLimit.y+300) {
            
            stateCamera = "up2"
            
        } else if(self.hero.position.y > self.topLimit.y+200 && self.hero.position.y < self.topLimit.y+450) {
            
            stateCamera = "up3"
            
        } else if(self.hero.position.y > self.topLimit.y+300 && self.hero.position.y < self.topLimit.y+600) {
            
            stateCamera = "up4"
            
        } else if(self.hero.position.y > self.topLimit.y+400 && self.hero.position.y < self.topLimit.y+750) {
            
            stateCamera = "up5"
            
        } else if(self.hero.position.y > self.topLimit.y+500 && self.hero.position.y < self.topLimit.y+900) {
            
            stateCamera = "up6"
            
        }
        
        changeCamera()
        
    }
    
    
    
    func changeCamera() {
        
        
        
       // print(self.topLimit.y - self.hero.position.y)
        
        
        
        switch(stateCamera) {
            
        case "normal":
            self.cameraPosition = CGPointMake(self.hero.position.x+360, self.firstCameraPos.y)
            self.cameraAction = SKAction.moveToX(self.cameraPosition.x, duration: 0)
            self.cameraActionUp = SKAction.moveToY(self.cameraPosition.y, duration: 0.5)
            let actionBlocks = SKAction.group([self.cameraActionUp, self.cameraAction])
            self.camera?.runAction(actionBlocks)
            break
            
        case "up1":
            
            self.cameraPostionUp = CGPointMake(self.hero.position.x+360, self.firstCameraPos.y+150)
            
            //                self.cameraActionUp = SKAction.moveTo(cameraPostionUp, duration: 0)
            
            //                self.camera?.runAction(self.cameraActionUp)
            
            self.cameraAction = SKAction.moveToX(self.cameraPostionUp.x, duration: 0)
            
            self.cameraActionUp = SKAction.moveToY(self.cameraPostionUp.y, duration: 0.5)
            
            let actionBlocks = SKAction.group([self.cameraActionUp, self.cameraAction])
            
            self.camera?.runAction(actionBlocks)
            
            break
            
        case "up2":
            
            self.cameraPostionUp = CGPointMake(self.hero.position.x+360, self.firstCameraPos.y+300)
            
            //                self.cameraActionUp = SKAction.moveTo(cameraPostionUp, duration: 0)
            
            //                self.camera?.runAction(self.cameraActionUp)
            
            self.cameraAction = SKAction.moveToX(self.cameraPostionUp.x, duration: 0)
            
            self.cameraActionUp = SKAction.moveToY(self.cameraPostionUp.y, duration: 0.5)
            
            let actionBlocks = SKAction.group([self.cameraActionUp, self.cameraAction])
            
            self.camera?.runAction(actionBlocks)
            
            break
            
        case "up3":
            
            self.cameraPostionUp = CGPointMake(self.hero.position.x+360, self.firstCameraPos.y+450)
            
            //                self.cameraActionUp = SKAction.moveTo(cameraPostionUp, duration: 0)
            
            //                self.camera?.runAction(self.cameraActionUp)
            
            self.cameraAction = SKAction.moveToX(self.cameraPostionUp.x, duration: 0)
            
            self.cameraActionUp = SKAction.moveToY(self.cameraPostionUp.y, duration: 0.5)
            
            let actionBlocks = SKAction.group([self.cameraActionUp, self.cameraAction])
            
            self.camera?.runAction(actionBlocks)
            
            break
            
        case "up4":
            
            self.cameraPostionUp = CGPointMake(self.hero.position.x+360, self.firstCameraPos.y+600)
            
            //                self.cameraActionUp = SKAction.moveTo(cameraPostionUp, duration: 0)
            
            //                self.camera?.runAction(self.cameraActionUp)
            
            self.cameraAction = SKAction.moveToX(self.cameraPostionUp.x, duration: 0)
            
            self.cameraActionUp = SKAction.moveToY(self.cameraPostionUp.y, duration: 0.5)
            
            let actionBlocks = SKAction.group([self.cameraActionUp, self.cameraAction])
            
            self.camera?.runAction(actionBlocks)
            
            break
            
        case "up5":
            
            self.cameraPostionUp = CGPointMake(self.hero.position.x+360, self.firstCameraPos.y+750)
            
            //                self.cameraActionUp = SKAction.moveTo(cameraPostionUp, duration: 0)
            
            //                self.camera?.runAction(self.cameraActionUp)
            
            self.cameraAction = SKAction.moveToX(self.cameraPostionUp.x, duration: 0)
            
            self.cameraActionUp = SKAction.moveToY(self.cameraPostionUp.y, duration: 0.5)
            
            let actionBlocks = SKAction.group([self.cameraActionUp, self.cameraAction])
            
            self.camera?.runAction(actionBlocks)
            
            break
            
        case "up6":
            
            self.cameraPostionUp = CGPointMake(self.hero.position.x+360, self.firstCameraPos.y+900)
            
            //                self.cameraActionUp = SKAction.moveTo(cameraPostionUp, duration: 0)
            
            //                self.camera?.runAction(self.cameraActionUp)
            
            self.cameraAction = SKAction.moveToX(self.cameraPostionUp.x, duration: 0)
            
            self.cameraActionUp = SKAction.moveToY(self.cameraPostionUp.y, duration: 0.5)
            
            let actionBlocks = SKAction.group([self.cameraActionUp, self.cameraAction])
            
            self.camera?.runAction(actionBlocks)
            
            break
            
        default: break
            
            
            
        }
        
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
            if bodyB.categoryBitMask == GameScene.MONSTER_NODE && hero.attackState == AttackState.Defending {
                bodyB.applyImpulse(CGVectorMake(100, 30))
                
            }else{
                self.hero.removeFromParent()
                restartLevel()
                print("oohhh damange")
            }
        
        }else if(bodyA.categoryBitMask == GameScene.PLAYER_NODE &&
                (bodyB.categoryBitMask == GameScene.CHAO_SLOW_NODE ||
                 bodyB.categoryBitMask == GameScene.CHAO_QUICK_NODE ||
                 bodyB.categoryBitMask ==  GameScene.TOCO_NODE ||
                 bodyB.categoryBitMask == GameScene.CHAO_NODE)){
            //print(flagTrocou)
            var norm = sqrt(contact.contactNormal.dx * contact.contactNormal.dx +
                        contact.contactNormal.dy * contact.contactNormal.dy)
            
            if(!flagTrocou) {norm = -norm}
//                    print(self.count)
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
                hero.score += 5
                hero.monstersKilled++
                print("kill monster")
            }else{
                //hero took damange
               
            }
            
        }
        else if(bodyA.categoryBitMask == GameScene.PLAYER_NODE  && bodyB.categoryBitMask == (GameScene.MOEDA_NODE )){
            //pegou a moeda
            bodyB.node?.removeFromParent()
            hero.qtdMoedas++
            hero.score += 10
            print("\(hero.qtdMoedas) coins in the pocket")
            
            
        }
        else if(bodyA.categoryBitMask == GameScene.PLAYER_NODE  && bodyB.categoryBitMask == (GameScene.END_LEVEL_NODE )){
            //terminou
            //pausa bruscamente
            
            let action = SKAction.sequence([SKAction.waitForDuration(0.45), SKAction.runBlock({
            self.scene?.view?.paused = true
                
            })])
            
            runAction(action)
            print("win")
        }
        
    }
    
}
