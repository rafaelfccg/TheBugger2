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
    
    func mudaScene(nomeSKS: String, withMethod:Int, andLevel:Int)
    func backToMenu()
    func selectLevel(nomeSKS: String)
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var levelSelected:Int?
    
    let kDistanceThreshold:Double = 10
    var hero: TBPlayerNode = TBPlayerNode()
    let limitTimeAction:Double = 0.08
    var touchStartedAt:Double?
    var delegateChanger: SceneChangesDelegate?
    var labelScore:SKLabelNode?
    var finalNode: SKNode?
    var finalBackNode: SKNode?
    var percentage:SKLabelNode?
    var numberDeathLabel:SKLabelNode?
    
    var tapToStartLabel:SKLabelNode?
    var hasBegan:Bool = false
    var stopParalax:Bool = false
    
    let removable = "removable"
    
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
    
    var topLimit:CGPoint = CGPointMake(0, 430)
    // count number of deaths
    var numberOfDeath:Int = 0
    // death node
    var deathNodeReference:SKNode?
    var stagePercentage:Double?
    
    var firstHeroPosition:CGPoint = CGPoint()
    var firstCameraPos:CGPoint = CGPointMake(0, 220)
    var upDone = false
    var stateCamera = "normal"
    //musica
    var backgroundMusicPlayer:AVAudioPlayer?
    var lastShot:CFTimeInterval = 0 // Variavel auxiliar para dar o tiro no tempo correto
    
    var isMethodOne:Int?
    
    static let CHAO_NODE:UInt32             = 0b000000000000010
    static let PLAYER_NODE:UInt32           = 0b000000000000001
    static let MONSTER_NODE:UInt32          = 0b000000000000100
    static let POWERUP_NODE:UInt32          = 0b000000000001000
    static let ESPINHOS_NODE:UInt32         = 0b000000000010000
    static let TIRO_NODE:UInt32             = 0b000000000100000
    static let JOINT_ATTACK_NODE:UInt32     = 0b000000001000000
    static let CHAO_QUICK_NODE:UInt32       = 0b000000010000000
    static let CHAO_SLOW_NODE:UInt32        = 0b000000100000000
    static let TOCO_NODE:UInt32             = 0b000001000000000
    static let MOEDA_NODE:UInt32            = 0b000010000000000
    static let OTHER_NODE:UInt32            = 0b000100000000000
    static let STOP_CAMERA_NODE:UInt32      = 0b001000000000000
    static let END_LEVEL_NODE:UInt32        = 0b010000000000000
    static let REFERENCIA_NODE:UInt32       = 0b100000000000000

    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        
        
        hero.method = isMethodOne
        self.addChild(hero)
        hero.setUpPlayer()
        self.size = CGSizeMake(self.view!.frame.size.width * 1.5, self.view!.frame.height * 1.5)
