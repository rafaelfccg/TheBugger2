//
//  GameScene.swift
//  TheBuggger
//
//  Created by Rafael Gouveia on 9/28/15.
//  Copyright (c) 2015 rfccg. All rights reserved.
//

import SpriteKit
import AVFoundation

//protocol SceneChangesDelegate{
//    
//    func mudaScene(nomeSKS: String, withMethod:Int, andLevel:Int)
//    func backToMenu()
//    func selectLevel(nomeSKS: String)
//    func gameOver()
//    func mudaSceneBoss(nomeSKS: String, withMethod:Int, andLevel:Int)
//}

class GameSceneBase: SKScene, SKPhysicsContactDelegate,TBSceneProtocol{
    
    var levelSelected:Int?
    
    let kDistanceThreshold:Double = 10
    var hero: TBPlayerNode = TBPlayerNode()
    let limitTimeAction:Double = 0.08
    var touchStartedAt:Double?
    var delegateChanger: SceneChangesDelegate?
    var labelScore:SKLabelNode?
    var contadorNode:SKSpriteNode?
    var finalNode: SKNode?
    var finalBackNode: SKNode?
    var percentage:SKLabelNode?
    var numberDeathLabel:SKLabelNode?
    var deathSinceLastAd:Int?
    
    var tapToStartLabel:SKLabelNode?
    var hasBegan:Bool = false
    var stopParalax:Bool = false
    var completionNode:TBCompletionLevelNode?
    
    let removable = "removable"
    
    var finalStage: Bool = false
    
    //coins
    var coinsMark:[Bool] = [false,false,false]
    
    //SPEED
    let skyspeed:Float = 270.0
    let parallaxSpeed:Float = 320.0
    
    let numFormatter = NSNumberFormatter()
    //parallax
    var skyNode:SKSpriteNode?
    var skyNodeNext:SKSpriteNode?
    var background1:SKSpriteNode?
    var background2:SKSpriteNode?
    
    var deltaTime : NSTimeInterval = 0
    var lastFrameTime :NSTimeInterval  = 0
    
    //camera
    var cameraPosition:CGPoint = CGPoint()
    var cameraAction:SKAction = SKAction()
    var cameraPostionUp:CGPoint = CGPoint()
    var cameraActionUp:SKAction = SKAction()
    
    var topLimit:CGPoint = CGPointMake(0, 390)
    // count number of deaths
    var numberOfDeath:Int = 1
    // death node
    var deathNodeReference:SKNode?
    var stagePercentage:Double?
    
    var firstHeroPosition:CGPoint = CGPoint()
    var firstCameraPos:CGPoint? = CGPointMake(0 , 220)
    var upDone = false
    var stateCamera = 0
    let HUDz:CGFloat = 10000
    //musica
    var backgroundMusicPlayer:AVAudioPlayer?
    var lastShot:CFTimeInterval = 0 // Variavel auxiliar para dar o tiro no tempo correto
    
    var isMethodOne:Int?
    
    static let CHAO_NODE:UInt32             = 0b0000000000000000010
    static let PLAYER_NODE:UInt32           = 0b0000000000000000001
    static let MONSTER_NODE:UInt32          = 0b0000000000000000100
    static let POWERUP_NODE:UInt32          = 0b0000000000000001000
    static let ESPINHOS_NODE:UInt32         = 0b0000000000000010000
    static let TIRO_NODE:UInt32             = 0b0000000000000100000
    static let JOINT_ATTACK_NODE:UInt32     = 0b0000000000001000000
    static let CHAO_QUICK_NODE:UInt32       = 0b0000000000010000000
    static let CHAO_SLOW_NODE:UInt32        = 0b0000000000100000000
    static let TOCO_NODE:UInt32             = 0b0000000001000000000
    static let MOEDA_NODE:UInt32            = 0b0000000010000000000
    static let OTHER_NODE:UInt32            = 0b0000000100000000000
    static let STOP_CAMERA_NODE:UInt32      = 0b0000001000000000000
    static let END_LEVEL_NODE:UInt32        = 0b0000010000000000000
    static let REFERENCIA_NODE:UInt32       = 0b0000100000000000000
    static let BOSSONE_NODE:UInt32          = 0b0001000000000000000
    static let METALBALL_NODE:UInt32        = 0b0010000000000000000
    static let REVIVE_NODE:UInt32           = 0b0100000000000000000
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        self.deathSinceLastAd  = 0
        delegateChanger?.stopAnimations()

        
        if let statisticsLogs = fetchLogsByLevel(levelSelected!)
        {
            numberOfDeath = Int(statisticsLogs.tentativas) + 1
        }
        
