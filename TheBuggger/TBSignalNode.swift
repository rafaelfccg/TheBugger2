//  Created by Rafael Gouveia on 11/3/15.
//  Copyright © 2015 rfccg. All rights reserved.
//

import Foundation
import SpriteKit

class TBSignalNode:SKSpriteNode {
    static var signalAnimation:SKAction?
    static var signalAtlas:SKTextureAtlas = SKTextureAtlas(named: "signal")
    static func createSignalAnimation(){
        let pixelsArray = TBUtils().getSprites(signalAtlas, nomeImagens: "greensignal-")
        TBSignalNode.signalAnimation = SKAction.repeatActionForever(SKAction.animateWithTextures(pixelsArray, timePerFrame: 0.05));
        
    }
}