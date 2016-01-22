//
//  TBSKNodeExtension.swift
//  TheBuggger
//
//  Created by Rafael Gouveia on 1/20/16.
//  Copyright © 2016 rfccg. All rights reserved.
//

import Foundation
import SpriteKit
extension SKNode{
    func removeParentIfPossible(){
        if self.parent != nil {
            self.removeFromParent()
        }
    }
}