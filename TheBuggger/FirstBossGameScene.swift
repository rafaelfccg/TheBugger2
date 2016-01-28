//
//  FirstBossGameScene.swift
//  TheBuggger
//
//  Created by Victor Augusto Pereira Porciúncula on 1/13/16.
//  Copyright © 2016 rfccg. All rights reserved.
//

import SpriteKit

class FirstBossGameScene: GameSceneBase, BossProtocol {
    
    var simpleBlock1:TBSimpleBlockNode?
    var simpleBlock2:TBSimpleBlockNode?
    
    var allocBool:Bool = true
    var deallocBool:Bool = false
    var lastID = 0
    var bossIsRunnning = false
    
    var defaultY:CGFloat = 0
    
    var firstBoss:TBFirstBossNode = TBFirstBossNode()
    
    static let REALLOC:UInt32            = 0b0000000100000000000
    
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        setupHUD()

        let achor = self.childNodeWithName("achor")
        defaultY = (achor?.position.y)! - (achor?.frame.size.height)!/2
        
        simpleBlock1 = TBSimpleBlockNode.unarchiveFromFile("TBSimpleBlockNode")
        simpleBlock2 = TBSimpleBlockNode.unarchiveFromFile("TBSimpleBlockNode")
        
        resetLevel()
        
        setBlock(simpleBlock1!)
        setBlock(simpleBlock2!)
        simpleBlock1?.id = 0
        simpleBlock2?.id = 1
        setBoss()
        
    }
    func resetLevel(){
        let nodeConnection = self.childNodeWithName("connection")
        simpleBlock1?.removeParentIfPossible()
        self.addChild(simpleBlock1!)
        simpleBlock1?.position = CGPointMake((nodeConnection?.position.x)!, defaultY)
        simpleBlock2?.removeParentIfPossible()
    
    }
    func checkBossVelocity() {      // Checa se existe algum boss, caso exista, aumenta sua velocidade
            self.firstBoss.updateVelocity(self.hero)
            self.firstBoss.startBoss()
    }
    
    override func startGame(){
        super.startGame()
        runAction(SKAction.sequence([SKAction.waitForDuration(1.35), SKAction.runBlock({
            self.checkBossVelocity()
            self.bossIsRunnning = true
        })]))      // O boss so comeca a andar depois de certo tempo
    }


    func repositionBlock(inout block:TBSimpleBlockNode, basedOn:TBSimpleBlockNode){
        let nodeConnection = basedOn.childNodeWithName("connection")
        //let achor = basedOn.childNodeWithName("achor")
        
       
        //if block.position.x < basedOn.position.x {
        dispatch_async(dispatch_get_main_queue(), {
            if block.parent == nil{
                self.addChild(block)
            }else{
                block.removeFromParent()
                self.addChild(block)
            }
            block.position = CGPointMake(( basedOn.position.x + (nodeConnection?.position.x)!), self.defaultY)

        })
       
    }
    
    func setBoss(){
        self.enumerateChildNodesWithName(TBFirstBossNode.name , usingBlock: {(node, ponter)->Void in
            
            let groundBoti = TBFirstBossNode()
            groundBoti.name = "firstBoss"
            groundBoti.position = node.position
            groundBoti.zPosition = 100
            self.firstBoss = groundBoti
            self.addChild(self.firstBoss)
        })
        

    }
    
    func bossDead() {
        
    }
    
    override func restartLevel()
    {
        super.restartLevel()
        self.bossIsRunnning = false
        self.firstBoss.removeFromParent()
        setBoss()
        resetLevel()
    }
    
    func setBlock(block:TBSimpleBlockNode){
        let realloc = block.childNodeWithName("realloc")
        realloc?.physicsBody = SKPhysicsBody(rectangleOfSize: (realloc?.frame.size)!)
        realloc?.physicsBody?.collisionBitMask = 0b0
        realloc?.physicsBody?.contactTestBitMask = GameSceneBase.PLAYER_NODE
        realloc?.physicsBody?.categoryBitMask  = FirstBossGameScene.REALLOC
        realloc?.physicsBody?.affectedByGravity = false
        realloc?.physicsBody?.dynamic  = false
        realloc?.physicsBody?.pinned = true
        realloc?.physicsBody?.allowsRotation = false;

    }
    override func setupHUD() {
        super.setupHUD()
        percentage = SKLabelNode(text: "50")
        percentage?.fontName = "Squares Bold"
        self.camera!.addChild(percentage!)
        percentage?.zPosition = self.HUDz
        percentage?.fontSize = 40
        percentage?.position = CGPointMake(0, contadorNode!.position.y - 10)
        percentage!.name = "hud"
    }
    
    override func update(currentTime: CFTimeInterval) {
        //print("hero \(self.hero.physicsBody!.velocity)")
        if(hasBegan) {
            updateHPLabel()
            if self.bossIsRunnning {
                self.firstBoss.updateVelocity(self.hero)
            }
        }

        super.update(currentTime)
        
    }
    func updateHPLabel(){
        self.stagePercentage = Double(self.firstBoss.life)
        
        let per = Int(stagePercentage!)
        percentage?.text = "\(per)"
    }
    
    
    override func setUpLevel(){
        
        super.setUpLevel()
        
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
        
    }

    override func didBeginContact(contact: SKPhysicsContact) {
        super.didBeginContact(contact)
        
        var bodyA = contact.bodyA
        var bodyB = contact.bodyB
        
        //ordena para que bodyA tenha sempre a categoria "menor"
        if(bodyA.categoryBitMask > bodyB.categoryBitMask){
            let aux = bodyB
            bodyB = bodyA
            bodyA = aux
        }
        
        if(bodyB.categoryBitMask == GameScene.BOSSONE_NODE && bodyA.categoryBitMask == GameScene.JOINT_ATTACK_NODE) {
            if(hero.actionState == ActionState.Attacking) {
                if let boss = bodyB.node as? TBFirstBossNode {
                    boss.decreaseLife()
                }
            }
        }else if(bodyB.categoryBitMask == GameScene.METALBALL_NODE && bodyA.categoryBitMask == GameScene.BOSSONE_NODE) {
            if let boss = bodyA.node as? TBFirstBossNode {
                if let metalBall = bodyB.node as? TBBallFirstBossNode {
                    boss.decreaseLifeMetalBall()
                    if(metalBall.ataqueDuploTriplo) {
                        metalBall.bossDamagedDontBackAttack()
                    } else {
                        metalBall.bossDamaged()
                    }
                }
            }
        } else if(bodyB.categoryBitMask == GameScene.METALBALL_NODE && bodyA.categoryBitMask == GameScene.REFERENCIA_NODE) {
            if let metalBall = bodyB.node as? TBBallFirstBossNode {
                metalBall.ballMissed()
            }
        }else if (bodyB.categoryBitMask == FirstBossGameScene.REALLOC && bodyA.categoryBitMask == GameSceneBase.PLAYER_NODE ){
            if let block = bodyB.node?.parent as? TBSimpleBlockNode{
                if block.id == 0{
                    lastID = block.id
                    repositionBlock(&simpleBlock2! , basedOn: block)
                    //print(simpleBlock2?.position)
                }else{
                    lastID = block.id
                    repositionBlock(&simpleBlock1! , basedOn: block)
                }
            }else{
                print("contato mas nao foi")
            }
        }
    }

}
