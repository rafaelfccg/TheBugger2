//
//  TBOptionsViewController.swift
//  TheBuggger
//
//  Created by Rafael Gouveia on 11/10/15.
//  Copyright © 2015 rfccg. All rights reserved.
//

import Foundation
import UIKit

class TBOptionsViewController: UIViewController {
    @IBOutlet weak var SettingsLabel: UILabel!
    
    @IBOutlet weak var method1Description: UILabel!
    @IBOutlet weak var methodLabel: UILabel!
    @IBOutlet weak var radioButtonMethod2: CheckBox!
    @IBOutlet weak var radioButtonMethod1: CheckBox!
   
    @IBOutlet weak var method2Description: UILabel!
    @IBOutlet weak var method2Label: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var animatedBack: UIImageView!
    var imageBack:UIImage?
    
    var method:Int?
    
    override func viewDidLoad() {
        method1Description.hidden = true
        method2Description.hidden = true
        method2Label.hidden = true
        methodLabel.hidden = true
        radioButtonMethod1.hidden = true
        radioButtonMethod2.hidden = true
        
        animatedBack.animationImages = [UIImage(named: "set-1")!,
            UIImage(named: "set-2")!,
            UIImage(named: "set-3")!,
            UIImage(named: "set-4")!,
            UIImage(named: "set-5")!,
            UIImage(named: "set-6")!]
        animatedBack.animationDuration = 0.35
        animatedBack.animationRepeatCount = 1
        backgroundImage.image = imageBack
        let gestureBack = UITapGestureRecognizer(target: self, action: Selector("back"))
        backgroundImage.addGestureRecognizer(gestureBack)
        backgroundImage.userInteractionEnabled = true
    
        let defaults = NSUserDefaults.standardUserDefaults()
        method = defaults.integerForKey("method")
        
        if method == 1 {
            radioButtonMethod1.isChecked = true
            radioButtonMethod2.isChecked = false
        }else{
            radioButtonMethod1.isChecked = false
            radioButtonMethod2.isChecked = true
        }
        
    }
    func change(){
        radioButtonMethod1.isChecked = !radioButtonMethod1.isChecked
        radioButtonMethod2.isChecked = !radioButtonMethod2.isChecked

    }
    
    func back(){
        //logs customizados no flurry
        if(method == 1)
        {
            Flurry.logEvent("Method 1 Choosed")
        }
        else if(method == 2)
        {
            Flurry.logEvent("Method 2 Choosed")
        }
        self.navigationController?.popViewControllerAnimated(false)
    }
    
    @IBAction func selectMethod1(sender: AnyObject) {
        if method != 1{
            method = 1
             let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setInteger(method!, forKey: "method")
            change()
        }
    }
    
    @IBAction func selectMethod2(sender: AnyObject) {
        if method != 2 {
            method = 2
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setInteger(method!, forKey: "method")
            change()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        animatedBack.image = UIImage(named: "set-6")
        animatedBack.startAnimating()
        self.performSelector(Selector("showElements"), withObject: nil, afterDelay: 0.35)

    }
    
    func showElements(){
        method1Description.hidden = false
        method2Description.hidden = false
        method2Label.hidden = false
        methodLabel.hidden = false
        radioButtonMethod1.hidden = false
        radioButtonMethod2.hidden = false
        
    }
}