        hero.method = isMethodOne
        self.addChild(hero)
        hero.setUpPlayer()
        //1000.5 562.5
        let width:CGFloat = 1000.5
        let height = (width / self.view!.frame.size.width) * self.view!.frame.size.height
        self.size = CGSizeMake(width, height)
        //self.size = CGSizeMake(self.view!.frame.size.width * 1.5, self.view!.frame.height * 1.5)
        switch UIDevice.currentDevice().userInterfaceIdiom {
        case .Phone:
            self.firstCameraPos = CGPointMake(0 , 0.40 * height)
            break
        default :
            self.firstCameraPos = CGPointMake(0 , 0.43 * height)
            break
        }
        
        print(size)
        let camera = SKCameraNode();
        self.addChild(camera)
        self.camera = camera
        
        numFormatter.minimumIntegerDigits = 9
        numFormatter.maximumFractionDigits = 0
        //paralax ceu
        skyNode = SKSpriteNode(imageNamed: "sky")
        skyNode?.size = CGSizeMake(self.size.width+100, self.size.height+100)
        skyNodeNext = SKSpriteNode(imageNamed: "sky")
        skyNodeNext?.size = skyNode!.size
        
        background1 = SKSpriteNode(texture: TBUtils.getNextBackground())
        background1?.size = self.size
        background2 = SKSpriteNode(texture: TBUtils.getNextBackground())
        background2?.size = self.size
        
        setUpLevel()
        camera.position = CGPointMake(self.hero.position.x+360, self.firstCameraPos!.y)
        
        camera.addChild(skyNode!)
        camera.addChild(skyNodeNext!)
        camera.addChild(background1!)
        camera.addChild(background2!)
        
        skyNode?.position = CGPoint(x: 0,y: 0)
        skyNode?.zPosition = -100
        skyNodeNext?.position = CGPoint(x: (skyNode?.position.x)! + (skyNode?.frame.size.width)!,y: 0)
        skyNodeNext?.zPosition = -99
        
        background1?.position = CGPoint(x: 0,y: 0)
        background1?.zPosition = -50
        background2?.position = CGPoint(x: (background1?.position.x)! + (background1?.frame.size.width)!,y: 0)
        background2?.zPosition = -49
        
        self.physicsWorld.gravity = CGVectorMake(0.0, -35.0) // Diminuindo a gravidade para o personagem cair mais rapido
        
        self.physicsWorld.contactDelegate = self
        
