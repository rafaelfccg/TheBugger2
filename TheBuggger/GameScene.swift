//
//  GameScene.swift
//  TheBuggger
//
//  Created by Rafael Gouveia on 9/28/15.
//  Copyright (c) 2015 rfccg. All rights reserved.
//

import SpriteKit
import AVFoundation


class GameScene:GameSceneBase {
    

    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        setupHUD()
    }
    
    override func updateNumberOfTries(){
        let per = Int(self.numberOfDeath)
        numberDeathLabel?.text = NSString(format: "Tentativas:%03d", per) as String//"Tentativas: \(per)"
    }
    
    override func setupHUD()
    {
        super.setupHUD()
        let back = self.camera!.childNodeWithName("restartButton")
        
        labelScore = SKLabelNode(fontNamed: "Squares Bold")
        labelScore!.text = self.numFormatter.stringFromNumber(0)
        labelScore?.name  = "hud"
        self.camera!.addChild(labelScore!)
        labelScore?.fontSize = 25
        labelScore?.position = CGPointMake(self.size.width/2 - (labelScore?.frame.size.width)! + 20, back!.position.y - 15)
        labelScore?.zPosition = self.HUDz
        let backScore = SKSpriteNode(imageNamed: "pt-hud")
        backScore.size = CGSizeMake(280,50)
        backScore.position = CGPointMake(0, 10)
        backScore.zPosition = -1
        backScore.name = "hud"
        
        labelScore?.addChild(backScore)
        
        percentage = SKLabelNode(text: "0%")
        percentage?.fontName = "Squares Bold"
        self.camera!.addChild(percentage!)
        percentage?.zPosition = self.HUDz
        percentage?.position = CGPointMake(0, labelScore!.position.y + 3)
        percentage!.name = "hud"
        
    }
    
    
    override func restartLevel()
    {
        super.restartLevel()
        let dies = ["Porcentagem": Int(stagePercentage!), "Stage": levelSelected!]
        Flurry.logEvent("Died", withParameters: dies)
        
        spawnMoedas()
        spawnMonstros()
        spawnPowerUp()
        spawnRevive()
    }
    
    func spawnMonstros(){
        //otimizar, acho que da pra colocar umas paradas dentro das respectivas classes
        self.enumerateChildNodesWithName(TBGroundBotNode.name , usingBlock: {(node, ponter)->Void in
            
            let groundBoti = TBGroundBotNode()
            
            groundBoti.position = node.position
            groundBoti.name = self.removable
            groundBoti.zPosition = 100
            self.addChild(groundBoti)
            
        })
        
        self.enumerateChildNodesWithName(TBShotBotNode.name , usingBlock: {(node, ponter)->Void in
            
            let groundBotj = TBShotBotNode()
            
            groundBotj.position = node.position
            groundBotj.name = self.removable
            groundBotj.zPosition = 100
            self.addChild(groundBotj)
        })
        
        self.enumerateChildNodesWithName(TBBopperBotNode.name , usingBlock: {(node, ponter)->Void in
            
            let groundBoti = TBBopperBotNode()
            groundBoti.position = node.position
            groundBoti.name = self.removable
            groundBoti.zPosition = 100
            self.addChild(groundBoti)
        })
        
        self.enumerateChildNodesWithName(TBFlyingBotNode.name , usingBlock: {(node, ponter)->Void in
            
            let groundBoti = TBFlyingBotNode()
            groundBoti.position = node.position
            groundBoti.name = self.removable
            groundBoti.zPosition = 100
            self.addChild(groundBoti)
        })
        
    }
    
    func spawnPowerUp(){
        self.enumerateChildNodesWithName("frenesi", usingBlock:{(node:SKNode! , stop:UnsafeMutablePointer <ObjCBool>)-> Void in
            let frenezy  = TBPowerUpNode(texture: nil, color: UIColor.clearColor(), size: CGSizeMake(40, 100))
            frenezy.setUP(TBPowerUpsStates.Frenezy)
            frenezy.position = node.position
            frenezy.name = self.removable
            self.addChild(frenezy)
            
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
            
        })
        
        for i in 0  ..< 3 {
            if let node = self.childNodeWithName("bit\(i)") {
                let bit = TBBitNode()
                bit.position = (node.position)
                
                bit.name  = self.removable
                bit.num = i
                self.addChild(bit)
                coinsMark[i] = false
                bit.runAction(SKAction.repeatActionForever( TBBitNode.animation!), withKey: "moedaBit")
            }
        }
    }
    
    func spawnRevive()
    {
        self.enumerateChildNodesWithName(TBReviveNode.name , usingBlock: {(node, ponter)->Void in
            
            let reviveNode = TBReviveNode(size: node.frame.size)
            reviveNode.position = node.position
            reviveNode.name = self.removable
            reviveNode.zPosition = 100
            self.addChild(reviveNode)
        })
        
    }
    
    override func setUpLevel(){
        
        super.setUpLevel()
        spawnMonstros()
        
        //do something with the each child type
        
        self.enumerateChildNodesWithName("chao_quick", usingBlock: {
            (node:SKNode! , stop:UnsafeMutablePointer <ObjCBool>)-> Void in
            
            let chaoQuick = TBChangeSpeedGround(type:0);// 0 == rapido
            chaoQuick.position = node.position;
            chaoQuick.size = node.frame.size
            chaoQuick.setUPChao()
            chaoQuick.name = "changeSpeedNode"
            self.setObstacleTypeHit(chaoQuick)
            node.removeFromParent()
            self.addChild(chaoQuick)
            
        })
        
        self.enumerateChildNodesWithName("chao_slow", usingBlock: {
            (node:SKNode! , stop:UnsafeMutablePointer <ObjCBool>)-> Void in
            let chaoSlow = TBChangeSpeedGround(type: 1);// 0 == rapido
            chaoSlow.position = node.position;
            chaoSlow.size = node.frame.size
            chaoSlow.setUPChao()
            chaoSlow.name = "changeSpeedNode"
            self.setObstacleTypeHit(chaoSlow)
            node.removeFromParent()
            self.addChild(chaoSlow)
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
        
        self.enumerateChildNodesWithName("backScreenTutorial", usingBlock: {
            (node:SKNode! , stop:UnsafeMutablePointer <ObjCBool>)-> Void in
            //            let spriteNode
                node.runAction(SKAction.repeatActionForever(TBTutorialNodes.backScreenTutorialAction!))
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
        
        self.enumerateChildNodesWithName("thirdGestureTutorial", usingBlock: {
            (node:SKNode! , stop:UnsafeMutablePointer <ObjCBool>)-> Void in
            //            let spriteNode
            node.runAction(SKAction.repeatActionForever(TBTutorialNodes.slideBackTutorialAction!))
            
        })
        self.enumerateChildNodesWithName("firstActionTutorial", usingBlock: {
            (node:SKNode! , stop:UnsafeMutablePointer <ObjCBool>)-> Void in
            //            let spriteNode
            node.runAction(SKAction.repeatActionForever(TBTutorialNodes.jumpTutorialAction!))
            
        })
        
        self.enumerateChildNodesWithName("greenSignal", usingBlock: {
            (node:SKNode! , stop:UnsafeMutablePointer <ObjCBool>)-> Void in
            //            let spriteNode
            node.runAction(SKAction.repeatActionForever(TBSignalNode.signalAnimation!))
            
        })
        
        self.enumerateChildNodesWithName("slowSignal", usingBlock: {
            (node:SKNode! , stop:UnsafeMutablePointer <ObjCBool>)-> Void in
            //            let spriteNode
            node.runAction(SKAction.repeatActionForever(TBSlowSignalNode.signalAnimation!))
            
        })
        
        self.enumerateChildNodesWithName("secondActionTutorial", usingBlock: {
            (node:SKNode! , stop:UnsafeMutablePointer <ObjCBool>)-> Void in
            //            let spriteNode
            node.runAction(SKAction.repeatActionForever(TBTutorialNodes.attackTutorialAction!))
            
        })
        
        self.enumerateChildNodesWithName("thirdActionTutorial", usingBlock: {
            (node:SKNode! , stop:UnsafeMutablePointer <ObjCBool>)-> Void in
            //            let spriteNode
            node.runAction(SKAction.repeatActionForever(TBTutorialNodes.blockTutorialAction!))
            
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
            // let spriteNode
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
        
        spawnPowerUp()
        spawnRevive()
        
        finalNode = childNodeWithName(TBFinalNode.name)
        finalBackNode = self.childNodeWithName(TBFinalNode.nameBack)
    }
    
    func updatePercentageLabel(){
        let per = Int(stagePercentage!)
        percentage?.text = "\(per)%"
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        super.update(currentTime)
        if(hasBegan) {
            self.stagePercentage = Double(floor(100*(hero.position.x - self.firstHeroPosition.x)/(deathNodeReference!.frame.size.width)))
            updatePercentageLabel()
        }
        
    }
    
    //MARK -- CONTACT
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
        if(bodyA.categoryBitMask == GameScene.PLAYER_NODE  && bodyB.categoryBitMask == (GameScene.STOP_CAMERA_NODE )){
            //muda o estado da camera para a função update não alterar a posição dela
            stateCamera = -1
            stopParalax = true
        }
        else if(bodyA.categoryBitMask == GameScene.PLAYER_NODE && bodyB.categoryBitMask == GameScene.REVIVE_NODE)
        {
            if let reviveNode = bodyB.node as? TBReviveNode {
                if(!reviveNode.picked)
                {
                    reviveNode.picked = true
                    reviveNode.runAction(TBReviveNode.animation!)
                }
            }
        }
        else if(bodyA.categoryBitMask == GameScene.PLAYER_NODE  && bodyB.categoryBitMask == (GameScene.END_LEVEL_NODE )){
            //terminou
            if(!finalStage)
            {
                finalStage = true
                
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
            //Salvando os dados com persistencia
                saveLogsFetched(self.hero, bitMark: self.coinsMark, levelSelected: self.levelSelected!, tentativas: self.numberOfDeath)
                
            // somando todos os dados para adicionar ao game center
                // - função sumStatistics() chama fetchLogs() e deve ser chamada após salvar os logs atuais
                let totalStatistics = sumStatistics()
                submitScoreGC(totalStatistics.score)
                collect21BitsAchievementGC(totalStatistics.numBits)
                coinsAchievementGC(totalStatistics.moedas)
                bugsAchievementGC(totalStatistics.monstersTotalKilled)
                
                Flurry.logEvent("CompletedLevel", withParameters: ["Stage": levelSelected!])
                hero.realSpeed = 0
                
                let action = SKAction.sequence([TBFinalNode.animation!, SKAction.runBlock({
                    if self.completionNode?.parent == nil {
                        
                    }
                    self.childNodeWithName(TBFinalNode.nameBack)!.runAction(
                        
                        SKAction.sequence([TBFinalNode.animationBack!, SKAction.waitForDuration(0.1), SKAction.runBlock({
                            self.scene?.view?.paused = true
                            let defaults = NSUserDefaults.standardUserDefaults()
                            let max = defaults.integerForKey("level")
                            if max < self.levelSelected! + 1 {
                                defaults.setInteger(self.levelSelected! + 1, forKey: "level")
                            }
                            if self.completionNode == nil{
                                self.completionNode = TBCompletionLevelNode.unarchiveFromFile("TBCompletionLevelNode")
                            }
                            self.completionNode!.zPosition = self.HUDz
                            self.completionNode!.setUP(self.numberOfDeath,bits:self.coinsMark , coins: self.hero.qtdMoedas, monsters: self.hero.monstersKilled, pontos: self.hero.score)
                            if (self.completionNode?.parent == nil){
                                self.camera!.addChild(self.completionNode!)
                            }
                            
                        })])
                    )
                    
                })])
                
                self.camera?.enumerateChildNodesWithName("hud", usingBlock: {(node,pointer) in
                    node.removeFromParent()
                })
                self.camera?.enumerateChildNodesWithName(self.removable, usingBlock: {(node,pointer) in
                    node.removeFromParent()
                })
                
                let clearedArr = TBUtils.getSprites(SKTextureAtlas(named:"AreaCleared"), nomeImagens: "AC-")
                let areaCleared = SKSpriteNode( texture: clearedArr[0])
                let actionClear = SKAction.animateWithTextures(clearedArr, timePerFrame: 0.1)
                self.camera?.addChild(areaCleared)
                
                let groupFinal2 = SKAction.group([SKAction.playSoundFileNamed("Complete.wav", waitForCompletion: false), actionClear])
                
                areaCleared.runAction(SKAction.sequence([groupFinal2, SKAction.runBlock({
                    //if areaCleared.parent != nil{
                    areaCleared.removeFromParent()
                    //}
                })]))
                let groupFinal = SKAction.group([SKAction.playSoundFileNamed("GateClosed", waitForCompletion: true), action])
                finalNode!.runAction(SKAction.sequence([SKAction.waitForDuration(1.5) ,groupFinal]))
                
            }
        }
    }
}