//
//  UserEngagement.swift
//  CigarStack
//
//  Created by Darius Pasca on 08/03/2018.
//  Copyright © 2018 Darius Pasca. All rights reserved.
//

import Foundation
import StoreKit
import Firebase

class UserEngagement{
    static let appStartupCountKey = "appStartupCount"
    static let userEngagementCountKey = "userEngagementCount"
    
    static var sendAnalytics: Bool {
        return UserSettings.shareAnalytics.value
    }
    
    static var sendCrashReports: Bool {
        return UserSettings.shareCrashReports.value
    }
    
    static func initialiseUserAnalytics() {
        if sendAnalytics { FirebaseApp.configure() }
        if sendCrashReports { Fabric.with([Crashlytics.self]) }
    }
    
    static func onReviewTrigger() {
        UserDefaults.standard.incrementCounter(withKey: userEngagementCountKey)
        if shouldTryRequestReview() {
            SKStoreReviewController.requestReview()
        }
    }
    
    static func onAppOpen() {
        UserDefaults.standard.incrementCounter(withKey: appStartupCountKey)
    }
    
    private static func shouldTryRequestReview() -> Bool {
        let appStartCountMinRequirement = 3
        let userEngagementModulo = 10
        
        let appStartCount = UserDefaults.standard.getCount(withKey: appStartupCountKey)
        let userEngagementCount = UserDefaults.standard.getCount(withKey: userEngagementCountKey)
        
        print(userEngagementCount)
        
        return appStartCount >= appStartCountMinRequirement && userEngagementCount % userEngagementModulo == 0
    }
    
    static var appVersion: String {
        get { return Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String }
    }
    
    static var appBuildNumber: String {
        get { return Bundle.main.infoDictionary!["CFBundleVersion"] as! String }
    }
    
    enum Event: String {
        // Add
        case addHumidor = "Add_Humidor"
        case addCigar = "Add_Cigar"
        
        // Data
        case csvImport = "CSV_Import"
        case csvUnsuccessfulImport = "CSV_Import_Error"
        case csvExport = "CSV_Export"
        case csvUnsuccessfulExport = "CSV_Export_Error"
        case deleteAllData = "Delete_All_Data"
        
        // Modify
        case deleteCigar = "Delete_Cigar"
        case reviewCigar = "Review_Cigar"
        case giftCigar = "Gift_Cigar"
        case editCigar = "Edit_Cigar"
        case moveCigar = "Move_Cigar"
        case editHumidor = "Edit_Humidor"
        
        // Search
        case search = "Search_Cigar"
        
        // Settings changes
        case disableAnalytics = "Disable_Analytics"
        case enableAnalytics = "Enable_Analytics"
        case disableCrashReports = "Disable_Crash_Reports"
        case enableCrashReports = "Enable_Crash_Reports"
        case changeSortOrder = "Change_Sort"
        
        // Premium
        case premmiumPageView = "Premium_Visualization"
        case premiumPurchaseStart = "Premium_Purchase_Start"
        case premiumPurchaseCompleted = "Premium_Purchase_Completed"
        case premiumPurchaseCanceled = "Premium_Purchase_Canceled"
    }
    
    static func logEvent(_ event: Event) {
        guard sendAnalytics else { return }
        Analytics.logEvent(event.rawValue, parameters: nil)
    }
}

extension UserDefaults {
    func incrementCounter(withKey key: String) {
        let newCount = UserDefaults.standard.integer(forKey: key) + 1
        UserDefaults.standard.set(newCount, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    func getCount(withKey: String) -> Int {
        return UserDefaults.standard.integer(forKey: withKey)
    }
}
