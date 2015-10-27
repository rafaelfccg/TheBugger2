//
//  GameViewController.swift
//  TheBuggger
//
//  Created by Rafael Gouveia on 9/28/15.
//  Copyright (c) 2015 rfccg. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController, SceneChangesDelegate {
    
    var gameMethod:Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        TBEspinhosNode.createSKActionAnimation()
        TBGroundBotNode.createSKActionAnimation()
        TBMoedasNode.createSKActionAnimation()
        TBPlayerNode.createPlayerAttack()
        TBPlayerNode.createPlayerDefense()
        TBPlayerNode.createPlayerWalkAnimation()    
        
        self.navigationController?.navigationBar.hidden = true

        mudaScene("Level1SceneFinal",withMethod: gameMethod!)
    }
    
    func mudaScene(nomeSKS: String, withMethod:Int)
    {
        if let scene = GameScene(fileNamed: nomeSKS) {
            // Configure the view.
            scene.delegateChanger = self
            
            let skView = self.view as! SKView
            //skView.showsFPS = true
            //skView.showsNodeCount = true
            //skView.showsPhysics = true;
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill
            
            scene.isMethodOne = withMethod
            
            skView.presentScene(scene)
        }
    }
    func backToMenu() {
        let skView = self.view as! SKView
        
        skView.paused = true
        skView.scene?.removeAllChildren()
        
        self.performSegueWithIdentifier("backToMenuSegue", sender: self)  
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