        tapToStartLabel = SKLabelNode(text: "TAP TO START")
        tapToStartLabel?.fontName = "Squares Bold"
        tapToStartLabel?.zPosition  = self.HUDz
        tapToStartLabel?.fontColor = UIColor(red: 0.16, green: 0.95, blue: 0.835, alpha: 1)
        self.camera!.addChild(tapToStartLabel!)
        self.listener = self.hero
        if(backgroundMusicPlayer == nil){
            
            let backgroundMusicURL = NSBundle.mainBundle().URLForResource("Move_Ya", withExtension: ".mp3")
            
            do {
                try  backgroundMusicPlayer = AVAudioPlayer(contentsOfURL: backgroundMusicURL!)
                backgroundMusicPlayer!.numberOfLoops  = -1
                if(!backgroundMusicPlayer!.playing){
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
        self.scene?.view?.paused = false
        tapToStartLabel?.removeFromParent()
        Flurry.logEvent("User Player \(levelSelected)")
    }
    
    func moveSprite(sprite : SKSpriteNode,
        nextSprite : SKSpriteNode, speed : Float, isParalaxSky:Bool) -> Void {
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
                        nextSprite.position.x + nextSprite.frame.size.width - 7,
                        y: sprite.position.y)
                if(isParalaxSky){
                    sprite.zPosition = -99
                    nextSprite.zPosition = -100
                }else{
                    sprite.zPosition = -49
                    nextSprite.zPosition = -50
                    sprite.texture = TBUtils.getNextBackground()
                }
                
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
                        sprite.position.x + sprite.frame.size.width - 7 ,
                        y: nextSprite.position.y)
                if(isParalaxSky){
                    sprite.zPosition = -100
                    nextSprite.zPosition = -99
                }else{
                    sprite.zPosition = -50
                    nextSprite.zPosition = -49
                    nextSprite.texture = TBUtils.getNextBackground()
                }
            }
            
    }
    
    
    func updateNumberOfTries(){
        let per = Int(self.numberOfDeath)
        numberDeathLabel?.text = NSString(format: "Tentativas:%03d", per) as String//"Tentativas: \(per)"
    }
    
    func setupHUD()
    {
        let backTexture = SKTexture(imageNamed: "back-hud")
        let back = SKSpriteNode(texture: backTexture, size: CGSizeMake(80, 33))
        back.name = "restartButton"
        self.camera!.addChild(back)
        
        back.position = CGPoint(x: -self.size.width/2 + back.size.width/2 + 5, y: self.size.height/2 - back.size.height/2 - 5)
        back.zPosition =  1000
        
        let centerTopPoint = CGPointMake(0, back.position.y)
        
        let contTexture = SKTexture(imageNamed: "contador-0");
        self.contadorNode = SKSpriteNode(texture:contTexture, size: CGSizeMake(140,70))
        self.camera!.addChild(contadorNode!);
        self.contadorNode!.position = CGPointMake(0, centerTopPoint.y - 6);
        self.contadorNode!.zPosition = self.HUDz - 4;
        self.contadorNode!.name="hud"

        //implementada pela subclass
    }
    
    func restartLevel()
    {
        self.numberOfDeath++
        self.stopParalax = false
        stateCamera = 0
        background1?.texture = TBUtils.getNextBackground()
        background2?.texture = TBUtils.getNextBackground()
        self.enumerateChildNodesWithName(self.removable, usingBlock: {
            (node, ponter)->Void in
            node.removeFromParent()
        })
        
        camera?.enumerateChildNodesWithName(self.removable, usingBlock: {
            (node, ponter)->Void in
            node.removeFromParent()
        })
        // removendo tb o monstro que atira
        self.enumerateChildNodesWithName("shot", usingBlock: {
            (node, ponter)->Void in
            
            node.removeFromParent()
            
        })
        self.enumerateChildNodesWithName("changeSpeedNode", usingBlock: {
            (node, ponter)->Void in
            if let nodeI = node as? TBChangeSpeedGround{
                nodeI.hadEffect = false
            }
            
        })
        
        let method = hero.method
        
        setHeroPosition()
        
        hero.resetHero()
        lastFrameTime = 0
        
        self.addChild(hero)
        hasBegan = false
        hero.method = method
        
        skyNode?.position = CGPoint(x: 0,y: 0)
        skyNodeNext?.position = CGPoint(x: (skyNode?.position.x)! + (skyNode?.frame.size.width)!,y: 0)
        
        if(tapToStartLabel?.parent == nil){
            self.camera!.addChild(tapToStartLabel!)
        }
        
        updateNumberOfTries()
    }
    
    func backtToMenu(){
        saveAttempts(levelSelected!, tentativas: self.numberOfDeath)
        backgroundMusicPlayer?.stop()
        delegateChanger?.selectLevel("SelectLevelScene")
    }
    
    func setHeroPosition(){
        let spanw = self.childNodeWithName("SpawnHero")
        
        self.hero.position = (spanw!.position)
        self.hero.realSpeed = 0
        firstHeroPosition = hero.position
        hero.updateVelocity()
        self.camera?.position = CGPointMake(hero.position.x, (camera?.position.y)! - 100)
        self.hero.zPosition = 100
        
    }
    
    func setObstacleTypeHit(node: SKNode){
        node.physicsBody?.affectedByGravity = false
        node.physicsBody?.allowsRotation = false
        node.physicsBody?.dynamic = false
        node.physicsBody?.pinned = false
        node.physicsBody?.restitution = 0
        //node.physicsBody?.contactTestBitMask =
        
    }
    
    func setUpLevel(){
        
        setHeroPosition()
        
        //do something with the each child type
        
        self.enumerateChildNodesWithName("chao", usingBlock: {
            (node:SKNode! , stop:UnsafeMutablePointer <ObjCBool>)-> Void in
            node.physicsBody = SKPhysicsBody(rectangleOfSize: node.frame.size)
            self.setObstacleTypeHit(node)
            node.physicsBody?.pinned = true
            node.physicsBody!.categoryBitMask = GameScene.CHAO_NODE
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
        
        self.enumerateChildNodesWithName("espinhoSolto", usingBlock: {
            (node:SKNode! , stop:UnsafeMutablePointer <ObjCBool>)-> Void in
            
            node.physicsBody  = SKPhysicsBody(rectangleOfSize: node.frame.size)
            node.physicsBody?.categoryBitMask = GameScene.ESPINHOS_NODE
            node.zPosition = 1
            self.setObstacleTypeHit(node)
            node.runAction(TBEspinhoSoltoNode.animation!)
            
        })
        
        self.enumerateChildNodesWithName(TBEspinhosNode.name, usingBlock: {
            (node:SKNode! , stop:UnsafeMutablePointer <ObjCBool>)-> Void in
            
            let espinhoSize = CGSizeMake(node.frame.size.width*0.85, node.frame.size.height*0.85)
            node.physicsBody  = SKPhysicsBody(rectangleOfSize: espinhoSize)
            node.physicsBody?.categoryBitMask = GameScene.ESPINHOS_NODE
            node.zPosition = 1
            self.setObstacleTypeHit(node)
            
            node.runAction(SKAction.repeatActionForever(TBEspinhosNode.animation!))
            
        })
        //nó pulo morte
        self.enumerateChildNodesWithName("morte_queda", usingBlock: {
            (node:SKNode! , stop:UnsafeMutablePointer <ObjCBool>)-> Void in
            
            node.physicsBody  = SKPhysicsBody(rectangleOfSize: node.frame.size)
            node.physicsBody?.categoryBitMask = GameScene.ESPINHOS_NODE
            node.zPosition = 1
            
            let colorNode = node as! SKSpriteNode
            colorNode.color = SKColor.clearColor()
            
            self.setObstacleTypeHit(node)
            
            self.deathNodeReference = node
            
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
        
        
        self.enumerateChildNodesWithName("alert", usingBlock: {
            (node:SKNode! , stop:UnsafeMutablePointer <ObjCBool>)-> Void in
            node.runAction(TBAlertNode.alertAnimation!)
            node.zPosition = 10
            
        })
        
        self.enumerateChildNodesWithName("machine", usingBlock: {
            (node:SKNode! , stop:UnsafeMutablePointer <ObjCBool>)-> Void in
            node.runAction(TBMachineFrontNode.machineFrontAnimation!)
            node.zPosition = 10
            
        })
        
        self.enumerateChildNodesWithName("greenLeds", usingBlock: {
            (node:SKNode! , stop:UnsafeMutablePointer <ObjCBool>)-> Void in
            node.runAction(TBGreenLedsNode.greenLedsAnimation!)
            node.zPosition = 10
            
        })
        
        self.enumerateChildNodesWithName("cicloChoque", usingBlock: {
            (node:SKNode! , stop:UnsafeMutablePointer <ObjCBool>)-> Void in
            // a textura tem que ser criada estaticamente para otimização
            node.physicsBody  = SKPhysicsBody(rectangleOfSize: node.frame.size)
            self.setObstacleTypeHit(node)
            node.physicsBody?.collisionBitMask = 0
            
            // alternando entre os estados, acho que da pra otimizar
            let deBoas = SKAction.sequence([SKAction.runBlock({ node.physicsBody?.categoryBitMask = 0} ),SKAction.colorizeWithColor(UIColor.greenColor(), colorBlendFactor: 1, duration: 0.3), SKAction.waitForDuration(1)])
            
            let danger = SKAction.sequence([SKAction.colorizeWithColor(UIColor.redColor(), colorBlendFactor: 1, duration: 0.3), SKAction.runBlock({ node.physicsBody?.categoryBitMask = GameScene.ESPINHOS_NODE} ), SKAction.waitForDuration(0.1)])
            
            let alert = SKAction.sequence([SKAction.colorizeWithColor(UIColor.orangeColor(), colorBlendFactor: 1, duration: 0.3), SKAction.waitForDuration(0.3)])
            
            node.runAction(SKAction.repeatActionForever( SKAction.sequence([deBoas, alert, danger]) ) )
            
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
                self.backgroundMusicPlayer?.pause()
                self.backtToMenu()
            }else if (name == "Continue"){
                //self.completionNode?.animateBackground()
                self.delegateChanger?.selectLevel("SelectLevelScene")
                self.backgroundMusicPlayer?.stop()
            }else{
                
                if(hasBegan){
                    self.hero.state = States.Initial
                }else{
                    hasBegan = true
                    self.paused = false
                    
                    startGame()
                    self.hero.state = States.FAIL
                }
            }
        }
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
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.hero.state = nextStatefor(self.hero.state, andInput: Directions.END)
        self.hero.actionCall()
        self.touchStartedAt = nil
        
    }
    
    func updateScore(){
        labelScore?.text = numFormatter.stringFromNumber(hero.score)
    }
    
    func backToForeground(){
        lastFrameTime = CACurrentMediaTime()
        deltaTime = 0
        self.hero.state = States.Initial
    }
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        updateScore()
        
        if(stateCamera != -1)
        {
            cameraState()
        }
        
        if(hasBegan) {
            
            //PARRALLAX SETTING
            if(lastFrameTime == 0) {
                lastFrameTime = currentTime
            }
            deltaTime = currentTime - lastFrameTime
            lastFrameTime = currentTime
            if(stopParalax == false && hero.physicsBody?.velocity.dx > 1)
            {
                self.moveSprite(skyNode!, nextSprite: skyNodeNext!, speed: self.skyspeed,isParalaxSky: true)
                self.moveSprite(background1!, nextSprite: background2!, speed: self.parallaxSpeed,isParalaxSky: false)
                
            }
            //hero checkings
            self.hero.updateVelocity()
//            self.hero.checkHeroFloorContact()
            //Action checking
            if(self.touchStartedAt != nil &&  self.touchStartedAt! + self.limitTimeAction < currentTime ){
                self.hero.state = nextStatefor(self.hero.state, andInput: Directions.END)
                self.hero.actionCall()
                if hero.state != States.FAIL{
                    self.touchStartedAt = currentTime
                }
                self.hero.state = States.Initial
            }
        }else{
            hero.runStandingAction()
        }
    }
    func checkAd(){
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        self.deathSinceLastAd = userDefaults.integerForKey("ads") + 1

        let a = Int(arc4random_uniform(3) + 6)
        if deathSinceLastAd > a {
            delegateChanger?.gameOver()
            deathSinceLastAd = 0
        }
        userDefaults.setInteger(self.deathSinceLastAd!, forKey:"ads")
    }
    
    func cameraState() {
        let height = 0.16 * self.size.height
        let base = 0.10 * self.size.height
        if(self.hero.position.y < self.topLimit.y) {
            stateCamera = 0
        } else if(self.hero.position.y >= self.topLimit.y && self.hero.position.y < self.topLimit.y + height) {
            stateCamera = 1
        } else if(self.hero.position.y >= self.topLimit.y + base && self.hero.position.y < self.topLimit.y+2*height) {
            stateCamera = 2
        } else if(self.hero.position.y > self.topLimit.y + 2 * base && self.hero.position.y < self.topLimit.y+3*height) {
            stateCamera = 3
        } else if(self.hero.position.y > self.topLimit.y + 3 * base && self.hero.position.y < self.topLimit.y+4*height) {
            stateCamera = 4
        } else if(self.hero.position.y > self.topLimit.y + 4 * base && self.hero.position.y < self.topLimit.y+5*height) {
            stateCamera = 5
        } else if(self.hero.position.y > self.topLimit.y + 5 * base && self.hero.position.y < self.topLimit.y+6*height) {
            stateCamera = 6
        }
        changeCamera()
    }
    
    func changeCamera() {
        var height = self.firstCameraPos!.y + CGFloat(stateCamera) * (0.16 * self.size.height)
        let width = 0.36 * self.size.width + self.hero.position.x
        
        if(stateCamera > 0){
            height += 50
        }
        self.cameraPosition = CGPointMake(width, height)
        self.cameraAction = SKAction.moveToX(self.cameraPosition.x, duration: 0)
        self.cameraActionUp = SKAction.moveToY(self.cameraPosition.y, duration: 0.5)
        let actionBlocks = SKAction.group([self.cameraActionUp, self.cameraAction])
        self.camera?.runAction(actionBlocks)
        
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
        if bodyA.categoryBitMask == GameScene.PLAYER_NODE  &&
            bodyB.categoryBitMask == GameScene.POWERUP_NODE {
                
                
                if let node = bodyB.node as? TBPowerUpNode  {
                    if !node.hadEffect {
                        node.hadEffect = true
                        node.removeFromParent()
                        hero.activatePowerUp(node.powerUP!)
                    }
                }
                
        }else if(bodyA.categoryBitMask == GameScene.PLAYER_NODE  &&
            (bodyB.categoryBitMask == GameScene.MONSTER_NODE ||
                bodyB.categoryBitMask == GameScene.ESPINHOS_NODE ||
                bodyB.categoryBitMask == GameScene.TIRO_NODE
                || bodyB.categoryBitMask == GameScene.METALBALL_NODE)){
                    
                    if(bodyA.node?.name == hero.standJoint?.name){
                        bodyA = hero.physicsBody!
                    }
                    hero.dangerCollision(bodyB, sender: self)
                    
        }else if(bodyA.categoryBitMask == GameScene.PLAYER_NODE &&
            (bodyB.categoryBitMask == GameScene.CHAO_SLOW_NODE ||
                bodyB.categoryBitMask == GameScene.CHAO_QUICK_NODE ||
                bodyB.categoryBitMask ==  GameScene.TOCO_NODE ||
                bodyB.categoryBitMask == GameScene.CHAO_NODE)){
                    
                    var norm = sqrt(contact.contactNormal.dx * contact.contactNormal.dx +
                        contact.contactNormal.dy * contact.contactNormal.dy)
                    
                    if(!flagTrocou) {norm = -norm}
                    
                    if hero.actionForKey("attack") == nil && hero.actionForKey("defence") == nil && hero.actionForKey("dash") == nil && !hero.heroStopped{
                        self.hero.removeStandingAction()
                        self.hero.runWalkingAction()
                    }
                    
                    
                    if(contact.contactNormal.dy/norm > 0.5){
                        self.hero.jumpState = JumpState.CanJump
                    }
                    if bodyB.categoryBitMask == GameScene.CHAO_QUICK_NODE {
                        
                        hero.quickFloorCollision(bodyB, sender: self)
                        
                    }else if bodyB.categoryBitMask == GameScene.CHAO_SLOW_NODE{
                        
                        hero.slowFloorCollision(bodyB, sender: self)
                    }
                    if bodyB.categoryBitMask == GameScene.TOCO_NODE {
                        if(bodyA.node?.position.x < bodyB.node?.position.x) {
                            hero.stopWalk()
                        }
                    }else{
                        hero.checkPlayerTocoContact(ActionState.Idle)
                    }
        }else if((bodyA.categoryBitMask == GameScene.MONSTER_NODE)  && bodyB.categoryBitMask == (GameScene.JOINT_ATTACK_NODE )){
            if(hero.actionState == ActionState.Attacking){
                if let gbotmonste = bodyA.node as? TBMonsterProtocol{
                    gbotmonste.dieAnimation(self.hero)
                }
            }
            
        } else if(bodyA.categoryBitMask == GameScene.PLAYER_NODE  && bodyB.categoryBitMask == (GameScene.MOEDA_NODE )){
            //pegou a moeda
            if  let bit = bodyB.node as? TBBitNode {
                hero.score += 100
                self.coinsMark[bit.num!] = true
                self.runAction(SKAction.playSoundFileNamed("SPECIAL_COIN", waitForCompletion: true))
                bit.gotMe(self)
                
            }else if let moeda = bodyB.node as? TBMoedasNode {
                if !moeda.picked {
                    hero.qtdMoedas++
                    moeda.picked = true
                    self.runAction(SKAction.playSoundFileNamed("moeda.mp3", waitForCompletion: true))
                    hero.score += 10
                }
            }
            bodyB.node?.removeFromParent()
            
        }
        else if(bodyA.categoryBitMask == GameScene.PLAYER_NODE  && bodyB.categoryBitMask == (GameScene.STOP_CAMERA_NODE )){
            //muda o estado da camera para a função update não alterar a posição dela
            stateCamera = -1
            stopParalax = true
        }else if(bodyB.categoryBitMask == GameScene.REFERENCIA_NODE && bodyA.categoryBitMask == GameScene.PLAYER_NODE)  {
            
            if(bodyB.node?.name == "referencia") {
                if let myBot = bodyB.node!.parent as? TBMonsterProtocol {
                    myBot.startAttack()
                }
            }
            else {
                if let myBot = bodyB.node!.parent as? TBShotBotNode {
                    myBot.stopShotMode()
                }
                else if let flyBot = bodyB.node!.parent as? TBFlyingBotNode {
                    flyBot.stopAttack()
                } else if let megaLaser = bodyB.node as? TBMegaLaserNode {
                    if(!megaLaser.entrouContato) {
                        megaLaser.initFire(self)
                    }
                }
            }
        }
    }
    func didEndContact(contact: SKPhysicsContact) {
        var bodyA = contact.bodyA
        var bodyB = contact.bodyB
        //var flagTrocou = false
        
        //ordena para que bodyA tenha sempre a categoria "menor"
        if(bodyA.categoryBitMask > bodyB.categoryBitMask){
            let aux = bodyB
            bodyB = bodyA
            bodyA = aux
            //flagTrocou = true
        }
        if(bodyA.categoryBitMask == GameScene.PLAYER_NODE && bodyB.categoryBitMask == GameScene.CHAO_QUICK_NODE) {
            self.hero.quickFloorCollisionOff(bodyB, sender: self)
        } else if bodyA.categoryBitMask == GameScene.PLAYER_NODE &&
            (bodyB.categoryBitMask == GameScene.CHAO_SLOW_NODE ||
                bodyB.categoryBitMask == GameScene.CHAO_QUICK_NODE ||
                bodyB.categoryBitMask == GameScene.CHAO_NODE){
                    
                    if (self.hero.jumpState == JumpState.CanJump){
                        self.hero.jumpState == JumpState.FirstJump
                    }
        }
    }
}