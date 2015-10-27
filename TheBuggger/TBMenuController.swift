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
    
    var isMethodOne:Int?
    
    
    override func viewDidAppear(animated: Bool) {
        
    }
    
    @IBAction func actionButMet1(sender: AnyObject) {
        isMethodOne = 1
        self.performSegueWithIdentifier("ToGameSegue", sender: self)
        
        
    }
    
    @IBAction func actionButMet2(sender: AnyObject) {
        isMethodOne = 2
        self.performSegueWithIdentifier("ToGameSegue", sender: self)
    }
    
    @IBAction func actionButMet3(sender: AnyObject) {
        isMethodOne = 3
        self.performSegueWithIdentifier("ToGameSegue", sender: self)
        
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "ToGameSegue"){
            //if isMethodOne! {
            let gameView = segue.destinationViewController as!GameViewController
            gameView.gameMethod = isMethodOne
            //}
        }
    }
}