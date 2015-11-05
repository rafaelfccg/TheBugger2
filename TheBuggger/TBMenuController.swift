//
//  MenuController.swift
//  TheBuggger
//
//  Created by Rafael Gouveia on 10/26/15.
//  Copyright © 2015 rfccg. All rights reserved.
//

import Foundation
import UIKit

class TBMenuViewController :UIViewController {
    
    @IBOutlet weak var butMet1: UIButton!
    @IBOutlet weak var butMet3: UIButton!
    @IBOutlet weak var butMet2: UIButton!
    
    @IBOutlet weak var veryEasyBut: UIButton!
    @IBOutlet weak var normalBut: UIButton!
    @IBOutlet weak var veryHardBut: UIButton!
    
    
    var isMethodOne:Int?
    var stringLevel:String?
    
    override func viewDidLoad() {
        self.navigationController?.navigationBarHidden = true
    }
    
    override func viewDidAppear(animated: Bool) {
        
        TBEspinhosNode.createSKActionAnimation()
        TBGroundBotNode.createSKActionAnimation()
        TBMoedasNode.createSKActionAnimation()
        TBPlayerNode.createPlayerAttack()
        TBPlayerNode.createPlayerDefense()
        TBPlayerNode.createPlayerWalkAnimation()
        TBPlayerNode.createPlayerStandAnimation()
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
        TBRedLightEffect.createRedLightAnimation()
        TBPlayerNode.createDeathAnimation()
        
    }
    
    @IBAction func actionButMet1(sender: AnyObject) {
        isMethodOne = 1
        self.performSegueWithIdentifier("toLevelSegue", sender: self)
    }
    
    @IBAction func actionButMet2(sender: AnyObject) {
        isMethodOne = 2
        self.performSegueWithIdentifier("toLevelSegue", sender: self)
    }
    
    @IBAction func actionButMet3(sender: AnyObject) {
        isMethodOne = 3
        self.performSegueWithIdentifier("toLevelSegue", sender: self)  
        
    }
    
    @IBAction func veryEasyLevel(sender: AnyObject) {
        self.stringLevel = "Level1Scene"
        self.performSegueWithIdentifier("ToGameSegue", sender: self)
    }
    
    @IBAction func normalLevel(sender: AnyObject) {
        self.stringLevel = "Level2Scene"
        self.performSegueWithIdentifier("ToGameSegue", sender: self)
    }
    @IBAction func veryHarLevel(sender: AnyObject) {
        self.stringLevel = "Level3SceneFinal"
        self.performSegueWithIdentifier("ToGameSegue", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "ToGameSegue"){
            let gameView = segue.destinationViewController as! GameViewController
            gameView.gameMethod = isMethodOne
            gameView.level = self.stringLevel
        }else if segue.identifier == "toLevelSegue"{
            let levelView = segue.destinationViewController as! TBMenuViewController
            levelView.isMethodOne = isMethodOne

        }
    }
    @IBAction func backButton(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
}