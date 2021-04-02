//
//  PremiumViewController.swift
//  PocketHumidor
//
//  Created by Darius Pasca on 06/03/2019.
//  Copyright © 2019 Darius Pasca. All rights reserved.
//

import UIKit
import SwiftyStoreKit

class PremiumViewController: UIViewController,  UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var purchaseButton: UIButton!
    @IBOutlet weak var bePremium: UILabel!
    @IBOutlet weak var closeButtonImage: UIImageView!
    var hideCloseButton = true
    var outOfItems:Bool?
    let impact = UIImpactFeedbackGenerator(style: .light)
    
    
    var featuresTitle = [NSLocalizedString("Unlimited Stacks", comment: ""), NSLocalizedString("Infinite Items", comment: ""), NSLocalizedString("Support Development", comment: "")]
    var featuresDescription = [NSLocalizedString("Mange as many stacks as you want. The free version limit is 2 stacks.", comment: ""),NSLocalizedString("Add as many items as you want. The free version limit is 25 items.", comment: ""), NSLocalizedString("PocketStack is being developed and supported by an indie developer. Support the further development of the app.", comment: "")]
    var featureIcon = [UIImage(named: "Multiple"),UIImage(named: "Infinite"),UIImage(named: "Developer")]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        closeButtonImage.isHidden = hideCloseButton
        closeButtonImage.isUserInteractionEnabled = !hideCloseButton
        if UserSettings.isPremium.value == true {
            bePremium.text = "Premium Member Benefits"
            bePremium.font = bePremium.font.withSize(20)
            purchaseButton.isEnabled = false
            purchaseButton.isHidden = true
        }
        else{
            purchaseButton.isEnabled = true
            purchaseButton.isHidden = false
        }
        
        purchaseButton.setTitle(NSLocalizedString("Unlock Premium for ", comment: "") + UserSettings.premiumPrice.value , for: .normal)
        
        if outOfItems == nil {
            featuresTitle.reverse()
            featuresDescription.reverse()
            featureIcon.reverse()
        }
        else if outOfItems!{
            featuresTitle.rearrange(from: 0, to: 1)
            featuresDescription.rearrange(from: 0, to: 1)
            featureIcon.rearrange(from: 0, to: 1)
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UserEngagement.logEvent(.premmiumPageView)
    }
    
    @IBAction func purchase(_ sender: UIButton) {
        SwiftyStoreKit.retrieveProductsInfo(["premium"]) { result in
            if let product = result.retrievedProducts.first {
                SwiftyStoreKit.purchaseProduct(product, quantity: 1, atomically: true) { result in
                    
                    //Logs StartPurchase
                    if UserEngagement.sendAnalytics{
                        UserEngagement.logEvent(.premiumPurchaseStart)
                    }
                    
                    switch result {
                    case .success(let product):
                        if product.needsFinishTransaction {
                            SwiftyStoreKit.finishTransaction(product.transaction)
                        }
                        
                        //Log DidPurchase
                        if UserEngagement.sendAnalytics{
                            UserEngagement.logEvent(.premiumPurchaseCompleted)
                        }
                        
                        UserSettings.isPremium.value = true
                        self.successAlert(title: NSLocalizedString("Thank you!", comment: ""),message: NSLocalizedString("You've successfully purchased PocketHumidor Premium!", comment: ""))
                        
                    case .error(let error):
                        switch error.code {
                        case .unknown: self.presentAlert(title: NSLocalizedString("There Is A Problem", comment: ""), message: NSLocalizedString("Sorry, something unexpected happened.If the error persists write us at support@pockethumidor.app", comment: ""))
                        case .clientInvalid: self.presentAlert(title: NSLocalizedString("There Is A Problem", comment: ""), message: NSLocalizedString("Sorry, you're not allowed to make the payment", comment: ""))
                        case .paymentCancelled: UserEngagement.logEvent(.premiumPurchaseCanceled); break
                        case .paymentInvalid:
                            print("The purchase identifier was invalid")
                            self.presentAlert(title: NSLocalizedString("There Is A Problem", comment: ""), message: NSLocalizedString("Sorry, something unexpected happened. Try later or send an e-mail at support@pockethumidor.app", comment: ""))
                        case .paymentNotAllowed: self.presentAlert(title: NSLocalizedString("There Is A Problem", comment: ""), message: NSLocalizedString("The device is not allowed to make the payment. If the error persists write us at support@pockethumidor.app", comment: ""))
                        case .storeProductNotAvailable:
                            print("The product is not available in the current storefront")
                            self.presentAlert(title: NSLocalizedString("There Is A Problem", comment: ""), message: NSLocalizedString("Sorry, something unexpected happened.If the error persists write us at support@pockethumidor.app", comment: ""))
                        case .cloudServicePermissionDenied:
                            print("Access to cloud service information is not allowed")
                            self.presentAlert(title: NSLocalizedString("There Is A Problem", comment: ""), message: NSLocalizedString("Sorry, something unexpected happened.If the error persists write us at support@pockethumidor.app", comment: ""))
                        case .cloudServiceNetworkConnectionFailed:  self.presentAlert(title: NSLocalizedString("There Is A Problem", comment: ""), message: NSLocalizedString("Could not connect to the newtwork. If the error persists write us at support@pockethumidor.app", comment: ""))
                        case .cloudServiceRevoked: print("User has revoked permission to use this cloud service")
                        case .privacyAcknowledgementRequired:
                            self.presentAlert(title: NSLocalizedString("There Is A Problem", comment: ""), message: NSLocalizedString("Sorry, something unexpected happened.If the error persists write us at support@pockethumidor.app", comment: ""))
                        case .unauthorizedRequestData:
                            self.presentAlert(title: NSLocalizedString("There Is A Problem", comment: ""), message: NSLocalizedString("Sorry, something unexpected happened.If the error persists write us at support@pockethumidor.app", comment: ""))
                        case .invalidOfferIdentifier:
                            self.presentAlert(title: NSLocalizedString("There Is A Problem", comment: ""), message: NSLocalizedString("Sorry, something unexpected happened.If the error persists write us at support@pockethumidor.app", comment: ""))
                        case .invalidSignature:
                            self.presentAlert(title: NSLocalizedString("There Is A Problem", comment: ""), message: NSLocalizedString("Sorry, something unexpected happened.If the error persists write us at support@pockethumidor.app", comment: ""))
                        case .missingOfferParams:
                            self.presentAlert(title: NSLocalizedString("There Is A Problem", comment: ""), message: NSLocalizedString("Sorry, something unexpected happened.If the error persists write us at support@pockethumidor.app", comment: ""))
                        case .invalidOfferPrice:
                            self.presentAlert(title: NSLocalizedString("There Is A Problem", comment: ""), message: NSLocalizedString("Sorry, something unexpected happened.If the error persists write us at support@pockethumidor.app", comment: ""))
                        case .overlayCancelled:
                            self.presentAlert(title: NSLocalizedString("There Is A Problem", comment: ""), message: NSLocalizedString("Sorry, something unexpected happened.If the error persists write us at support@pockethumidor.app", comment: ""))
                        case .overlayInvalidConfiguration:
                            self.presentAlert(title: NSLocalizedString("There Is A Problem", comment: ""), message: NSLocalizedString("Sorry, something unexpected happened.If the error persists write us at support@pockethumidor.app", comment: ""))
                        case .overlayTimeout:
                            self.presentAlert(title: NSLocalizedString("There Is A Problem", comment: ""), message: NSLocalizedString("Sorry, something unexpected happened.If the error persists write us at support@pockethumidor.app", comment: ""))
                        case .ineligibleForOffer:
                            self.presentAlert(title: NSLocalizedString("There Is A Problem", comment: ""), message: NSLocalizedString("Sorry, something unexpected happened.If the error persists write us at support@pockethumidor.app", comment: ""))
                        case .unsupportedPlatform:
                            self.presentAlert(title: NSLocalizedString("There Is A Problem", comment: ""), message: NSLocalizedString("Sorry, something unexpected happened.If the error persists write us at support@pockethumidor.app", comment: ""))
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
                print(results.restoreFailedPurchases)
            }
            else if results.restoredPurchases.count > 0 {
                UserSettings.isPremium.value = true
                self.successAlert(title: "", message: NSLocalizedString("You've successfully restored your purchase!", comment: ""))
            }
            else {
                self.presentAlert(title: NSLocalizedString("There Is A Problem", comment: ""), message: NSLocalizedString("Sorry, no previous Premium purchase was found.", comment: ""))
            }
        }
    }
    
    func reload(){
        bePremium.fadeTransition(1.5)
        bePremium.text = "Premium Member Benefits"
        bePremium.font = bePremium.font.withSize(20)
        purchaseButton.isEnabled = false
        purchaseButton.isHidden = true
    }
    
    func presentAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func successAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            self.reload()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func dismiss(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    
    //CollectionView
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "featureCell", for: indexPath) as! PremiumFeaturesCollectionViewCell
        cell.premiumImage.image = featureIcon[indexPath.row]
        cell.featureTitleLabel.text = featuresTitle[indexPath.row]
        cell.featureDescriptionLabel.text = featuresDescription[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        impact.impactOccurred()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        let totalCellWidth = 80 * collectionView.numberOfItems(inSection: 0)
        let totalSpacingWidth = 5 * (collectionView.numberOfItems(inSection: 0) - 1)
        
        let leftInset = (collectionView.layer.frame.size.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
        let rightInset = leftInset
        
        return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
        
    }
    

}

class PremiumFeaturesCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var premiumImage: UIImageView!
    @IBOutlet weak var featureTitleLabel: UILabel!
    @IBOutlet weak var featureDescriptionLabel: UILabel!
    
    
    
}

@IBDesignable
public class AngleView: UIView {
    
    @IBInspectable public var fillColor: UIColor = .blue { didSet { setNeedsLayout() } }
    
    var points: [CGPoint] = [
        .zero,
        CGPoint(x: 1, y: 0),
        CGPoint(x: 1, y: 0.4),
        CGPoint(x: 0, y: 0.5)
        ] { didSet { setNeedsLayout() } }
    
    private lazy var shapeLayer: CAShapeLayer = {
        let _shapeLayer = CAShapeLayer()
        self.layer.insertSublayer(_shapeLayer, at: 0)
        return _shapeLayer
    }()
    
    override public func layoutSubviews() {
        shapeLayer.fillColor = fillColor.cgColor
        
        guard points.count > 2 else {
            shapeLayer.path = nil
            return
        }
    
        let path = UIBezierPath()
        path.move(to: convert(relativePoint: points[0]))
        for point in points.dropFirst() {
            path.addLine(to: convert(relativePoint: point))
        }
        
        path.close()
        
        shapeLayer.path = path.cgPath
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(
            roundedRect: self.bounds,
            byRoundingCorners: .allCorners,
            cornerRadii: CGSize(width: 10, height: 10)
            ).cgPath
        
        self.layer.mask = maskLayer
    }
    
    private func convert(relativePoint point: CGPoint) -> CGPoint {
        return CGPoint(x: point.x * bounds.width + bounds.origin.x, y: point.y * bounds.height + bounds.origin.y)
    }
}
