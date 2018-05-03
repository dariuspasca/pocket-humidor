//
//  SideMenuUIViewController.swift
//  CigarStack
//
//  Created by Darius Pasca on 03/03/2018.
//  Copyright © 2018 Darius Pasca. All rights reserved.
//

import UIKit
import CoreData

class SideMenuUIViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var humidorsList = [String]()

    @IBOutlet weak var humidorsTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        updateHumidorsList()
        //Remove extra empty cells in TableView
        self.humidorsTable.estimatedRowHeight = 50.0
        self.humidorsTable.tableFooterView = UIView()
        
        self.navigationItem.title = NSLocalizedString("Your Humidors", comment: "")
    }

    // MARK: - Table view data source

     func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return humidorsList.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UserSettings.currentHumidor.value = humidorsList[indexPath.row]
        UserSettings.shouldReloadView.value = true
        DispatchQueue.main.async
            {
                self.dismiss(animated: true, completion: nil)
        }
    }

     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "humidorCell") as! SideMenuHumidorCell
        cell.humidorName.text = humidorsList[indexPath.row]
        if indexPath.row == 0 {
            cell.humidorName.textColor = UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1)
            cell.humidorName.font = UIFont.boldSystemFont(ofSize: 18.0)
        }
        return cell
    }
    
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    /* There is only one segue, no need to check identifier */
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
            if humidorsList.isEmpty{
                return false
            }
            else{
                return true
            }
    }
    
    // MARK: - CoreData
    
    func updateHumidorsList(){
        let humidors = CoreDataController.sharedInstance.fetchHumidors()
        if !humidors.isEmpty {
            /* Clears array possible previous data */
            humidorsList.removeAll()
            for humidor in humidors {
                if humidor.name! == UserSettings.currentHumidor.value{
                    humidorsList.insert(humidor.name!, at: 0)
                }
                else{
                    humidorsList.append(humidor.name!)
                }
            }
        }
    }
    
}



class SideMenuHumidorCell: UITableViewCell{
    @IBOutlet weak var humidorName: UILabel!
    
}
