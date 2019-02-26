//
//  PrivacyViewController.swift
//  CigarStack
//
//  Created by Darius Pasca on 08/03/2018.
//  Copyright © 2018 Darius Pasca. All rights reserved.
//

import UIKit
import Eureka

class PrivacyViewController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupFormView()
    }

    func setupFormView(){
        
           form +++ Section(header: NSLocalizedString("Analytics", comment: ""), footer: NSLocalizedString("Anonymous crash reports and usage statistics can be reported to help improve PocketHumidor.", comment: ""))
            <<< SwitchRow(NSLocalizedString("Share Crash Reports", comment: "")){
                $0.title = $0.tag
                $0.onChange { [unowned self] in
                    self.crashReportsSwitchChanged($0)
                }
                $0.value = UserSettings.shareCrashReports.value
                }
            <<< SwitchRow(NSLocalizedString("Share Analytics", comment: "")){
                $0.title = $0.tag
                $0.onChange { [unowned self] in
                    self.analyticsSwitchChanged($0)
                }
                $0.value = UserSettings.shareAnalytics.value
                }
    }
    
    func crashReportsSwitchChanged(_ sender: _SwitchRow) {
        guard let switchValue = sender.value else { return }
        if switchValue {
            UserEngagement.logEvent(.enableCrashReports)
            UserSettings.shareCrashReports.value = true
            
        } else {

            persuadeToKeepOn(title: NSLocalizedString("Turn Off Crash Reports?", comment: ""), message: NSLocalizedString("Anonymous crash reports are \n essential to fix the bugs. \n This never includes any information about your items. Are you sure \n you want to turn this off?", comment: "")) { result in
                    if result {
                        sender.value = true
                        sender.reload()
                    } else {
                        UserEngagement.logEvent(.disableCrashReports)
                        UserSettings.shareCrashReports.value = false
                    }
            }
        }
    }
    
    func analyticsSwitchChanged(_ sender: _SwitchRow) {
        guard let switchValue = sender.value else { return }
        if switchValue {
            UserEngagement.logEvent(.enableAnalytics)
            UserSettings.shareAnalytics.value = true
            
        } else {
            // If this is being turned off, let's try to persuade them to turn it back on
            persuadeToKeepOn(title: NSLocalizedString("Turn Off Analytics?", comment: ""), message: NSLocalizedString("Anonymous usage statistics \n help prioritise development. \n This never includes any information about your items. Are you sure \n you want to turn this off?", comment: "")) { result in
                    if result {
                        sender.value = true
                        sender.reload()
                    } else {
                        UserEngagement.logEvent(.disableAnalytics)
                        UserSettings.shareAnalytics.value = false
                    }
            }
        }
    }

    func persuadeToKeepOn(title: String, message: String, completion: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Turn Off", comment: ""), style: .destructive) { _ in
            completion(false)
        })
        alert.addAction(UIAlertAction(title: NSLocalizedString("Leave On", comment: ""), style: .default) { _ in
            completion(true)
        })
        present(alert, animated: true)
    }
}
