//
//  TBOptionsViewController.swift
//  TheBuggger
//
//  Created by Rafael Gouveia on 11/10/15.
//  Copyright © 2015 rfccg. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class TBOptionsViewController: UIViewController {
    @IBOutlet weak var SettingsLabel: UILabel!
    @IBOutlet weak var allyson: UILabel!
    @IBOutlet weak var vitor: UILabel!
    @IBOutlet weak var rafael: UILabel!
    @IBOutlet weak var maysa: UILabel!
    @IBOutlet weak var Thyago: UILabel!
    @IBOutlet weak var programmers: UILabel!
    @IBOutlet weak var designers: UILabel!
    
    @IBOutlet weak var method1Description: UILabel!
    @IBOutlet weak var methodLabel: UILabel!
    @IBOutlet weak var radioButtonMethod2: CheckBox!
    @IBOutlet weak var radioButtonMethod1: CheckBox!
   
    @IBOutlet weak var backButton: UIImageView!
    @IBOutlet weak var method2Description: UILabel!
    @IBOutlet weak var method2Label: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var animatedBack: UIImageView!
    var imageBack:UIImage?
    var backgroundMusicPlayer:AVAudioPlayer?
    var effectMusicPlayer:AVAudioPlayer?
    let clickedButton = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("NormalButton", ofType: "wav")!)
    var method:Int?
    var isCredit:Bool = false
    
    override func viewDidLoad() {
        if !self.isCredit {
            method1Description.hidden = true
            method2Description.hidden = true
            method2Label.hidden = true
            methodLabel.hidden = true
            radioButtonMethod1.hidden = true
            radioButtonMethod2.hidden = true
        
            let tapDesc1 = UITapGestureRecognizer(target: self, action: #selector(TBOptionsViewController.selector1))
            let tapDesc2 = UITapGestureRecognizer(target: self, action: #selector(TBOptionsViewController.selector2))
            
            methodLabel.addGestureRecognizer(tapDesc1)
            methodLabel.userInteractionEnabled  = true
            method2Label.addGestureRecognizer(tapDesc2)
            method2Label.userInteractionEnabled  = true
            
            let defaults = NSUserDefaults.standardUserDefaults()
            method = defaults.integerForKey("method")
            
            if method == 1 {
                radioButtonMethod1.isChecked = true
                radioButtonMethod2.isChecked = false
            }else{
                radioButtonMethod1.isChecked = false
                radioButtonMethod2.isChecked = true
            }

        }else{
            self.allyson.hidden = true
            self.vitor.hidden = true
            self.rafael.hidden = true
            self.Thyago.hidden = true
            self.maysa.hidden = true
            self.programmers.hidden = true
            self.designers.hidden = true
        }
        animatedBack.animationImages = [UIImage(named: "set-1")!,
            UIImage(named: "set-2")!,
            UIImage(named: "set-3")!,
            UIImage(named: "set-4")!,
            UIImage(named: "set-5")!,
            UIImage(named: "set-6")!]
        animatedBack.animationDuration = 0.35
        animatedBack.animationRepeatCount = 1
        backgroundImage.image = imageBack
        let gestureBack = UITapGestureRecognizer(target: self, action: #selector(TBOptionsViewController.back))
        backgroundImage.addGestureRecognizer(gestureBack)
        backgroundImage.userInteractionEnabled = true
        
        backButton.animationImages = [UIImage(named: "back-1")!,
            UIImage(named: "back-2")!,
            UIImage(named: "back-3")!,
            UIImage(named: "back-2")!]
        backButton.animationRepeatCount = -1
        backButton.animationDuration = 1
        backButton.startAnimating()
        backButton.userInteractionEnabled = true
        let gestureBack2 = UITapGestureRecognizer(target: self, action: #selector(TBOptionsViewController.back))
        backButton.addGestureRecognizer(gestureBack2)
        
    }
    func change(){
        
        radioButtonMethod1.isChecked = !radioButtonMethod1.isChecked
        radioButtonMethod2.isChecked = !radioButtonMethod2.isChecked
    }
    func selector1(){
        if method != 1{
            method = 1
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setInteger(method!, forKey: "method")
            change()
        }
    }
    
    func selector2(){
        if method != 2{
            method = 2
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setInteger(method!, forKey: "method")
            change()
        }
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
        do {
            try  backgroundMusicPlayer = AVAudioPlayer(contentsOfURL: self.clickedButton)
                backgroundMusicPlayer!.play()
        }catch {
            print("MUSIC NOT FOUND")
        }
        selector1()
    }
    
    @IBAction func selectMethod2(sender: AnyObject) {
        do {
            try  backgroundMusicPlayer = AVAudioPlayer(contentsOfURL: self.clickedButton)
            backgroundMusicPlayer!.play()
        }catch {
            print("MUSIC NOT FOUND")
        }
        selector2()
    }
    
    override func viewDidAppear(animated: Bool) {
        animatedBack.image = UIImage(named: "set-6")
        animatedBack.startAnimating()
        
        self.performSelector(#selector(TBOptionsViewController.showElements), withObject: nil, afterDelay: 0.35)
        
    }
    
    func showElements(){
        if !self.isCredit {
            method1Description.hidden = false
            method2Description.hidden = false
            method2Label.hidden = false
            methodLabel.hidden = false
            radioButtonMethod1.hidden = false
            radioButtonMethod2.hidden = false
        }else{
            self.allyson.hidden = false
            self.vitor.hidden = false
            self.rafael.hidden = false
            self.Thyago.hidden = false
            self.maysa.hidden = false
            self.programmers.hidden = false
            self.designers.hidden = false
        }
        
    }
}