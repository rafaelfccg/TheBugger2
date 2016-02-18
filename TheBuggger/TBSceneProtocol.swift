//
//  TBSceneProtocol.swift
//  TheBuggger
//
//  Created by Rafael Gouveia on 2/16/16.
//  Copyright © 2016 rfccg. All rights reserved.
//

import Foundation

protocol TBSceneProtocol{
    
    var isMethodOne:Int?{ get set }
    var levelSelected:Int?{get set}
    var delegateChanger: SceneChangesDelegate?{get set}
    
}