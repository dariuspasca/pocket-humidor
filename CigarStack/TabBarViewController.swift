//
//  TabBarViewController.swift
//  CigarStack
//
//  Created by Darius Pasca on 20/03/2018.
//  Copyright © 2018 Darius Pasca. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate, AddCigarDelegate {

    var previousSelectedItem: Int!
    
    var selectedSplitViewController: UISplitViewController? {
        return selectedViewController as? UISplitViewController
    }

    override func viewDidLoad() {
        self.delegate = self

    }
    
    override func viewDidLayoutSubviews() {
        self.tabBar.invalidateIntrinsicContentSize()
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item.tag == 1 {
            if UserSettings.currentHumidor.value != ""{
                var countCigars:Int32 = 0
                let humidors = CoreDataController.sharedInstance.fetchHumidors()
                for humidor in humidors!{
                    countCigars = countCigars + humidor.quantity
                }
                
                if !UserSettings.isPremium.value && countCigars > 24{
                    let storyboard = UIStoryboard(name: "Settings", bundle: nil)
                    let destVC = storyboard.instantiateViewController(withIdentifier: "premiumController") as! PurchaseViewController
                    destVC.hideCloseButton = false
                    destVC.modalPresentationStyle = .formSheet
                    destVC.modalTransitionStyle = .coverVertical
                    self.present(destVC, animated: true, completion: nil)
                }
                else{
                    let destVC = UIStoryboard(name: "NewCigar", bundle: nil).instantiateInitialViewController() as! UINavigationController
                    let vc = destVC.topViewController as! AddCigarController
                    vc.delegate = self
                    destVC.modalPresentationStyle = .formSheet
                    destVC.modalTransitionStyle = .coverVertical
                    
                    if UIDevice.current.userInterfaceIdiom == .pad{
                        destVC.preferredContentSize = CGSize(width: 500, height: 700)
                    }
                    present(destVC, animated: true, completion: nil)
                }
            }
            else{
                // create the alert
                let alert = UIAlertController(title: NSLocalizedString("No Humidor Available", comment: ""), message: NSLocalizedString("To add items at least one humidor is required. Tap the + button in the right top corner to add a humidor.", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                
                // add an action (button)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                alert.view.tintColor = UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1)
                
                // show the alert
                self.present(alert, animated: true, completion: nil)
            }
        }
        else if item.tag == 3 {
            guard let selectedSplitViewController = selectedSplitViewController else { return }
            
            //back to root
            if selectedSplitViewController.masterNavigationController.viewControllers.count > 1 {
                selectedSplitViewController.masterNavigationController.popToRootViewController(animated: true)
            }
        }
    }
    
    
    func addCigarForceReload() {
        let nav = self.viewControllers![0] as! UINavigationController
        let home = nav.topViewController as! HomeViewController
        home.viewWillAppear(true)
    }
    
    func cigarTriggerReview() {
        UserEngagement.onReviewTrigger()
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let viewControllers = self.viewControllers
        if viewController == viewControllers![2] {
            return false
        }
        else {
            return true
        }
    }
}

