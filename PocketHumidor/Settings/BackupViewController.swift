//
//  BackupViewController.swift
//  PocketHumidor
//
//  Created by Darius Pasca on 25/03/2019.
//  Copyright © 2019 Darius Pasca. All rights reserved.
//

import UIKit
import Eureka
import SVProgressHUD

class BackupViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func automaticBackupSwitch(_ sender: UISwitch) {
        UserSettings.iCloudAutoBackup.value = sender.isOn
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func backupNow(_ sender: UIButton) {
        SVProgressHUD.show(withStatus: NSLocalizedString("Generating...", comment: ""))
        let CloudManager = CloudDataManager()
        CloudManager.runBackup(completion: { (flag) in
            if flag{
                SVProgressHUD.dismiss(withDelay: 1, completion: {SVProgressHUD.showSuccess(withStatus: "Completed")})
            }
            else{
                SVProgressHUD.dismiss(withDelay: 1, completion: {SVProgressHUD.showError(withStatus: "Failed")})
            }
        })
        

        
    }
    
}


class dataViewController: FormViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        form +++ Section()
            +++ Section(header: NSLocalizedString("To move items between devices, create an export of your items below, and send or share the file with your other device. On the other device, Import from the file to copy the items.", comment: ""), footer: NSLocalizedString("Export to a CSV file. CSV files can be opened by most spreadsheet software.", comment: ""))
            <<< ButtonRow ("Export") {
                $0.title = NSLocalizedString("Export", comment: "")
                $0.onCellSelection(self.exportData)
            }
            
            +++ Section(header: "", footer: NSLocalizedString("Import from a CSV file.", comment: ""))
            <<< ButtonRow ("Import") {
                $0.title = NSLocalizedString("Export", comment: "")
                $0.onCellSelection(self.exportData)
            }
            +++ Section(header: NSLocalizedString("Note: Personal generated CSV files are not yet supported.", comment: ""), footer: NSLocalizedString("This will delete all items and stacks from this device. This is not reversible!", comment: ""))
            <<< ButtonRow ("Delete") {
                $0.title = NSLocalizedString("Delete All", comment: "")
                $0.onCellSelection(self.exportData)
            }
    }
    
    
    func exportData(cell: ButtonCellOf<String>, row: ButtonRow){
        print("export")
    }
    
    func importData(cell: ButtonCellOf<String>, row: ButtonRow){
        print("import")
    }
}
