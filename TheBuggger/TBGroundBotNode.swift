//
//  TBGroundBotNode.swift
//  TheBuggger
//
//  Created by Victor Augusto Pereira Porciúncula on 02/10/15.
//  Copyright © 2015 rfccg. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class TBGroundBotNode: SKSpriteNode {
    static let name = "SpawnMonsterType1"
    
    var jaAtacou = false // Variavel auxiliar para o bot atacar apenas uma vez
    
    init() {
        
        super.init(texture: nil, color: UIColor.blackColor(), size: CGSizeMake(80, 80))
        var monsterArray = self.getSprites("GroundMonster", nomeImagens: "groundMonster-")
        self.texture = monsterArray[0]
        
        //self.color = UIColor.whiteColor()
        self.size = CGSizeMake(80, 80)
        self.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.size.width, self.size.height - 4))
        self.physicsBody?.friction = CGFloat(0)
        self.physicsBody?.linearDamping = 0
        self.physicsBody?.allowsRotation = false
        
        let action = SKAction.animateWithTextures(monsterArray, timePerFrame: 0.1);
        runAction(SKAction.repeatActionForever(action));
        
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getSprites(textureAtlasName: String, nomeImagens: String) -> Array<SKTexture>
    {
        let textureAtlas = SKTextureAtlas(named: textureAtlasName)
        var spriteArray = Array<SKTexture>();
        
        let numImages = textureAtlas.textureNames.count
        //        print("\(numImages)")
        for (var i=1; i <= numImages; i++)
        {
            let playerTextureName = "\(nomeImagens)\(i)"
            spriteArray.append(textureAtlas.textureNamed(playerTextureName))
        }
        
        return spriteArray;
    }
    
    func startAttack() {
        let tempoInvestida = CGVectorMake(-100, 0)
        let investida = SKAction.moveBy(tempoInvestida, duration: 0.2)
        self.runAction(investida)
    }

}
