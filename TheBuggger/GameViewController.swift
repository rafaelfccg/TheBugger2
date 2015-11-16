//
//  GameViewController.swift
//  TheBuggger
//
//  Created by Rafael Gouveia on 9/28/15.
//  Copyright (c) 2015 rfccg. All rights reserved.
//

import UIKit
import SpriteKit
import GoogleMobileAds

class GameViewController: UIViewController, SceneChangesDelegate, GADInterstitialDelegate {
    
    var gameMethod:Int?
    var level:String?
    var bannerView:GADInterstitial?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.hidden = true
        self.bannerView = GADInterstitial(adUnitID: "ca-app-pub-6041956545350401/7481016976")
//        self.bannerView
        let request = GADRequest()
        
        request.testDevices = ["c4336acbf820c8d2c37e54257d6dcffb"]
        self.bannerView!.loadRequest(request)
        selectLevel(self.level!)
        //showAds()
    }
    
    func interstitialDidReceiveAd(ad: GADInterstitial!) {
        ad.presentFromRootViewController(self)
    }
    func selectLevel(nomeSKS: String){
        if let scene = SelectLevelScene(fileNamed: nomeSKS) {
            // Configure the view.
            //scene.delegateChanger = self
            scene.delegateChanger = self
            
            let skView = self.view as! SKView
            //skView.showsFPS = true
            //skView.showsNodeCount = true
             // skView.showsPhysics = true;
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill
            
            //scene.isMethodOne = 1
            
            skView.presentScene(scene)
        }
        
    }
    
    func showAds(){
    
        if(self.bannerView!.isReady){
            self.bannerView?.presentFromRootViewController(self)
        }
    }
    
    func mudaScene(nomeSKS: String, withMethod:Int, andLevel:Int)
    {
        if let scene = GameScene(fileNamed: nomeSKS) {
            // Configure the view.
            scene.delegateChanger = self
            scene.levelSelected = andLevel
            
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
        skView.scene?.removeAllActions()
        skView.scene?.removeAllChildren()
        //self.navigationController?.popViewControllerAnimated(true)
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
