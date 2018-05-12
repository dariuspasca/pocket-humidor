//
//  AddHumidorController.swift
//  CigarStack
//
//  Created by Darius Pasca on 30/01/2018.
//  Copyright © 2018 Darius Pasca. All rights reserved.
//

import UIKit
import Eureka

class AddHumidorController: FormViewController {
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    var dismissKeyboard = false
    var navigationAccessoryIsHidden = true

    override func viewDidLoad() {
        super.viewDidLoad()
        view.tintColor =  UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1)
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = 44.0
        
        self.form.keyboardReturnType = KeyboardReturnTypeConfiguration(nextKeyboardType: .send, defaultKeyboardType: .send)
        
        
        navigationAccessoryView = {
            let naview = CustomNavigationAccessoryView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44.0))
            naview.tintColor = UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1)
            naview.doneButton.target = self
            naview.doneButton.action = "navigationDone:"
            return naview
        }()
        
        
        form +++ Section()
            <<< TextRow ("Name") {
               $0.placeholder = NSLocalizedString("Humidor Name", comment: "")
                $0.add(rule: RuleRequired(msg: "required"))
                $0.validationOptions = .validatesOnChange
                }.cellUpdate { cell, row in
                    if !self.navigationAccessoryIsHidden{
                        self.navigationAccessoryIsHidden = true
                    }
                    cell.inputAccessoryView?.isHidden = self.navigationAccessoryIsHidden
                    
                    if row.validate().isEmpty {
                        let trimmedWhitespacesName = row.value!.trimmingCharacters(in: NSCharacterSet.whitespaces)
                        if trimmedWhitespacesName != ""{
                            row.value = trimmedWhitespacesName
                            cell.update()
                            self.saveButton.isEnabled = true
                        }
                    }
                    else{
                        self.saveButton.isEnabled = false
                    }
                    
            }
            +++ Section()
            
            <<< SliderRow("Humidity Level"){
                $0.title = NSLocalizedString("Humidity Level", comment: "")
                $0.displayValueFor = {
                     return String(Int($0!))
                }
                $0.value = 75
                $0.steps = 100
                $0.maximumValue = 100
                $0.minimumValue = 50
                }.cellSetup({ (cell, row) in
                    cell.height = ({return 80})
                })
            +++ Section()
            /*
            <<< TextAreaRow("Notes"){
                $0.placeholder = NSLocalizedString("Notes", comment: "")
                }.cellSetup({ (cell, row) in
                    cell.height = ({return 90})
                }).cellUpdate { cell, row in
                    if self.navigationAccessoryIsHidden{
                        self.navigationAccessoryIsHidden = false
                    }
                    cell.inputAccessoryView?.isHidden = self.navigationAccessoryIsHidden
            }
        */

            +++ MultivaluedSection(multivaluedOptions: [.Reorder, .Insert, .Delete,],
                           header: NSLocalizedString("Dividers", comment: ""),
                           footer: NSLocalizedString("Use dividers to keep your humidor organized.", comment: "")){
                            $0.tag = "trays"
                            $0.addButtonProvider = { section in
                                return ButtonRow(){
                                    $0.title = NSLocalizedString("Add New Divider", comment: "")
                                }.cellUpdate { cell, row in cell.textLabel?.textColor = UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1) }
                            }
                            $0.multivaluedRowToInsertAt = { index in
                                return NameRow() {
                                    $0.placeholder = NSLocalizedString("Divider Name", comment: "")
                                    }.cellSetup { (cell, row) in
                                        cell.textField.autocorrectionType = .yes
                                }
                            }
                            $0 <<< NameRow() {
                                $0.placeholder = NSLocalizedString("Divider Name", comment: "")
                                $0.add(rule: RuleRequired(msg: "required"))
                                $0.validationOptions = .validatesOnChange
                                }.cellSetup { (cell, row) in
                                    cell.textField.autocorrectionType = .yes
                            }
        }
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !dismissKeyboard{
            let row: TextRow! = self.form.rowBy(tag: "Name")
            row.cell.textField.becomeFirstResponder()
            dismissKeyboard = true
        }
        
    }
    
    //MARK: -Keyboard
    
    override func textInputShouldReturn<T>(_ textInput: UITextInput, cell: Cell<T>) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        let formValues = self.form.values()
        let name = formValues["Name"] as? String
        if (CoreDataController.sharedInstance.searchHumidor(name: name!) != nil){
            showAlertButtonTapped(title: NSLocalizedString("Humidor already exists!", comment: ""), message: NSLocalizedString("You can't have multiple humidors with the same name.", comment: ""))
        }
        else{
            let humidorOrderID = CoreDataController.sharedInstance.countHumidors()
            let humidity = formValues["Humidity Level"] as! Float
            let newHumidor = CoreDataController.sharedInstance.addNewHumidor(name: name!, humidityLevel: Int16(humidity),orderID: Int16(humidorOrderID))
            let trays = (self.form.sectionBy(tag: "trays") as! MultivaluedSection).values()
    
            
            switch trays.count{
            case 0:
                _ = CoreDataController.sharedInstance.addNewTray(name: NSLocalizedString("Main Divider", comment: ""), humidor: newHumidor, orderID: 0)
            case 1:
                let trayTrimmed = (trays[0] as! String).trimmingCharacters(in: NSCharacterSet.whitespaces)
                if trayTrimmed == ""{
                    _ = CoreDataController.sharedInstance.addNewTray(name: NSLocalizedString("Main Divider", comment: ""), humidor: newHumidor, orderID: 0)
                }
                else{
                    _ = CoreDataController.sharedInstance.addNewTray(name: trayTrimmed, humidor: newHumidor, orderID: 0)
                }
            case 1...:
                var orderID: Int16 = 0
                let traysUnique = removeDuplicates(array: trays as! [String])
                for tray in traysUnique{
                    let trayTrimmed = tray.trimmingCharacters(in: NSCharacterSet.whitespaces)
                    if trayTrimmed != ""{
                        _ = CoreDataController.sharedInstance.addNewTray(name: trayTrimmed, humidor: newHumidor, orderID: orderID)
                        orderID += 1
                    }
                }
            default: break
            }
            
            if UserSettings.openHumidor.value == true{
                UserSettings.currentHumidor.value = name!
                UserSettings.shouldReloadView.value = true
            }
            cancel(sender)
        }
    }

    //Blocks the popover the scroll the tableview when keyboard is shown
    override func keyboardWillShow(_ notification: Notification) {
        if UIDevice.current.userInterfaceIdiom != .pad{
            super.keyboardWillShow(notification)
        }
    }
    
    override func keyboardWillHide(_ notification: Notification) {
        if UIDevice.current.userInterfaceIdiom != .pad{
           super.keyboardWillHide(notification)
        }
    }
    
    func showAlertButtonTapped(title: String, message: String) {
        
        // create the alert
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        alert.view.tintColor = UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1)
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    func removeDuplicates(array: [String]) ->[String]{
        var set = Set<String>()
        let result = array.filter {
            guard !set.contains($0) else {
                return false
            }
            set.insert($0)
            return true
        }
        return result
    }
    
}
