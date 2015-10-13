//
//  TBFlying.swift
//  TheBuggger
//
//  Created by Victor Augusto Pereira Porciúncula on 06/10/15.
//  Copyright © 2015 rfccg. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class TBFlying: GKComponent {
    var botToFly: SKNode!
    
    func flying() {
        let tempoDecida = CGVectorMake(-20, -200)
        let decida = SKAction.moveBy(tempoDecida, duration: 0.5)
        
        let tempoSubida = CGVectorMake(-20, 200)
        let subida = SKAction.moveBy(tempoSubida, duration: 0.5)
        
        let group = SKAction.sequence([decida, subida, decida, subida, decida, subida, decida, subida, decida, subida, decida, subida])
        self.botToFly.runAction(group)
    }
}
