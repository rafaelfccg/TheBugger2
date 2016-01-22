
//  TBCompletionNode.swift
//  TheBuggger
//
//  Created by Rafael Gouveia on 11/26/15.
//  Copyright © 2015 rfccg. All rights reserved.
//

import Foundation
import SpriteKit

class TBSimpleBlockNode: SKNode {
    
    var delegateChanger:SceneChangesDelegate?
    var id:Int  = -1
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    class func unarchiveFromFile(file : String) -> TBSimpleBlockNode? {
        if let path = NSBundle.mainBundle().pathForResource(file, ofType: ".sks") {
            do{
                let sceneData = try NSData(contentsOfFile: path, options: NSDataReadingOptions.DataReadingMappedIfSafe)
                let archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
                
                archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
                let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as! TBSimpleBlockNode
                archiver.finishDecoding()
                return scene
            } catch {
                return nil
            }
        } else {
            return nil
        }
    }
}
