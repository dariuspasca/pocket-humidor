//
//  AppDelegate.swift
//  CigarStack
//
//  Created by Darius Pasca on 25/02/2018.
//  Copyright © 2018 Darius Pasca. All rights reserved.
//

import UIKit
import CoreData
import SwiftyStoreKit
import SVProgressHUD
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var backgroundUpdateTask: UIBackgroundTaskIdentifier!
    
    var tabBarController: TabBarController {
        return window!.rootViewController as! TabBarController
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
       
       UserEngagement.initialiseUserAnalytics()
       completeStoreTransactions()
       setupAdditionalStoreSettings()
       setupSvProgressHud()
        
        //Keeps track of the versiom for now
        if UserSettings.currentVersion.value == "" {
            UserSettings.currentVersion.value = UserEngagement.appVersion
        }
        else{
            if UserEngagement.appVersion > UserSettings.currentVersion.value {
                 UserSettings.currentVersion.value = UserEngagement.appVersion
            }
        }

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        if UserSettings.iCloudAutoBackup.value && UserSettings.iCloud.value{
            self.runBackup()
        }
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        UserEngagement.onAppOpen()
 
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
        if UserSettings.iCloudAutoBackup.value && UserSettings.iCloud.value{
            self.runBackup()
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
        if url.absoluteString.hasSuffix(".csv") {
            openCsvImport(url: url)
        }
        return true
    }
    
    func setupSvProgressHud() {

        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.setDefaultAnimationType(.native)
        SVProgressHUD.setDefaultMaskType(.clear)
        SVProgressHUD.setMinimumDismissTimeInterval(2)
    }
    
    func openCsvImport(url: URL) {
        tabBarController.selectedIndex = 4
        
        
        let settingsSplitView = tabBarController.selectedSplitViewController!
        let navController = settingsSplitView.masterNavigationController
        navController.dismiss(animated: false)

        navController.viewControllers.first!.performSegue(withIdentifier: "settingsData", sender: url)
 
    }
    
    func setupAdditionalStoreSettings(){
        //Enable in appstore purchase
        SwiftyStoreKit.shouldAddStorePaymentHandler = { payment, product in
            return true
        }
        
        //Saves the price
        SwiftyStoreKit.retrieveProductsInfo(["premium"]) { result in
            if let product = result.retrievedProducts.first {
                UserSettings.premiumPrice.value = product.localizedPrice!
            }
        }
    }
    
    func completeStoreTransactions(){
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    //Unlock content
                    UserSettings.isPremium.value = true
                case .failed, .purchasing, .deferred:
                    break // do nothing
                }
            }
        }
    }
    
    func runBackup(){
        let cloudManager = CloudDataManager()
        DispatchQueue.global().async(execute: { () -> Void in
            self.beginBackgroundUpdateTask()
                
            cloudManager.runBackup()
                
                // End the background task.
            self.endBackgroundUpdateTask()
        })
    }
    
    func beginBackgroundUpdateTask() {
        self.backgroundUpdateTask = UIApplication.shared.beginBackgroundTask(expirationHandler: {
            self.endBackgroundUpdateTask()
        })
    }
    
    func endBackgroundUpdateTask() {
        UIApplication.shared.endBackgroundTask(self.backgroundUpdateTask)
        self.backgroundUpdateTask = UIBackgroundTaskInvalid
    }
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "PocketHumidor")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}

