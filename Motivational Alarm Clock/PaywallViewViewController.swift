//
//  PaywallViewViewController.swift
//  Motivational Alarm Clock
//
//  Created by Alek Matthiessen on 1/12/21.
//  Copyright © 2021 Alek Matthiessen. All rights reserved.
//

import UIKit
import Firebase
import Purchases
import FBSDKCoreKit
import MBProgressHUD
import AppsFlyerLib
import AVKit
import AVFoundation
import Kingfisher
import FirebaseDatabase

@objc protocol SwiftPaywallDelegate {
    func purchaseCompleted(paywall: PaywallViewViewController, transaction: SKPaymentTransaction, purchaserInfo: Purchases.PurchaserInfo)
    @objc optional func purchaseFailed(paywall: PaywallViewViewController, purchaserInfo: Purchases.PurchaserInfo?, error: Error, userCancelled: Bool)
    @objc optional func purchaseRestored(paywall: PaywallViewViewController, purchaserInfo: Purchases.PurchaserInfo?, error: Error?)
}

var ref : DatabaseReference?

var uid = String()
var referrer = String()
var didpurchase = Bool()

class PaywallViewViewController: UIViewController {
    
    var purchases = Purchases.configure(withAPIKey: "slBUTCfxpPxhDhmESLETLyjJtFpYzjCj", appUserID: nil)
    
    var delegate : SwiftPaywallDelegate?
    
    private var offering : Purchases.Offering?
    
    private var offeringId : String?

    @IBAction func tapPay(_ sender: Any) {
        
        guard let package = offering?.availablePackages[0] else {
            print("No available package")
            MBProgressHUD.hide(for: view, animated: true)
            
            return
        }
        
        
        Purchases.shared.purchasePackage(package) { (trans, info, error, cancelled) in
            
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if let error = error {
                
                MBProgressHUD.hide(for: self.view, animated: true)
                
                if let purchaseFailedHandler = self.delegate?.purchaseFailed {
                    purchaseFailedHandler(self, info, error, cancelled)
                } else {
                    if !cancelled {
                        
                    }
                }
            } else  {
                if let purchaseCompletedHandler = self.delegate?.purchaseCompleted {
                    purchaseCompletedHandler(self, trans!, info!)
                    
//                    self.logPurchaseSuccessEvent(referrer : referrer)
                    //
                    ref?.child("Users").child(uid).updateChildValues(["Purchased" : "True"])
                    
                    didpurchase = true
                    
                    AppsFlyerLib.shared().logEvent(AFEventStartTrial, withValues: [AFEventParam1 : referrer])
                    
//                                            AppsFlyerTracker.shared().trackEvent(AFEventStartTrial, withValues: [
//                                                AFEventParamContentId: referrer,
//
//                                            ]);
                    
                    MBProgressHUD.hide(for: self.view, animated: true)
                    
                    
                    referrer = "Paywall"
                    
                    self.dismiss(animated: true, completion: nil)
                    
                    
                    
                } else {
                    
//                    self.logPurchaseSuccessEvent(referrer : referrer)
                    //
                    ref?.child("Users").child(uid).updateChildValues(["Purchased" : "True"])
                    
                    MBProgressHUD.hide(for: self.view, animated: true)
                    
                    
                    //                        AppsFlyerTracker.shared().trackEvent(AFEventStartTrial, withValues: [
                    //                            AFEventParamContentId: referrer,
                    //
                    //                        ]);
                    didpurchase = true
                    
                    referrer = "Paywall"
                    
                    self.dismiss(animated: true, completion: nil)
                    
                    
                    
                }
            }
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()

        Purchases.shared.offerings { (offerings, error) in
            
            if error != nil {
            }
            if let offeringId = self.offeringId {
                
                self.offering = offerings?.offering(identifier: "Yearly")
            } else {
                self.offering = offerings?.current
            }
            
        }

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
