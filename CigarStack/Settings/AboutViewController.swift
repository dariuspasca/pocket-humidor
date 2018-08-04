//
//  AboutViewController.swift
//  CigarStack
//
//  Created by Darius Pasca on 08/03/2018.
//  Copyright © 2018 Darius Pasca. All rights reserved.
//

import UIKit
import FlagKit

class AboutViewController: UIViewController {
    
    @IBOutlet weak var version: UILabel!
    @IBOutlet weak var premiumStatus: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UserSettings.isPremium.value == true {
            version.text = "Premium"
        }
        else{
            version.text = NSLocalizedString("Not Premium", comment: "")
        }
        
        version.text = "CigarStack " + UserEngagement.appVersion
        
       
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
