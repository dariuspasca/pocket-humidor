//
//  AboutViewController.swift
//  CigarStack
//
//  Created by Darius Pasca on 08/03/2018.
//  Copyright © 2018 Darius Pasca. All rights reserved.
//

import UIKit
import Eureka

class AboutViewController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        form +++ Section(NSLocalizedString("Information", comment: ""))
            <<< LabelRow(){
                $0.title = NSLocalizedString("Version", comment: "")
                $0.value = "\(UserEngagement.appVersion)"
            }
            <<< LabelRow(){
                $0.title = NSLocalizedString("Status", comment: "")
                if UserDefaults.standard.bool(forKey: "CigarStackPro") == true {
                    $0.value = NSLocalizedString("Unlimited", comment: "")
                }
                else{
                    $0.value = NSLocalizedString("Limited", comment: "")
                }
        }
        
            +++ Section()
            <<< LabelRow (NSLocalizedString("Rate", comment: "")) {
                $0.title = $0.tag
                $0.cell.accessoryType = .disclosureIndicator
                }
                .onCellSelection { cell, row in
                    UIApplication.shared.open(URL(string: "itms-apps://\(SettingsViewController.appStoreAddress)?action=write-review")!, options: [:])
            }
                <<< LabelRow (NSLocalizedString("Attributions", comment: "")) {
                    $0.title = $0.tag
                    $0.cell.accessoryType = .disclosureIndicator
                    }
                    .onCellSelection { cell, row in
                        self.performSegue(withIdentifier: "attributionsSegue", sender: self)
                }

    }
}

class AttributionsTableViewcontroller: UITableViewController {
 
    var licenseKeys: [String]!
    var licenseValues: [String]!
    
    
    override func viewDidLoad() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140
        fetchLicenses()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return licenseKeys.count
    }
    
    func fetchLicenses(){
        if let url = Bundle.main.url(forResource:"AttributesLicense", withExtension: "plist"){
            let licensesDictionary = NSDictionary(contentsOf: url)
            licenseKeys = licensesDictionary!["Keys"] as! Array<String>
            licenseValues = licensesDictionary!["Values"] as! Array<String>
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "attributesCell") as! AttributionsCell
       cell.title.text = licenseKeys[indexPath.row]
        cell.license.text = licenseValues[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
   
    
}

class AttributionsCell: UITableViewCell{
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var license: UILabel!
    
}
