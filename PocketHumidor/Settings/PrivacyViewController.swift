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
        
            /*+++ Section(header: NSLocalizedString("Data Sync", comment: ""), footer: NSLocalizedString("Automatically upload and store your data in iCloud to be accessible from all your devices.", comment: ""))
            <<< SwitchRow("iCloud Drive"){
                $0.title = $0.tag
                $0.value = UserSettings.iCloud.value
                }
                .onChange {
                    UserSettings.iCloud.value = $0.value!
            }
            */
           form +++ Section(header: NSLocalizedString("Analytics", comment: ""), footer: NSLocalizedString("Anonymous crash reports and usage statistics can be reported to help improve PocketHumidor.", comment: ""))
            <<< SwitchRow(NSLocalizedString("Share Analytics", comment: "")){
                $0.title = $0.tag
                $0.value = UserSettings.shareAnalytics.value
                }
                .onChange {
                    UserSettings.shareAnalytics.value = $0.value!
            }
    }

}
