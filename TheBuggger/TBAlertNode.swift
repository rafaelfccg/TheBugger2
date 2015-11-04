//  Created by Rafael Gouveia on 11/3/15.
//  Copyright © 2015 rfccg. All rights reserved.
//

import Foundation
import SpriteKit

class TBAlertNode :SKSpriteNode{
    static var alertAnimation:SKAction?
    
    static func createAlertAnimation(){
        let pixelsArray = TBUtils().getSprites("Alert", nomeImagens: "alert-")
        TBAlertNode.alertAnimation = SKAction.repeatActionForever(SKAction.animateWithTextures(pixelsArray, timePerFrame: 0.05));
        
    }
}