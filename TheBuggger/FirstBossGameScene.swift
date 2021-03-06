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
    var snowRunning = false    // Variavel para a a particula snow ser criada apenas uma vez
    var snowParticle:SKEmitterNode?
    var snowParticle2:SKEmitterNode?
    var snowParticle3:SKEmitterNode?
    
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
        self.createSnowParticle()
        runAction(SKAction.sequence([SKAction.waitForDuration(1.35), SKAction.runBlock({
            self.checkBossVelocity()
            self.bossIsRunnning = true
        })]))      // O boss so comeca a andar depois de certo tempo
    }
    
    func createSnowParticle () {  // Cria a particula de neve
        if(!self.snowRunning) {
            self.snowRunning = true
            let snowParticle = SKEmitterNode(fileNamed: "TBBossSnowParticle.sks")
            snowParticle?.zPosition = 1000
            snowParticle?.position.y += 260
            snowParticle?.particleScale = 0.1
            self.snowParticle = snowParticle
            
            let snowParticle2 = SKEmitterNode(fileNamed: "TBBossSnowParticle.sks")
            snowParticle2?.zPosition = 1000
            snowParticle2?.position.y += 260
            snowParticle2?.particleScale = 0.1
            snowParticle2?.position.x -= 320
            self.snowParticle2 = snowParticle2
            
            let snowParticle3 = SKEmitterNode(fileNamed: "TBBossSnowParticle.sks")
            snowParticle3?.zPosition = 1000
            snowParticle3?.position.y += 260
            snowParticle3?.particleScale = 0.1
            snowParticle3?.position.x += 320
            self.snowParticle3 = snowParticle3
            
            self.camera?.addChild(self.snowParticle!)
            self.camera?.addChild(self.snowParticle2!)
            self.camera?.addChild(self.snowParticle3!)
        }
    }
    
    func removeSnowParticle() { // Remove a particula de neve
        self.camera?.removeChildrenInArray([self.snowParticle!, self.snowParticle2!, self.snowParticle3!])
        self.snowRunning = false
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
            groundBoti.bossSceneDelegate = self
            self.addChild(self.firstBoss)
        })
        

    }
    
    func bossDead() {
        self.hero.realSpeed = 0
        let defaults = NSUserDefaults.standardUserDefaults()
        let max = defaults.integerForKey("level")
        if max < self.levelSelected! + 1 {
            defaults.setInteger(self.levelSelected! + 1, forKey: "level")
        }
        
        completeLevelAchievementGC(levelSelected!)
        bitsAchievementGC(coinsMark, levelSelected: levelSelected!)
        
        // Salvando o log de quantos usuário únicos já ganharam
        if let statisticsLogs = fetchLogsByLevel(levelSelected!)
        {
            if(statisticsLogs.won != true)
            {
                Flurry.logEvent("UniqueCompletedLevel", withParameters: ["Stage": levelSelected!])
            }
        }
        
        saveLogsFetched(self.hero, bitMark: self.coinsMark, levelSelected: self.levelSelected!, tentativas: self.numberOfDeath)
        
        // somando todos os dados para adicionar ao game center
        // - função sumStatistics() chama fetchLogs() e deve ser chamada após salvar os logs atuais
        let totalStatistics = sumStatistics()
        submitScoreGC(totalStatistics.score)
        collect21BitsAchievementGC(totalStatistics.numBits)
        coinsAchievementGC(totalStatistics.moedas)
        bugsAchievementGC(totalStatistics.monstersTotalKilled)
        
        Flurry.logEvent("CompletedLevel", withParameters: ["Stage": levelSelected!])
        // Tela de pontuacao com botao pra mostrar a historia
        
        //Medida Temporaria
        backgroundMusicPlayer?.pause()
        delegateChanger?.runStory(TBSecondStory(fileNamed:"TBSecondStory")!, withMethod: 0, andLevel: 8)
        
        
    }
    
    override func restartLevel()
    {
        super.restartLevel()
        self.bossIsRunnning = false
        self.removeSnowParticle()
        self.createSnowParticle()
        self.firstBoss.removeFromParent()
        setBoss()
        self.updateHPLabel()
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
        percentage = SKLabelNode(text: "100")
        percentage?.fontName = "Squares Bold"
        self.camera!.addChild(percentage!)
        percentage?.zPosition = self.HUDz
        percentage?.fontSize = 35
        percentage?.position = CGPointMake(0, contadorNode!.position.y - 10)
        percentage!.name = "hud"
    }
    
    override func update(currentTime: CFTimeInterval) {
        //print("hero \(self.hero.physicsBody!.velocity)")
        if(hasBegan) {
            //updateHPLabel()
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
