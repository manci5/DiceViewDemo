//
//  ViewController.swift
//  diceanimation
//
//  Created by Manuel on 12/16/15.
//  Copyright © 2015 Manuel. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    var isTheUpper = false
    var thrownDices = [DiceView]()
    
    @IBOutlet weak var numbers: UIView!
    @IBOutlet weak var bottomBar: UIImageView!
    
    @IBOutlet weak var b1: UIButton!
    @IBOutlet weak var b2: UIButton!
    @IBOutlet weak var b3: UIButton!
    @IBOutlet weak var b4: UIButton!
    @IBOutlet weak var b5: UIButton!
    
    @IBOutlet weak var woodLayout: NSLayoutConstraint!
    @IBOutlet weak var holderLayout: NSLayoutConstraint!
    
    
    var rollFromTop = false
    @IBOutlet weak var whiteView: UIView!
    @IBOutlet weak var halfVignette: UIImageView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            let t1 = CGAffineTransformMakeTranslation(0, -5.00)
            let t2 = CGAffineTransformMakeScale(1.2, 1.2)
            self.numbers.transform = CGAffineTransformConcat(t1, t2)
        }
        
        for v in [b1, b2, b3, b4, b5]{
            let c2 = CGAffineTransformMakeScale(0.92, 1.0)
            v.transform = c2
        }
        
    }
    
    
    @IBAction func throwButtonAction(sender: UIButton) { // blue: -1 -2, red: 1 2 3
        throwDices(sender.tag < 0 ? .Blue : .Red, count: abs(sender.tag))
    }
    
    @IBAction func rollWhiteAction(sender: AnyObject) {
        rollFromTop = (sender as! UIButton).tag == 1
        self.throwDices(.White, count: whiteCount)
    }
    
    func removeDices(){
        
        let thrown = Array(thrownDices)
        self.thrownDices.removeAll()
        
        for thrownDice in thrown {
            UIView.animateWithDuration(0.15, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                thrownDice.alpha = 0.00
                }, completion: { value in
                    thrownDice.removeFromSuperview()
            })
        }
        
    }
    
    
    
    func throwDices(color: DiceColor, count: Int){
        
        if sounds {
            delay(0.2){
                audioPlayer.stop()
                audioPlayer.play()
            }
        }
        
        if !upDices.isEmpty && !downDices.isEmpty {
            if upDices[0].color != downDices[0].color {
                appSplitViewController!.clearBoard()
            }
        }
        removeDices()
        
        let f = self.view.frame
        var reds = [DiceView]()
        let ipad = UIDevice.currentDevice().userInterfaceIdiom == .Pad
        var diceDimension =  min(f.width, f.height)*(color == .White ? (count == 1 && !ipad ? (0.6) : 0.3) : 0.25)
        for number in 0..<count {
            let dice = DiceView(frame: CGRectMake(0, 0, diceDimension, diceDimension), color: color, number: random()%6+1)
            if color == .White { self.whiteView.insertSubview(dice, atIndex: 1)}
            else { self.view.insertSubview(dice, atIndex: 2)}
            reds.append(dice)
            self.thrownDices.append(dice)
        }
        
        func randomFactor() -> CGFloat { // -0.05 to 0.05
            return (CGFloat((random()%10000))/10000.00-0.5)*0.1
        }
        let fact: CGFloat = 1.4
        let reverse = color == .White && rollFromTop ? true : false
        let startPositionY = reverse ? -diceDimension*fact : f.height+diceDimension*fact
        if reverse {
            switch count {
            case 1:
                reds[0].center = CGPointMake(f.width*(0.5+randomFactor()*2), startPositionY)
            case 2:
                reds[0].center = CGPointMake(f.width*(0.3+randomFactor()), startPositionY)
                reds[1].center = CGPointMake(f.width*(0.7+randomFactor()), startPositionY)
            default:
                break
            }
        }
        else {
            switch count {
            case 1:
                reds[0].center = CGPointMake(f.width*(0.5+randomFactor()*2), startPositionY)
            case 2:
                reds[0].center = CGPointMake(f.width*(0.3+randomFactor()), startPositionY)
                reds[1].center = CGPointMake(f.width*(0.7+randomFactor()), startPositionY)
            case 3:
                reds[0].center = CGPointMake(f.width*(0.2+randomFactor()*0.5), startPositionY)
                reds[1].center = CGPointMake(f.width*(0.5+randomFactor()*0.5), startPositionY)
                reds[2].center = CGPointMake(f.width*(0.8+randomFactor()*0.5), startPositionY)
            default:
                break
            }
        }
        
        
        for red in reds {
            UIView.animateWithDuration(0.30, delay: Double(randomFactor())*5.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                let throwDistance = f.height
                let _: CGFloat = (color == .White && count == 1 ? 140 : 20)
                _ = -throwDistance*(1+randomFactor())
                red.center = CGPointMake(red.center.x, f.height*((color == .White ? 0.5+(reverse ? -0.1 : 0.1) : 0.35)+randomFactor()))
                red.transform = CGAffineTransformMakeRotation(randomFactor()*20)
                }, completion: nil)
        }
        
        if self.isTheUpper { upDices = self.thrownDices}
        else               { downDices = self.thrownDices}
        
        appSplitViewController!.checkDices()
        
        
        
    }


}










