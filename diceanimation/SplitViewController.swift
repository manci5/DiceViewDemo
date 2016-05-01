//
//  SplitViewController.swift
//  diceanimation
//
//  Created by Manuel on 12/17/15.
//  Copyright © 2015 Manuel. All rights reserved.
//

import UIKit
import StoreKit
import AVFoundation

var appSplitViewController: SplitViewController? = nil
var RiskRed = UIColor()
var RiskBlue = UIColor()
var upDices = [DiceView]()
var downDices = [DiceView]()
var whiteCount = 1
var hideGearsTime = 30.00
var audioPlayer = AVAudioPlayer()

class SplitViewController: UIViewController, UIAlertViewDelegate{

    @IBOutlet weak var containerUp: UIView!
    @IBOutlet weak var upToMiddle: NSLayoutConstraint!
    @IBOutlet weak var upToFullScreen: NSLayoutConstraint!
    
    @IBOutlet weak var containerDown: UIView!
    
    @IBOutlet weak var scoreLeft: UILabel!
    @IBOutlet weak var scoreRight: UILabel!
    @IBOutlet weak var scoreBoard: UIView!
    
    @IBOutlet weak var rules: UIImageView!
    @IBOutlet weak var rulesbutton: UIButton!
    
    @IBOutlet weak var gears: UIButton!
    @IBOutlet weak var gearsToBottom: NSLayoutConstraint!
    
    @IBOutlet weak var battery: UIImageView!
    @IBOutlet weak var batteryBar: UIView!
    @IBOutlet weak var batteryWidth: NSLayoutConstraint!

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var separator: UIView!
    
    var alert = UIAlertView()
    var timer = NSTimer()
    var runTime = NSDate()

    var blueAreUp = false
  
    var downViewController: ViewController { return self.childViewControllers[0] as! ViewController }
    var upViewController: ViewController { return self.childViewControllers[1] as! ViewController }
    
    
    
    override func viewDidLoad() {
        
        
        
        let rollURL =  NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("roll", ofType: "m4a")!)
        audioPlayer = try! AVAudioPlayer(contentsOfURL: rollURL)
        audioPlayer.prepareToPlay()        
        
        self.scoreBoard.hidden = true
        self.separator.transform = CGAffineTransformMakeRotation(CGFloat(M_PI*0.1))
        self.battery.transform = CGAffineTransformMakeTranslation(-0.5, 0.0)
        
        toggleGears(true)
        
        delay(hideGearsTime){
            self.toggleGears(false)
        }
        
        appSplitViewController = self
        scoreLeft.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
        
        
        RiskBlue = scoreLeft.textColor
        RiskRed = scoreRight.textColor
        
        self.upViewController.isTheUpper = true
        self.downViewController.isTheUpper = false
        
        appSplitViewController = self
        containerUp.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
        
        rules.alpha = 0.00
        rules.hidden = true
        rulesbutton.hidden = true
        
        if hideGearsTime == 120.00 { // first launch, gears button is visible for 2min, otherwise 30s
            displayRules()
        }
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        timer.invalidate()
        timer = NSTimer()
        UIDevice.currentDevice().batteryMonitoringEnabled = true
        timer = NSTimer(timeInterval: 30.00, target: self, selector: #selector(SplitViewController.updatebattery), userInfo: nil, repeats: true)
        self.updatebattery()
    }
    
    func peekGears(){
        
        if NSDate().timeIntervalSinceDate(runTime) > hideGearsTime && self.gears.alpha < 0.5 {
            
            delay(2.0){
                self.toggleGears(true)
            }
            delay(4.0){
                self.toggleGears(false)
            }
        }
    }
    
    

    func updatebattery(){
        let df = NSDateFormatter()
        df.dateFormat = "HH:mm"
        self.timeLabel.text = df.stringFromDate(NSDate())

        if !timer.valid { return }
        let level = CGFloat(UIDevice.currentDevice().batteryLevel)
        self.batteryBar.backgroundColor = level <= 0.20 ?  UIColor(red: 0.80, green: 0.0, blue: 0.0, alpha: 1.0) : UIColor.blackColor()
        
        self.batteryWidth.constant = level*20.00
    }
    
    
    func toggleGears( on: Bool){
        
        let alpha: CGFloat = 0.7

        self.battery.alpha = on ? alpha : 0
        self.batteryBar.alpha = on ? alpha : 0
        self.timeLabel.alpha = on ? alpha : 0
        self.gears.alpha = on ? 0.02 : 1.00
        
        UIView.animateWithDuration(0.3, animations: {
            
            self.battery.alpha = on ? 0 : alpha
            self.batteryBar.alpha = on ? 0 : alpha
            self.timeLabel.alpha = on ? 0 : alpha
            self.gears.alpha = on ? 1.00 : 0.02
            
            }, completion: nil)
        
    }
    
    func hideGears(){
        self.toggleGears(false)
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        timer.invalidate()
        timer = NSTimer()
    }
    
    func displayRules(){
        
        
        UIView.animateWithDuration(0.5, delay: 0.50, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.rules.hidden = false
            self.rulesbutton.hidden = false
            
            self.rules.alpha = 1.00
            self.rulesbutton.alpha = 1.00
            }, completion: {_ in
                self.rulesbutton.addTarget(self, action: #selector(SplitViewController.dismiss), forControlEvents: UIControlEvents.TouchUpInside)
        })

    }
    
