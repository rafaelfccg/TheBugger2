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
import AVFoundation


class GameViewController: UIViewController, SceneChangesDelegate, GADInterstitialDelegate{
    
    var gameMethod:Int?
    var level:String?
    var interstitial:GADInterstitial?
    var backgroundMusicPlayer:AVAudioPlayer?
    var backgroundMusicPlayer2:AVAudioPlayer?
    let clickedButton = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("NormalButton", ofType: "wav")!)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.hidden = true
        self.interstitial = createAndLoadInterstitial()
        selectLevel(self.level!)
        
    }
    
    func gameOver(){
        if interstitial!.isReady {
            interstitial!.presentFromRootViewController(self)
        }
        //createAndLoadInterstitial()
    }
    func createAndLoadInterstitial() -> GADInterstitial {

        let newInterstitial = GADInterstitial(adUnitID: "ca-app-pub-6041956545350401/7481016976")
        newInterstitial!.delegate = self
        let request = GADRequest()
        request.testDevices = ["c4336acbf820c8d2c37e54257d6dcffb","efa04c216ac1cdf43763e139720b8045"];
        newInterstitial!.loadRequest(request)
        return newInterstitial
    }
    func interstitialDidDismissScreen(ad: GADInterstitial!) {
        ad.delegate = nil
        self.interstitial = createAndLoadInterstitial()
    }
    
    func clearScene(){
        let skView = self.view as? SKView
        if skView?.scene != nil {
            skView?.scene?.removeAllActions()
            skView?.scene?.removeAllChildren()
            skView?.presentScene(nil)
        }
    }
    
    func selectLevel(nomeSKS: String){
        clearScene()
        let backgroundMusicURL = NSBundle.mainBundle().URLForResource("introMenu", withExtension: ".wav")
        playSound(&backgroundMusicPlayer,backgroundMusicURL: backgroundMusicURL!)
        if let scene = SelectLevelScene(fileNamed: nomeSKS) {
            // Configure the view.
            //scene.delegateChanger = self
            scene.delegateChanger = self
            
            let skView = self.view as! SKView
            //skView.showsFPS = true
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill
        
            skView.presentScene(scene)
        }
    }
    
    func mudaScene(nomeSKS: String, withMethod:Int, andLevel:Int)
    {
        clearScene()
        if let scene = GameScene(fileNamed: nomeSKS) {
           setScene(scene, withMethod: withMethod, andLevel: andLevel)
        }
    }
    
    func setScene(scene:GameSceneBase, withMethod:Int, andLevel:Int){
        self.backgroundMusicPlayer?.stop()
        scene.delegateChanger = self
        scene.levelSelected = andLevel
        
        let skView = self.view as! SKView
        //           skView.showsFPS = true
        //skView.showsNodeCount = true
        //skView.showsPhysics = true
        NSNotificationCenter.defaultCenter().addObserver(scene, selector:Selector("backToForeground"), name: "willEnterForeground", object: nil)
        skView.ignoresSiblingOrder = true
        
        scene.scaleMode = .AspectFill
        
        scene.isMethodOne = withMethod
        
        skView.presentScene(scene)
    }
    func mudaSceneBoss(nomeSKS: String, withMethod:Int, andLevel:Int)
    {
        clearScene()
        if let scene = FirstBossGameScene(fileNamed: nomeSKS) {
            setScene(scene, withMethod: withMethod, andLevel: andLevel)
        }
        
    }

    func backToMenu() {
        var skView = self.view as? SKView
        
        skView?.paused = true
        skView?.scene?.removeAllActions()
        skView?.scene?.removeAllChildren()
        skView?.presentScene(nil)
        skView = nil
        
        self.navigationController?.popViewControllerAnimated(false)
    
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
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        if(segue.identifier == "backToMenuSegue"){
            do {
                try  backgroundMusicPlayer = AVAudioPlayer(contentsOfURL: self.clickedButton)
                backgroundMusicPlayer!.play()
            }catch {
                print("MUSIC NOT FOUND")
            }
            let mainView = segue.destinationViewController as! UINavigationController
            let arr = mainView.viewControllers
            let menu =  arr[0] as! TBMenuViewController ;
            menu.backgroundMusicPlayer = backgroundMusicPlayer
            //mainView.backgroundMusicPlayer = self.backgroundMusicPlayer
        }
    }
}
