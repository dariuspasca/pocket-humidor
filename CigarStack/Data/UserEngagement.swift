//
//  UserEngagement.swift
//  CigarStack
//
//  Created by Darius Pasca on 08/03/2018.
//  Copyright © 2018 Darius Pasca. All rights reserved.
//

import Foundation
import StoreKit

class UserEngagement{
    static let appStartupCountKey = "appStartupCount"
    static let userEngagementCountKey = "userEngagementCount"
    
    static func onReviewTrigger() {
        UserDefaults.standard.incrementCounter(withKey: userEngagementCountKey)
        if #available(iOS 10.3, *), shouldTryRequestReview() {
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
        
        return appStartCount >= appStartCountMinRequirement && userEngagementCount % userEngagementModulo == 0
    }
    
    static var appVersion: String {
        get { return Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String }
    }
    
    static var appBuildNumber: String {
        get { return Bundle.main.infoDictionary!["CFBundleVersion"] as! String }
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