    func dismiss(){
        
        UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.rules.alpha = 0.00
            self.rulesbutton.alpha = 0.00
            }, completion: {_ in
                self.rules.hidden = true
                self.rulesbutton.hidden = true
        })
        
    }
    
    func clearBoard(){
        self.clear(UIButton())
    }
    
    
    @IBAction func gearsAction(sender: AnyObject) {
        let soundsmessage = sounds ? "Disable Sounds" : "Enable Sounds"
        self.alert = UIAlertView(title: "Menu", message: "", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "3 Red + 2 Blue", "Single White", "Double White", "Show Rules", soundsmessage)
        self.alert.show()
        
    }
    
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        switch buttonIndex {
        case 1: // red+blue
            self.changeTo(white: false)
            self.upViewController.removeDices()
            whiteCount = 0
        case 2: // single white
            self.changeTo(white: true)
            self.upViewController.removeDices()
            whiteCount = 1
        case 3: // double white
            self.changeTo(white: true)
            self.upViewController.removeDices()
            whiteCount = 2
        case 4:
            self.displayRules()
        case 5:
            sounds = !sounds
            NSUserDefaults.standardUserDefaults().setBool(sounds, forKey: "sounds")
        default: break
        }
        
        
        
    }
    
    func changeTo(white white: Bool){
        
        self.upViewController.whiteView.hidden = !white
        
        if white {
            self.upToMiddle.active = false
            self.upToFullScreen.active = true
            self.upViewController.halfVignette.hidden = true
        }
        else {
            self.upToMiddle.active = true
            self.upToFullScreen.active = false
            self.upViewController.halfVignette.hidden = false
        }
        
        self.view.layoutIfNeeded()
        
        UIView.animateWithDuration(0.60, delay: 0.00, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            
            for vc in [self.upViewController, self.downViewController]{
                vc.woodLayout.constant = white ? -100.00 : 0.00
                vc.holderLayout.constant = white ? -100.00 : -10.00
                vc.view.layoutIfNeeded()
            }
        }, completion: nil)
        

    }
    
    @IBAction func clear(sender: UIButton) {
        self.upViewController.removeDices()
        self.downViewController.removeDices()
        upDices = []
        downDices = []
        scoreBoard.hidden = true
    }
    
    func checkDices(){
        
        self.scoreBoard.layer.removeAllAnimations()
        UIView.animateWithDuration(0.3, animations: {
            self.scoreBoard.alpha = 0.00
            }, completion: {value in
                self.scoreBoard.hidden = true
        })
        
        // don't check if no dices, or same colors, or for whites
        if upDices.count == 0 || downDices.count == 0 { return }
        if upDices.first!.color == downDices.first!.color { return }
        if upDices.first!.color == .White || downDices.first!.color == .White { return }
        
        appSplitViewController!.view.userInteractionEnabled = false
        
        delay(0.4){
            UIView.animateWithDuration(0.3, animations: {
                self.scoreBoard.hidden = false
                self.scoreBoard.alpha = 0.00
                self.scoreBoard.alpha = 1.00
            })
            appSplitViewController!.view.userInteractionEnabled = true
        }
        
        blueAreUp = upDices.first!.color == .Blue
        let bdices = blueAreUp ? upDices : downDices
        let rdices = blueAreUp ? downDices : upDices
        
        var bmax = 0
        var bmin = 7
        for bd in bdices {
            if bd.number>bmax { bmax = bd.number }
            if bd.number<bmin && bdices.count == 2 { bmin = bd.number }
        }
        
        var rmax = 0
        var rmax2 = 0
        for rd in rdices {
            if rd.number > rmax { rmax = rd.number }
        }
        var foundMax = 0
        if rdices.count > 1 {
            var rest = [DiceView]()
            for rd in rdices {
                if rd.number != rmax { rest.append(rd) }
                else {
                    foundMax+=1
                }
                if foundMax == 2 { rest.append(rd) }
            }
            for r in rest {
                if r.number > rmax2 { rmax2 = r.number }
            }
        }
        
        
        let blueWinners = bmin == 7 ? [bmax] : [bmax, bmin]
        let redWinners = rmax2 == 0 ? [rmax] : [rmax, rmax2]
        
        
        var blueLost = 0
        var redLost = 0
        
        if blueWinners.maxElement() >= redWinners.maxElement() { redLost+=1 }
        else { blueLost+=1 }
        
        if blueWinners.count == 2 && redWinners.count == 2 {
            if blueWinners.minElement() >= redWinners.minElement() { redLost+=1 }
            else { blueLost+=1 }
        }
        
        delay(0.35, closure: {
            self.redLost(redLost, blueLost: blueLost)
        })
        

        
    }
    
    func redLost(redlost: Int, blueLost bluelost: Int){
        
        scoreRight.textColor = blueAreUp ? RiskRed : RiskBlue
        scoreLeft.textColor = blueAreUp ? RiskBlue : RiskRed
        
        scoreRight.text = blueAreUp ? "\(-redlost)" : "\(-bluelost)"
        scoreLeft.text = blueAreUp ? "\(-bluelost)" : "\(-redlost)"

        
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    
}
