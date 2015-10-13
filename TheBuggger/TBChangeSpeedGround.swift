//
//  TBChangeSpeedGround.swift
//  TheBuggger
//
//  Created by Rafael Gouveia on 10/13/15.
//  Copyright © 2015 rfccg. All rights reserved.
//

import Foundation
import SpriteKit

class TBChangeSpeedGround: SKSpriteNode {
    var speedAdded:Int
    var hadEffect:Bool

    required init?(coder aDecoder: NSCoder) {
        speedAdded = 0
        hadEffect = false
        super.init(coder: aDecoder)
    }
}