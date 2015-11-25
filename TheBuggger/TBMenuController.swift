//
//  MenuController.swift
//  TheBuggger
//
//  Created by Rafael Gouveia on 10/26/15.
//  Copyright © 2015 rfccg. All rights reserved.
//

import AVFoundation
import UIKit

class TBMenuViewController :UIViewController {
    
    @IBOutlet weak var butMet1: UIButton!
    @IBOutlet weak var butMet3: UIButton!
    @IBOutlet weak var butMet2: UIButton!
    
    @IBOutlet weak var veryEasyBut: UIButton!
    @IBOutlet weak var normalBut: UIButton!
    @IBOutlet weak var veryHardBut: UIButton!
    
    @IBOutlet weak var efeitoCima: UIImageView!
    @IBOutlet weak var efeitoBaixo: UIImageView!
    
    var isMethodOne:Int?
    var stringLevel:String?
    var backgroundMusicPlayer:AVAudioPlayer?
    
    override func viewDidLoad() {
        self.navigationController?.navigationBarHidden = true
        
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
        TBFinalNode.createSKActionAnimation()
        TBBrilhoNode.createBrilhoAnimation()
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
        
        if(backgroundMusicPlayer == nil){
            
            let backgroundMusicURL = NSBundle.mainBundle().URLForResource("introMenu", withExtension: ".wav")
            
            do {
                try  backgroundMusicPlayer = AVAudioPlayer(contentsOfURL: backgroundMusicURL!)
                backgroundMusicPlayer!.numberOfLoops  = -1
                if(!backgroundMusicPlayer!.playing){
                    backgroundMusicPlayer?.play()
                }
            }catch {
                print("MUSIC NOT FOUND")
            }
        }else{
            if(!backgroundMusicPlayer!.playing){
                backgroundMusicPlayer?.play()
            }
        }
        
    }
    
    @IBAction func actionButMet1(sender: AnyObject) {
        //isMethodOne = 1
        self.performSegueWithIdentifier("ToGameSegue", sender: self)
    }
    
    @IBAction func actionButMet2(sender: AnyObject) {
        self.performSegueWithIdentifier("ToOptionsSegue", sender: self)
        
        
    }
    func screenShotMethod()->UIImage {
        //Create the UIImage
        UIGraphicsBeginImageContextWithOptions(self.view.frame.size, false, UIScreen.mainScreen().scale)
        view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
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
            

        }
    }

}