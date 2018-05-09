//
//  TabBarViewController.swift
//  CigarStack
//
//  Created by Darius Pasca on 20/03/2018.
//  Copyright © 2018 Darius Pasca. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    var previousSelectedItem: Int!

    override func viewDidLoad() {
        self.delegate = self

    }
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item.tag == 1 {
            if UserSettings.currentHumidor.value != ""{
                let destVC = UIStoryboard(name: "NewCigar", bundle: nil).instantiateInitialViewController() as! UINavigationController
                if UIDevice.current.userInterfaceIdiom == .pad{
                    destVC.modalPresentationStyle = .formSheet
                    destVC.modalTransitionStyle = .coverVertical
                    destVC.preferredContentSize = CGSize(width: 500, height: 700)
                }
                present(destVC, animated: true, completion: nil)
            }
            else{
                // create the alert
                let alert = UIAlertController(title: "", message: NSLocalizedString("To add cigars at least one humidor is required. You can create one by pressing the plus (+) button in the top right corner.", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                
                // add an action (button)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                alert.view.tintColor = UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1)
                
                // show the alert
                self.present(alert, animated: true, completion: nil)
            }
        }

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

