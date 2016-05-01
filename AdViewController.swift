//
//  AdViewController.swift
//  diceanimation
//
//  Created by Manuel on 16/04/16.
//  Copyright © 2016 Manuel. All rights reserved.
//

import UIKit
import GoogleMobileAds

class AdViewController: UIViewController, GADBannerViewDelegate {

    @IBOutlet weak var banner: GADBannerView!
    @IBOutlet weak var layBannerOffset: NSLayoutConstraint!
    @IBOutlet weak var layBannerHeight: NSLayoutConstraint!
    @IBOutlet weak var layBannerWidth: NSLayoutConstraint!
    
    override func viewDidLoad() {
        appAdViewController = self

    }
    
    func tryAdAgain(){
        if self.layBannerOffset.constant == 0 || self.banner.hidden {
            return
        }
        print("trying to load request again")
        let request = GADRequest()
        banner.loadRequest(request)
        
    }
    
    
    override func viewDidLayoutSubviews() {
        if banner.tag == 0 {
            let banner = self.banner
            banner.tag = 1
            delay(0.2){
                
                banner.hidden = false
                banner.backgroundColor = UIColor.yellowColor()
                
                let ipad = UIDevice.currentDevice().userInterfaceIdiom == .Pad
                
                self.layBannerHeight.constant = ipad ? 90.00 : 50.00
                self.layBannerWidth.constant = ipad ? 728.00 : self.view.frame.width
                
                // initial position of banner is hidden:
                self.layBannerOffset.constant = -self.layBannerHeight.constant
                self.view.layoutIfNeeded()
                
                banner.adUnitID = "ca-app-pub-3396432489758830/6337231506"
                banner.rootViewController = self
                banner.adSize = ipad ? kGADAdSizeLeaderboard : kGADAdSizeSmartBannerPortrait
                banner.delegate = self
                banner.loadRequest(GADRequest())
                banner.backgroundColor = UIColor.blackColor()
                NSTimer.scheduledTimerWithTimeInterval(60.00, target: self, selector: #selector(self.tryAdAgain), userInfo: nil, repeats: true)
                
            }

        }
    }
    
    func adViewDidReceiveAd(bannerView: GADBannerView!) {
        UIView.animateWithDuration(0.2, animations: {
            self.layBannerOffset.constant = 0.00
            self.view.layoutIfNeeded()
        })
    }
    
    func adView(bannerView: GADBannerView!, didFailToReceiveAdWithError error: GADRequestError!) {
        UIView.animateWithDuration(0.2, animations: {
            self.layBannerOffset.constant = -self.layBannerHeight.constant
            self.view.layoutIfNeeded()
        })
        
    }    
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    


}
