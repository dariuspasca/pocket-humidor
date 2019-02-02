//
//  PurchaseViewController.swift
//  CigarStack
//
//  Created by Darius Pasca on 08/03/2018.
//  Copyright © 2018 Darius Pasca. All rights reserved.
//

import UIKit
import SwiftyStoreKit
import Crashlytics

class PurchaseViewController: UIViewController {
    
    @IBOutlet weak var purchaseButton: UIButton!
    @IBOutlet weak var bePremium: UILabel!
    @IBOutlet weak var closeButtonImage: UIImageView!
    var hideCloseButton = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        closeButtonImage.isHidden = hideCloseButton
        closeButtonImage.isUserInteractionEnabled = !hideCloseButton
        if UserSettings.isPremium.value == true {
            bePremium.text = "Premium Member"
            purchaseButton.isEnabled = false
            purchaseButton.isHidden = true
        }
        else{
             purchaseButton.isEnabled = true
            purchaseButton.isHidden = false
        }
 
        purchaseButton.setTitle(NSLocalizedString("Unlock Premium for ", comment: "") + UserSettings.premiumPrice.value , for: .normal)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        //Logs PageViews
        if UserSettings.shareAnalytics.value == true{
            Answers.logContentView(withName: "PocketStack Premium",
                                           contentType: "In-App Purchase",
                                           contentId: "premium-001",
                                           customAttributes: nil)
        }
    }
    

    @IBAction func purchase(_ sender: UIButton) {
        SwiftyStoreKit.retrieveProductsInfo(["premium"]) { result in
            if let product = result.retrievedProducts.first {
                SwiftyStoreKit.purchaseProduct(product, quantity: 1, atomically: true) { result in
                    let price = product.price
                    let currencyCode = product.priceLocale.currencyCode
                    
                    //Logs StartPurchase
                    if UserSettings.shareAnalytics.value == true {
                        Answers.logStartCheckout(withPrice: price,
                                                          currency: currencyCode,
                                                          itemCount: 1,
                                                          customAttributes: nil)
                    }
                    
                    switch result {
                    case .success(let product):
                        if product.needsFinishTransaction {
                            SwiftyStoreKit.finishTransaction(product.transaction)
                        }
                        
                        //Log DidPurchase
                        if UserSettings.shareAnalytics.value == true {
                            Answers.logPurchase(withPrice: price,
                                                currency: currencyCode,
                                                success: true,
                                                itemName: "Premium",
                                                itemType: "In-App Purchase",
                                                itemId: "iap-001",
                                                customAttributes: nil)
                        }
                        
                        UserSettings.isPremium.value = true
                        self.presentAlert(title: NSLocalizedString("Thank you!", comment: ""),message: NSLocalizedString("You've successfully purchased PocketHumidor Premium!", comment: ""))
                        
                    case .error(let error):
                        switch error.code {
                        case .unknown: self.presentAlert(title: NSLocalizedString("There Is A Problem", comment: ""), message: NSLocalizedString("Sorry, something unexpected happened.If the error persists write us at support@pockethumidor.app", comment: ""))
                        case .clientInvalid: self.presentAlert(title: NSLocalizedString("There Is A Problem", comment: ""), message: NSLocalizedString("Sorry, you're not allowed to make the payment", comment: ""))
                        case .paymentCancelled: break
                        case .paymentInvalid:
                            print("The purchase identifier was invalid")
                            self.presentAlert(title: NSLocalizedString("There Is A Problem", comment: ""), message: NSLocalizedString("Sorry, something unexpected happened. Try later or send an e-mail at support@pockethumidor.app", comment: ""))
                        case .paymentNotAllowed: self.presentAlert(title: NSLocalizedString("There Is A Problem", comment: ""), message: NSLocalizedString("The device is not allowed to make the payment. If the error persists write us at support@pockethumidor.app", comment: ""))
                        case .storeProductNotAvailable:
                            print("The product is not available in the current storefront")
                            self.presentAlert(title: NSLocalizedString("There Is A Problem", comment: ""), message: NSLocalizedString("Sorry, something unexpected happened. Try later or send an e-mail at support@pockethumidor.app", comment: ""))
                        case .cloudServicePermissionDenied:
                            print("Access to cloud service information is not allowed")
                            self.presentAlert(title: NSLocalizedString("There Is A Problem", comment: ""), message: NSLocalizedString("Sorry, something unexpected happened. Try later or send an e-mail at support@pockethumidor.app", comment: ""))
                        case .cloudServiceNetworkConnectionFailed:  self.presentAlert(title: NSLocalizedString("There Is A Problem", comment: ""), message: NSLocalizedString("Could not connect to the newtwork. If the error persists write us at support@pockethumidor.app", comment: ""))
                        case .cloudServiceRevoked: print("User has revoked permission to use this cloud service")
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func restorePurchase(_ sender: UIButton) {
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            if results.restoreFailedPurchases.count > 0 {
                self.presentAlert(title: NSLocalizedString("There Is A Problem", comment: ""), message: NSLocalizedString("Sorry, something unexpected happened. Try later or send an e-mail at support@pockethumidor.app", comment: ""))
            }
            else if results.restoredPurchases.count > 0 {
                UserSettings.isPremium.value = true
                self.presentAlert(title: "", message: NSLocalizedString("You've successfully restored your purchase!", comment: ""))
            }
            else {
               self.presentAlert(title: NSLocalizedString("There Is A Problem", comment: ""), message: NSLocalizedString("Sorry, no previous Premium purchase was found.", comment: ""))
            }
        }
    }
    
    func presentAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func dismiss(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    
}

