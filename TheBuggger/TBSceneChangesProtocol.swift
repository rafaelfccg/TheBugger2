//
//  TBSceneChangesProtocol.swift
//  TheBuggger
//
//  Created by Victor Augusto Pereira Porciúncula on 1/26/16.
//  Copyright © 2016 rfccg. All rights reserved.
//

import Foundation

protocol SceneChangesDelegate{
    
    func mudaScene(nomeSKS: String, withMethod:Int, andLevel:Int)
    func backToMenu()
    func selectLevel(nomeSKS: String)
    func gameOver()
    func mudaSceneBoss(nomeSKS: String, withMethod:Int, andLevel:Int)
    func startAnimations()
    func stopAnimations()
    func runStory(story:TBStoriesScene, withMethod:Int, andLevel:Int)
}