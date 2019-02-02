//
//  SettingsViewController.swift
//  CigarStack
//
//  Created by Darius Pasca on 05/03/2018.
//  Copyright © 2018 Darius Pasca. All rights reserved.
//

import UIKit
import MessageUI

class SettingsViewController: UITableViewController {
    
    static let feedbackEmailAddress = "contact@pocketstack.app"
    static let appStoreAddress = "1450368969"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Remove extra empty cells in TableView
        self.tableView.tableFooterView = UIView()
        
        DispatchQueue.main.async {
            // isSplit does not work correctly before the view is loaded; run this later
            if self.splitViewController!.isSplit {
                self.tableView.selectRow(at: IndexPath(row: 0, section: 1), animated: false, scrollPosition: .none)
            }
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 && indexPath.row == 1 {
            contact()
        }
        else if indexPath.section == 2 && indexPath.row == 0 {
            UIApplication.shared.open(URL(string: "itms-apps://itunes.apple.com/app/\(SettingsViewController.appStoreAddress)?action=write-review")!, options: [:])
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func contact() {
        let canSendEmail = MFMailComposeViewController.canSendMail()
        var optionalMessage = ""
        if !canSendEmail{
            optionalMessage = NSLocalizedString("at", comment: "") + " " + SettingsViewController.feedbackEmailAddress
        }
        let msg = NSLocalizedString("If you have any questions, comments or suggestions, please email me", comment: "") + optionalMessage + "." + NSLocalizedString("I'll do my best to respond.", comment: "")
        
        var alert: UIAlertController?
        if canSendEmail{
            
            alert = UIAlertController(title: NSLocalizedString("Send Feedback ?", comment: "") , message: msg, preferredStyle: .actionSheet)
            alert!.addAction(UIAlertAction(title: NSLocalizedString("Send e-mail", comment: ""), style: .default){ [unowned self] _ in
                self.presentMailComposeWindow()
            })
            alert!.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))
        }
        else{
            alert = UIAlertController(title: NSLocalizedString("Send Feedback ?", comment: "") , message: msg, preferredStyle: .alert)
            alert!.addAction(UIAlertAction(title: "OK", style: .default))
            alert!.view.tintColor = UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1)
        }

        present(alert!, animated: true)
    }
    
    
    
    func presentMailComposeWindow() {
        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = self
        mailComposer.setToRecipients(["PocketStack Developer <\(SettingsViewController.feedbackEmailAddress)>"])
        mailComposer.setSubject("PocketStack Feedback")
        let messageBody = """
        
        
        
        
        
        Extra Info:
        App Version: \(UserEngagement.appVersion) (\(UserEngagement.appBuildNumber))
        iOS Version: \(UIDevice.current.systemVersion)
        Device: \(UIDevice.current.model)
        """
        mailComposer.setMessageBody(messageBody, isHTML: false)
        present(mailComposer, animated: true)
    }
    
    //MARK -Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "settingsData" {
            let url = sender as? URL
            let nav = segue.destination as! UINavigationController
            let data = nav.viewControllers.first as! DataViewController
            data.importUrl = url
        }
    }
}

extension SettingsViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true)
    }
}
