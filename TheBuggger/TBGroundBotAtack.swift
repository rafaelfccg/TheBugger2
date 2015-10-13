//
//  TBGroundBotShot.swift
//  TheBuggger
//
//  Created by Victor Augusto Pereira Porciúncula on 02/10/15.
//  Copyright © 2015 rfccg. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class TBGroundBotAttack: GKComponent {
    var botToAttack: SKNode!
    func startAttack() {
        let tempoInvestida = CGVectorMake(-100, 0)
        let investida = SKAction.moveBy(tempoInvestida, duration: 0.2)
        self.botToAttack.runAction(investida)
    }
    
}
