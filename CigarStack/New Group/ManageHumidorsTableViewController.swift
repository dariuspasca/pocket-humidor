//
//  ManageHumidorsTableViewController.swift
//  CigarStack
//
//  Created by Darius Pasca on 27/04/2018.
//  Copyright © 2018 Darius Pasca. All rights reserved.
//

import UIKit
import CoreData

class ManageHumidorsTableViewController: UITableViewController {

    var cancelButton: UIBarButtonItem!
    var deleteButton: UIBarButtonItem!
    // Should use optional
    var selectedItems = [String]()
    var humidorsList = [String]()
    var rearrange = false
    var editMode = false
    
    var humidorDetail: Humidor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("Your Humidors", comment: "")
        cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        deleteButton = UIBarButtonItem(title: NSLocalizedString("Delete", comment: ""),style: .plain, target: self, action: #selector(deleteHumidors))
        self.navigationItem.leftBarButtonItem = cancelButton
        fetchHumidorsList()
        self.tableView.estimatedRowHeight = 65.0
        self.tableView.isEditing = editMode
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.tableView.tableFooterView = UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return humidorsList.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "humidorCell") as! SideMenuHumidorCell
        cell.humidorName.text = humidorsList[indexPath.row]
        return cell
    }


    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.tableView.isEditing{
            if selectedItems.isEmpty{
                navigationItem.leftBarButtonItem?.isEnabled = true
                selectedItems.append(humidorsList[indexPath.row])
            }
            else{
               selectedItems.append(humidorsList[indexPath.row])
            }
        }
        else{
            humidorDetail = CoreDataController.sharedInstance.searchHumidor(name: humidorsList[indexPath.row])
            self.performSegue(withIdentifier: "humidorDetail", sender: self)
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if self.tableView.isEditing{
            if let index = selectedItems.index(of: humidorsList[indexPath.row]) {
                selectedItems.remove(at: index)
                if selectedItems.isEmpty{
                    navigationItem.leftBarButtonItem?.isEnabled = false
                }
            }
        }
    }
    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        humidorsList.swapAt(fromIndexPath.row, to.row)
        rearrange = true
    }
    

    
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    


    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "humidorDetail"{
            let destinationVC = segue.destination as! HumidorDetailViewController
            destinationVC.humidor = humidorDetail!
        }
    }
    
    // MARK: - CoreData
    
    func fetchHumidorsList(){
        let humidors = CoreDataController.sharedInstance.fetchHumidors()
        if humidors != nil {
            for humidor in humidors! {
                humidorsList.append(humidor.name!)
            }
        }
    }
    
    func deleteHumidor(name: String){
        let humidorToDelete = CoreDataController.sharedInstance.searchHumidor(name: name)
        CoreDataController.sharedInstance.deleteHumidor(humidor: humidorToDelete!)
    }

    @objc func cancel(sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func deleteHumidors(sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "", message: NSLocalizedString("Are you sure you want to continue? All items will be permanently removed from selected humidors.", comment: ""), preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.cancel, handler: nil));
        alert.addAction(UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: UIAlertActionStyle.destructive, handler: {
            alertAction in
            for item in self.selectedItems{
                if let index = self.humidorsList.index(of: item) {
                    self.deleteHumidor(name: self.humidorsList[index])
                    self.humidorsList.remove(at: index)
                    self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
                    }
            }
            self.selectedItems.removeAll()

            if self.humidorsList.isEmpty{
                UserSettings.currentHumidor.value = ""
                UserSettings.shouldReloadView.value = true
                self.dismiss(animated: true, completion: nil)
            }
            else{
                if !self.humidorsList.contains(UserSettings.currentHumidor.value){
                    UserSettings.currentHumidor.value = self.humidorsList[0]
                    UserSettings.shouldReloadView.value = true
                }
                
                //Reasigns orderID to humidors
                for (index,item) in self.humidorsList.enumerated(){
                    let humidor = CoreDataController.sharedInstance.searchHumidor(name: item)
                    CoreDataController.sharedInstance.setHumidorOrderID(humidor: humidor!, orderID: Int16(index))
                }
            }
            self.setEditing(false, animated: true)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        editMode = !editMode
        self.tableView.setEditing(editMode, animated: true)
        if editMode{
            navigationItem.leftBarButtonItem = deleteButton
            navigationItem.rightBarButtonItem?.title = NSLocalizedString("Done", comment: "")
            navigationItem.leftBarButtonItem?.isEnabled = false
        }
        else{
            navigationItem.leftBarButtonItem = cancelButton
            navigationItem.rightBarButtonItem?.title = NSLocalizedString("Edit", comment: "")
            navigationItem.leftBarButtonItem?.isEnabled = true
            selectedItems.removeAll()
            if rearrange{
                rearrange = false
                for (index,item) in humidorsList.enumerated(){
                    let humidor = CoreDataController.sharedInstance.searchHumidor(name: item)
                    CoreDataController.sharedInstance.setHumidorOrderID(humidor: humidor!, orderID: Int16(index))
                }
            }
        }
    }
}
