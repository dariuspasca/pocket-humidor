//
//  DataViewController.swift
//  CigarStack
//
//  Created by Darius Pasca on 08/03/2018.
//  Copyright © 2018 Darius Pasca. All rights reserved.
//

import UIKit
import Eureka

class DataViewController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupFormView()
    }

    func setupFormView(){
        form +++ Section(header: NSLocalizedString("Data Sync", comment: ""), footer: NSLocalizedString("Automatically upload and store your data in iCloud to be accessible from all your devices.", comment: ""))
            <<< SwitchRow("iCloud Drive"){
                $0.title = $0.tag
                $0.value = UserSettings.iCloud.value
                }
                .onChange {
                    UserSettings.iCloud.value = $0.value!
            }
            
            +++ Section(header: NSLocalizedString("Analytics", comment: ""), footer: NSLocalizedString("Anonymous crash reports and usage statistics can be reported to help improve CigarStack.", comment: ""))
            <<< SwitchRow(NSLocalizedString("Send Crash Reports", comment: "")){
                $0.title = $0.tag
                $0.value = UserSettings.sendCrashReports.value
                }
                .onChange {
                    UserSettings.sendCrashReports.value = $0.value!
            }
            <<< SwitchRow(NSLocalizedString("Send Analytics", comment: "")){
                $0.title = $0.tag
                $0.value = UserSettings.sendAnalytics.value
                }
                .onChange {
                    UserSettings.sendAnalytics.value = $0.value!
        }
    }

}