//        print(size)
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
        camera.position = CGPointMake(self.hero.position.x+360, self.firstCameraPos.y)
        
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
        
        setupHUD()
        
        tapToStartLabel = SKLabelNode(text: "TAP TO START")
        self.camera!.addChild(tapToStartLabel!)
        
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
    
    func updatePercentageLabel(){
        let per = Int(stagePercentage!)
        percentage?.text = "\(per)%"
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
        labelScore = SKLabelNode(fontNamed: "Squares Bold")
        labelScore!.text = self.numFormatter.stringFromNumber(0)
        labelScore?.name  = "scoreLabel"
        self.camera!.addChild(labelScore!)
        labelScore?.fontSize = 25
        labelScore?.position = CGPointMake(self.size.width/2 - (labelScore?.frame.size.width)! + 20, back.position.y - 15)
        labelScore?.zPosition = 1000
        let backScore = SKSpriteNode(imageNamed: "pt-hud")
        backScore.size = CGSizeMake(280,50)
        backScore.position = CGPointMake(0, 10)
        backScore.zPosition = -1
        labelScore?.addChild(backScore)
        
        
        percentage = SKLabelNode(text: "0%")
        percentage?.fontName = "Squares Bold"
        self.camera!.addChild(percentage!)
        percentage?.zPosition = 1000
        percentage?.position = CGPointMake(0, labelScore!.position.y )
        
//        self.numberDeathLabel = SKLabelNode(text: "Tentativas: 000")
//        self.camera!.addChild(numberDeathLabel!)
//        numberDeathLabel?.zPosition = 1000
//        numberDeathLabel?.position = CGPointMake(CGRectGetMidX(self.frame) - self.numberDeathLabel!.frame.width/2 - 10, back.position.y)
        
        //como não funciona tirei do primeiro playtesting
        
//        let powerTexture = SKTexture(imageNamed: "power1")
//        let powerNode = SKSpriteNode(texture: powerTexture, size: CGSizeMake( 85, 85) )
//        powerNode.name = "powerNode"
//        self.camera!.addChild(powerNode)
//        powerNode.position = CGPoint(x: self.size.width/2 - powerNode.size.width/2 - 15, y: -self.size.height/2 + powerNode.size.height/2 + 10)
//        powerNode.zPosition = CGFloat(1000)
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
        self.numberOfDeath++
        self.stopParalax = false
        background1?.texture = TBUtils.getNextBackground()
        background2?.texture = TBUtils.getNextBackground()
        self.enumerateChildNodesWithName(self.removable, usingBlock: {
            (node, ponter)->Void in
            
            node.removeFromParent()

            })
        // removendo tb o monstro que atira
        self.enumerateChildNodesWithName("shot", usingBlock: {
            (node, ponter)->Void in
            
            node.removeFromParent()
            
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
        
        spawnMoedas()
        spawnMonstros()
        updateNumberOfTries()
     
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
        
        self.enumerateChildNodesWithName(TBShotBotNode.name , usingBlock: {(node, ponter)->Void in
            
            let groundBotj = TBShotBotNode()
            
            groundBotj.position = node.position
            groundBotj.name = self.removable
            groundBotj.physicsBody?.allowsRotation = false
            node.physicsBody?.pinned = false
            groundBotj.physicsBody?.categoryBitMask = GameScene.MONSTER_NODE
            groundBotj.physicsBody?.collisionBitMask = ~GameScene.JOINT_ATTACK_NODE
            groundBotj.physicsBody?.contactTestBitMask = GameScene.PLAYER_NODE | GameScene.JOINT_ATTACK_NODE
            groundBotj.zPosition = 100
            self.addChild(groundBotj)
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
        
        for (var i = 0 ; i < 3 ;i++) {
            if let node = self.childNodeWithName("bit\(i)") {
                let bit = TBBitNode()
                bit.position = (node.position)
                bit.physicsBody?.categoryBitMask = GameScene.MOEDA_NODE
                bit.physicsBody?.contactTestBitMask = GameScene.PLAYER_NODE
                bit.name  = self.removable
                bit.num = i
                self.addChild(bit)
            
                bit.runAction(SKAction.repeatActionForever( TBBitNode.animation!), withKey: "moedaBit")
            }
        }
    }
    
    func backtToMenu(){
        delegateChanger?.backToMenu()   
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
    
    func setUpLevel(){
        
        setHeroPosition()
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
        
        self.enumerateChildNodesWithName("pixel", usingBlock: {
            (node:SKNode! , stop:UnsafeMutablePointer <ObjCBool>)-> Void in
            let sprite = node as! SKSpriteNode
            //node.runAction(TBBrilhoNode.brilhoAnimation!)
            //node.zPosition = 90
            
            //REMOVENDO TEMPORARIAMENTE
            sprite.texture = nil
            
        })
        
        self.enumerateChildNodesWithName("redlight", usingBlock: {
            (node:SKNode! , stop:UnsafeMutablePointer <ObjCBool>)-> Void in
           node.runAction(TBRedLightEffect.redLight!)
           node.zPosition = 10
            
        })
        
        self.enumerateChildNodesWithName("alert", usingBlock: {
            (node:SKNode! , stop:UnsafeMutablePointer <ObjCBool>)-> Void in
            node.runAction(TBAlertNode.alertAnimation!)
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
        self.enumerateChildNodesWithName("paraCamera", usingBlock: {
            (node:SKNode! , stop:UnsafeMutablePointer <ObjCBool>)-> Void in
            
            node.physicsBody  = SKPhysicsBody(rectangleOfSize: node.frame.size)
            node.physicsBody?.collisionBitMask = 0
            node.physicsBody?.categoryBitMask = GameScene.STOP_CAMERA_NODE
            node.physicsBody?.contactTestBitMask = GameScene.PLAYER_NODE
            node.physicsBody?.pinned = true
            self.setObstacleTypeHit(node)
        })
        
        spawnMoedas()
        
        self.enumerateChildNodesWithName("FINAL", usingBlock: {
            (node:SKNode! , stop:UnsafeMutablePointer <ObjCBool>)-> Void in
            node.physicsBody  = SKPhysicsBody(rectangleOfSize: node.frame.size)
            node.physicsBody?.collisionBitMask = 0
            node.physicsBody?.categoryBitMask = GameScene.END_LEVEL_NODE
            node.physicsBody?.contactTestBitMask = GameScene.PLAYER_NODE
            node.physicsBody?.pinned = true
            self.setObstacleTypeHit(node)
        })
        
        
        self.enumerateChildNodesWithName("firstGestureTutorial", usingBlock: {
            (node:SKNode! , stop:UnsafeMutablePointer <ObjCBool>)-> Void in
            //            let spriteNode
            if(self.isMethodOne == 1 ){
                node.runAction(SKAction.repeatActionForever(TBTutorialNodes.tapTutorialAction!))
            }else {
                node.runAction(SKAction.repeatActionForever(TBTutorialNodes.slideUpTutorialAction!))
            }
        })
        
        self.enumerateChildNodesWithName("secondGestureTutorial", usingBlock: {
            (node:SKNode! , stop:UnsafeMutablePointer <ObjCBool>)-> Void in
            //            let spriteNode
            if(self.isMethodOne == 1 || self.isMethodOne == 3){
                node.runAction(SKAction.repeatActionForever(TBTutorialNodes.slideRightTutorialAction!))
            }else if self.isMethodOne == 2 {
                node.runAction(SKAction.repeatActionForever(TBTutorialNodes.tapTutorialAction!))
            }

        })
        
        self.enumerateChildNodesWithName("firstActionTutorial", usingBlock: {
            (node:SKNode! , stop:UnsafeMutablePointer <ObjCBool>)-> Void in
            //            let spriteNode
            node.runAction(SKAction.repeatActionForever(TBTutorialNodes.jumpTutorialAction!))
            
        })
        
        self.enumerateChildNodesWithName("secondActionTutorial", usingBlock: {
            (node:SKNode! , stop:UnsafeMutablePointer <ObjCBool>)-> Void in
            //            let spriteNode
            node.runAction(SKAction.repeatActionForever(TBTutorialNodes.attackTutorialAction!))
            
        })
        
        self.enumerateChildNodesWithName("firstGestureTutorialLabel", usingBlock: {
            (node:SKNode! , stop:UnsafeMutablePointer <ObjCBool>)-> Void in
            
            if(self.isMethodOne! == 2 || self.isMethodOne! == 3 ){
                let newNode = SKSpriteNode(imageNamed: "slidetxt")
                newNode.position = node.position
                newNode.size =  node.frame.size
                self.addChild(newNode)
                
            }else{
                let newNode = SKSpriteNode(imageNamed: "taptxt")
                newNode.position = node.position
                newNode.size =  node.frame.size
                self.addChild(newNode)
            }
            
        })
        
        self.enumerateChildNodesWithName("secondGestureTutorialLabel", usingBlock: {
            (node:SKNode! , stop:UnsafeMutablePointer <ObjCBool>)-> Void in
            //            let spriteNode
            if(self.isMethodOne! == 2 ){
                let newNode = SKSpriteNode(imageNamed: "taptxt")
                newNode.position = node.position
                newNode.size =  node.frame.size
                self.addChild(newNode)
                
            }else{
                let newNode = SKSpriteNode(imageNamed: "slidetxt")
                newNode.position = node.position
                newNode.size =  node.frame.size
                self.addChild(newNode)
            }
        })
        finalNode = childNodeWithName(TBFinalNode.name)
        finalBackNode = self.childNodeWithName(TBFinalNode.nameBack)
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
        
        // O tempo para o tiro é a cada 5 segundos
//        let delta: CFTimeInterval = currentTime - self.lastShot
//        
//        if(delta>5.0) {
//            self.lastShot = currentTime
//            self.shooting()
//        }
//        
       
        
        //checkBotShot()
       // checkCurrentShots(currentTime)
        updateScore()
        
        if(stateCamera != "final")
        {
            cameraState()
        }
        
        if(hasBegan) {
            self.hero.updateVelocity()
            //PARRALLAX SETTING
            if(lastFrameTime == 0) {
                lastFrameTime = currentTime
            }
            deltaTime = currentTime - lastFrameTime
            lastFrameTime = currentTime
            if(stopParalax == false)
            {
                self.moveSprite(skyNode!, nextSprite: skyNodeNext!, speed: self.skyspeed,isParalaxSky: true)
                self.moveSprite(background1!, nextSprite: background2!, speed: self.parallaxSpeed,isParalaxSky: false)
                
            }
            
            self.stagePercentage = Double(floor(100*(hero.position.x - self.firstHeroPosition.x)/(deathNodeReference!.frame.size.width)))
            updatePercentageLabel()
            
            if(self.touchStartedAt != nil &&  self.touchStartedAt! + self.limitTimeAction < currentTime ){
                self.hero.state = nextStatefor(self.hero.state, andInput: Directions.END)
                self.hero.actionCall()
                if hero.state != States.FAIL{
                    self.touchStartedAt = currentTime
                }
                self.hero.state = States.Initial
            }
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
           
            self.cameraAction = SKAction.moveToX(self.cameraPostionUp.x, duration: 0)
            
            self.cameraActionUp = SKAction.moveToY(self.cameraPostionUp.y, duration: 0.5)
            
            let actionBlocks = SKAction.group([self.cameraActionUp, self.cameraAction])
            
            self.camera?.runAction(actionBlocks)
            
            break
            
        case "up2":
            
            self.cameraPostionUp = CGPointMake(self.hero.position.x+360, self.firstCameraPos.y+300)
            
            self.cameraAction = SKAction.moveToX(self.cameraPostionUp.x, duration: 0)
            
            self.cameraActionUp = SKAction.moveToY(self.cameraPostionUp.y, duration: 0.5)
            
            let actionBlocks = SKAction.group([self.cameraActionUp, self.cameraAction])
            
            self.camera?.runAction(actionBlocks)
            
            break
            
        case "up3":
            
            self.cameraPostionUp = CGPointMake(self.hero.position.x+360, self.firstCameraPos.y+450)
            
            self.cameraAction = SKAction.moveToX(self.cameraPostionUp.x, duration: 0)
            
            self.cameraActionUp = SKAction.moveToY(self.cameraPostionUp.y, duration: 0.5)
            
            let actionBlocks = SKAction.group([self.cameraActionUp, self.cameraAction])
            
            self.camera?.runAction(actionBlocks)
            
            break
            
        case "up4":
            
            self.cameraPostionUp = CGPointMake(self.hero.position.x+360, self.firstCameraPos.y+600)
            
            self.cameraAction = SKAction.moveToX(self.cameraPostionUp.x, duration: 0)
            
            self.cameraActionUp = SKAction.moveToY(self.cameraPostionUp.y, duration: 0.5)
            
            let actionBlocks = SKAction.group([self.cameraActionUp, self.cameraAction])
            
            self.camera?.runAction(actionBlocks)
            
            break
            
        case "up5":
            
            self.cameraPostionUp = CGPointMake(self.hero.position.x+360, self.firstCameraPos.y+750)
            
            self.cameraAction = SKAction.moveToX(self.cameraPostionUp.x, duration: 0)
            
            self.cameraActionUp = SKAction.moveToY(self.cameraPostionUp.y, duration: 0.5)
            
            let actionBlocks = SKAction.group([self.cameraActionUp, self.cameraAction])
            
            self.camera?.runAction(actionBlocks)
            
            break
            
        case "up6":
            
            self.cameraPostionUp = CGPointMake(self.hero.position.x+360, self.firstCameraPos.y+900)
            
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
        
        
        if bodyA.categoryBitMask == GameScene.PLAYER_NODE  &&
            bodyB.categoryBitMask == GameScene.POWERUP_NODE {
                
                
        }else if(bodyA.categoryBitMask == GameScene.PLAYER_NODE  &&
          (bodyB.categoryBitMask == GameScene.MONSTER_NODE) ||
          (bodyB.categoryBitMask == GameScene.ESPINHOS_NODE) ||
          (bodyB.categoryBitMask == GameScene.TIRO_NODE)){
            
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
            
            if(contact.contactNormal.dy/norm > 0.5){
                self.hero.jumpState = JumpState.CanJump
            }
            if bodyB.categoryBitMask == GameScene.CHAO_QUICK_NODE {
 
                hero.quickFloorCollision(bodyB, sender: self)
                
            }else if bodyB.categoryBitMask == GameScene.CHAO_SLOW_NODE{
                
                hero.slowFloorCollision(bodyB, sender: self)
            }
            
            
        }else if((bodyA.categoryBitMask == GameScene.MONSTER_NODE)  && bodyB.categoryBitMask == (GameScene.JOINT_ATTACK_NODE )){
            if(hero.attackState == AttackState.Attacking){

                if let gbotmonste = bodyA.node as? TBGroundBotNode{
                    gbotmonste.dieAnimation()
                    hero.score += 5
                    hero.monstersKilled++
                
                } else if let gbotmonste2 = bodyA.node as? TBShotBotNode{
                        gbotmonste2.dieAnimation()
                        hero.score += 10
                        hero.monstersKilled++
                } 
               
            }
            
        }
        else if(bodyA.categoryBitMask == GameScene.PLAYER_NODE  && bodyB.categoryBitMask == (GameScene.MOEDA_NODE )){
            //pegou a moeda
            if  let bit = bodyB.node as? TBBitNode {
                hero.score += 100
                self.coinsMark[bit.num!] = true
               
            }else{
                hero.qtdMoedas++
                hero.score += 10
            }
            bodyB.node?.removeFromParent()
            
        }
        else if(bodyA.categoryBitMask == GameScene.PLAYER_NODE  && bodyB.categoryBitMask == (GameScene.STOP_CAMERA_NODE )){
            //muda o estado da camera para a função update não alterar a posição dela
                stateCamera = "final"
                stopParalax = true
        }
        else if(bodyA.categoryBitMask == GameScene.PLAYER_NODE  && bodyB.categoryBitMask == (GameScene.END_LEVEL_NODE )){
            //terminou
            
            hero.realSpeed = 0
            
            let action = SKAction.sequence([TBFinalNode.animation!, SKAction.runBlock({

                self.childNodeWithName(TBFinalNode.nameBack)!.runAction(
                    
                    SKAction.sequence([TBFinalNode.animationBack!, SKAction.waitForDuration(0.1), SKAction.runBlock({
                        self.scene?.view?.paused = true
                        let defaults = NSUserDefaults.standardUserDefaults()
                        let max = defaults.integerForKey("level")
                        if max < self.levelSelected! + 1 {
                             defaults.setInteger(self.levelSelected! + 1, forKey: "level")
                        } 
                        self.delegateChanger!.selectLevel("SelectLevelScene")
                    })])
                )
            
            })])
            
          finalNode!.runAction(action)
            
        } else if(bodyB.categoryBitMask == GameScene.REFERENCIA_NODE && bodyA.categoryBitMask == GameScene.PLAYER_NODE)  {
            if(bodyB.node?.name == "referencia") {
                if let myBot = bodyB.node!.parent as? TBShotBotNode {
                    myBot.activeShotMode()
                }
            }
            else {
                if let myBot = bodyB.node!.parent as? TBShotBotNode {
                    myBot.stopShotMode()
                }
            }
        }
    }
}
