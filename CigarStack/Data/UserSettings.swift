//
//  UserSettings.swift
//  CigarStack
//
//  Created by Darius Pasca on 08/03/2018.
//  Copyright © 2018 Darius Pasca. All rights reserved.
//

import Foundation

enum TableSortOrder: Int {
    // 0 is the default preference value.
    case byDate = 0
    case byName = 1
    case byQuantity = 2
    case byPrice = 3
    case byCountry = 4
    case byAge = 5
    
    var displayName: String {
        switch self {
        case .byDate:
            return NSLocalizedString("Date", comment: "")
        case .byName:
            return NSLocalizedString("Name", comment: "")
        case .byQuantity:
            return NSLocalizedString("Quantity", comment: "")
        case .byPrice:
            return NSLocalizedString("Price", comment: "")
        case .byCountry:
            return NSLocalizedString("Country", comment: "")
        case .byAge:
            return NSLocalizedString("Age", comment: "")
        }
    }
}

struct UserSetting<SettingType> {
    private let key: String
    private let defaultValue: SettingType
    
    init(key: String, defaultValue: SettingType) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    var value: SettingType {
        get {
            return UserDefaults.standard.object(forKey: key) as? SettingType ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}

class UserSettings{
    
    private static let tableSortOrderKey = "tableSortOrder"
    static var tableSortOrder: TableSortOrder {
        get {
            return TableSortOrder(rawValue: UserDefaults.standard.integer(forKey: tableSortOrderKey)) ?? .byDate
        }
        set {
            if newValue != tableSortOrder {
                UserDefaults.standard.set(newValue.rawValue, forKey: tableSortOrderKey)
            }
        }
    }
    
    static var isPremium = UserSetting<Bool>(key: "sendAnalytics", defaultValue: false)
    static var sendAnalytics = UserSetting<Bool>(key: "sendAnalytics", defaultValue: true)
    static var sendCrashReports = UserSetting<Bool>(key: "sendCrashReports", defaultValue: true)
    static var iCloud = UserSetting<Bool>(key: "iCloud", defaultValue: true)
    static var defaultSortOrder = UserSetting<Int>(key: "defaultSortOrder", defaultValue: 0)
    static var sortAscending = UserSetting<Bool>(key: "SortAscending", defaultValue: true)
    static var openHumidor = UserSetting<Bool>(key: "openNewHumidor", defaultValue: true)
    
    static var shouldReloadData = UserSetting<Bool>(key: "shouldReloadData", defaultValue: false)
    static var shouldReloadView = UserSetting<Bool>(key: "shouldReloadView", defaultValue: false)
    static var currentHumidor = UserSetting<String>(key: "currentHumidor", defaultValue: "")
}
