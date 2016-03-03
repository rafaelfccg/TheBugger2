//
//  MenuController.swift
//  TheBuggger
//
//  Created by Rafael Gouveia on 10/26/15.
//  Copyright © 2015 rfccg. All rights reserved.
//

import AVFoundation
import UIKit
import SpriteKit
import GameKit


class TBMenuViewController :UIViewController, GKGameCenterControllerDelegate {
    
    @IBOutlet weak var butMet1: UIButton!
    @IBOutlet weak var butMet2: UIButton!
    
    @IBOutlet weak var efeitoCima: UIImageView!
    @IBOutlet weak var efeitoBaixo: UIImageView!
    
    let backgroundMusicURL = NSBundle.mainBundle().URLForResource("introMenu", withExtension: ".wav")
    var backgroundMusicPlayer2:AVAudioPlayer?
    let clickedButton = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("NormalButton", ofType: "wav")!)
    var isMethodOne:Int?
    var stringLevel:String?
    var backgroundMusicPlayer:AVAudioPlayer?
    static var loadedAtlas = false
    

    @IBOutlet weak var theBuggerBoard: UIImageView!
    override func viewDidLoad() {
        self.navigationController?.navigationBarHidden = true
        if(!TBMenuViewController.loadedAtlas){
             SKTextureAtlas.preloadTextureAtlases([TBEspinhosNode.espinhosAtlas, TBBitNode.bitAtlas, TBGroundBotNode.monsterDeathAtlas, TBMoedasNode.moedaAtlas,TBPlayerNode.playerRunAtlas, TBPlayerNode.playerDashAtlas,TBEspinhoSoltoNode.espinhoAtlas, TBGroundBotNode.groundMonsterAtlas, TBShotBotNode.deathAtlas,TBUtils.paralaxAtlas],
                withCompletionHandler: {TBMenuViewController.loadedAtlas = true})
            
            
        }
        
        TBEspinhosNode.createSKActionAnimation()
        TBGroundBotNode.createSKActionAnimation()
        TBMoedasNode.createSKActionAnimation()
        TBPlayerNode.createPlayerAttack()
        TBPlayerNode.createPlayerDefense()
        TBPlayerNode.createPlayerWalkAnimation()
        TBPlayerNode.createPlayerStandAnimation()
        TBPlayerNode.createPlayerAirAnimation()
        TBPlayerNode.createPlayerFallingAnimation()
        TBTutorialNodes.createJumpTutorialAction()
        TBTutorialNodes.createTapTutorialAction()
        TBTutorialNodes.createSlideUpTutorialAction()
        TBTutorialNodes.createSlideRightTutorialAction()
        TBTutorialNodes.createAttackTutorialAction()
        TBTutorialNodes.createBlockTutorialAction()
        TBTutorialNodes.createSlideBackTutorialAction()
        TBFinalNode.createSKActionAnimation()
        TBAlertNode.createAlertAnimation()
        TBSignalNode.createSignalAnimation()
        TBMachineFrontNode.createMachineFrontAnimation()
        TBEspinhoSoltoNode.createSKActionAnimation()
        TBPlayerNode.createDeathAnimation()
        TBShotBotNode.createSKActionAnimation()
        TBShotNode.createSKActionAnimation()
        TBBitNode.createSKActionAnimation()
        TBChangeSpeedGround.createAccelerateAnimation()
        TBChangeSpeedGround.createSlowAnimation()
        TBBopperBotNode.createSKActionAnimation()
        TBFlyingBotNode.createSKActionAnimation()
        TBPlayerNode.createFrenezyAnimation()
        TBGreenLedsNode.createGreenLedsAnimation()
        TBFirstBossNode.createSKActionAnimation()
        TBMegaLaserNode.createSKActionAnimation()
        TBBallFirstBossNode.createSKActionAnimation()
        TBReviveNode.createSKActionAnimation()
        TBTutorialNodes.createBackScreenTutorialAction()
        
        self.theBuggerBoard.animationImages = [UIImage(named:"logo_1")!,
            UIImage(named: "logo_2")!,
            UIImage(named: "logo_3")!,
            UIImage(named: "logo_4")!,
            UIImage(named: "logo_5")!]
        self.theBuggerBoard.animationRepeatCount = -1
        self.theBuggerBoard.animationDuration   = 0.9
        self.theBuggerBoard.startAnimating()
        
        self.efeitoCima.animationImages = [UIImage(named:"enfeiteCima-1")!,
                                          UIImage(named: "enfeiteCima-2")!,
                                          UIImage(named: "enfeiteCima-3")!,
                                          UIImage(named: "enfeiteCima-4")!,
                                          UIImage(named: "enfeiteCima-5")!,
                                          UIImage(named: "enfeiteCima-4")!,
                                          UIImage(named: "enfeiteCima-3")!,
                                          UIImage(named: "enfeiteCima-2")!,]
        self.efeitoCima.animationRepeatCount = -1
        self.efeitoCima.animationDuration   = 0.9
        self.efeitoCima.startAnimating()
        
        
        self.efeitoBaixo.animationImages = [UIImage(named:"enfeiteBaixo-1")!,
            UIImage(named: "enfeiteBaixo-2")!,
            UIImage(named: "enfeiteBaixo-3")!,
            UIImage(named: "enfeiteBaixo-4")!,
            UIImage(named: "enfeiteBaixo-3")!,
            UIImage(named: "enfeiteBaixo-2")!,]
        self.efeitoBaixo.animationRepeatCount = -1
        self.efeitoBaixo.animationDuration   = 0.9
        self.efeitoBaixo.startAnimating()
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let method = defaults.integerForKey("method")
        if method > 2 || method <= 0{
            defaults.setInteger(1, forKey: "method")
        }
        let level = defaults.integerForKey("level")
        if level <= 0{
            defaults.setInteger(1, forKey: "level")
        }
        
        authenticateLocalPlayerGC()
        
        GKAchievement.resetAchievementsWithCompletionHandler { (error) -> Void in
            
        }
    }
    
    // autentica player no game center
    func authenticateLocalPlayerGC() {
        let localPlayer: GKLocalPlayer = GKLocalPlayer.localPlayer()
        
        localPlayer.authenticateHandler = {(ViewController, error) -> Void in
            if((ViewController) != nil) {
                // 1 Show login if player is not logged in
                self.presentViewController(ViewController!, animated: true, completion: nil)
            }
            else if (localPlayer.authenticated) {
                
                // 2 Player is already euthenticated & logged in, load game center
                print("Local player is authenticated\n")
                
            }
            else {
                // 3 Game center is not enabled on the users device
                print("Local player could not be authenticated, disabling game center\n")
                print(error)
            }
            
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        playSound(&backgroundMusicPlayer,backgroundMusicURL: backgroundMusicURL!)
    }
    
    @IBAction func actionButMet1(sender: AnyObject) {
        //isMethodOne = 1
        do {
            try  backgroundMusicPlayer2 = AVAudioPlayer(contentsOfURL: self.clickedButton)
            backgroundMusicPlayer2!.play()
        }catch {
            print("MUSIC NOT FOUND")
        }
        
        self.performSegueWithIdentifier("ToGameSegue", sender: self)
        
        
    }
    
    @IBAction func actionButMet2(sender: AnyObject) {
        
        
        let gcVC: GKGameCenterViewController = GKGameCenterViewController()
        gcVC.gameCenterDelegate = self
        gcVC.viewState = GKGameCenterViewControllerState.Leaderboards
        gcVC.leaderboardIdentifier = "TBAto1.Score"
        self.presentViewController(gcVC, animated: true, completion: nil)
        
//        do {
//            try  backgroundMusicPlayer2 = AVAudioPlayer(contentsOfURL: self.clickedButton)
//            backgroundMusicPlayer2!.play()
//        }catch {
//            print("MUSIC NOT FOUND")
//        }
//        self.performSegueWithIdentifier("ToOptionsSegue", sender: self)
        
        
    }
    func screenShotMethod()->UIImage {
        //Create the UIImage
        UIGraphicsBeginImageContextWithOptions(self.view.frame.size, false, UIScreen.mainScreen().scale)
        view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "ToGameSegue"){
            let gameView = segue.destinationViewController as! GameViewController
            gameView.gameMethod = isMethodOne
            gameView.level = "SelectLevelScene"
            gameView.backgroundMusicPlayer = self.backgroundMusicPlayer
        }else if segue.identifier == "ToOptionsSegue"{
            let options = segue.destinationViewController as! TBOptionsViewController
            options.imageBack = screenShotMethod()
            options.isCredit = false

        }else if segue.identifier == "ToCreditsSegue"{
            let options = segue.destinationViewController as! TBOptionsViewController
            options.imageBack = screenShotMethod()
            options.isCredit = true
        }
    }

}