//
//  AddHumidorController.swift
//  CigarStack
//
//  Created by Darius Pasca on 30/01/2018.
//  Copyright © 2018 Darius Pasca. All rights reserved.
//

import UIKit
import Eureka

protocol NewHumidorDelegate{
    func newHumidorForceReload()
    func dismissedHumidorView()
}

class AddHumidorController: FormViewController {
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    var delegate:NewHumidorDelegate?
    var dismissKeyboard = false
    var navigationAccessoryIsHidden = true
    var humidor: Humidor?
    var isCurrentHumidor = false
    var dividersHaveBeenEdited = false
    var isDeleting = true
    var trayList: [Tray]?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.tintColor =  UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1)
        navigationItem.title = NSLocalizedString("New Box", comment: "")
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = 44.0
        
        self.form.keyboardReturnType = KeyboardReturnTypeConfiguration(nextKeyboardType: .send, defaultKeyboardType: .send)
        
        
        navigationAccessoryView = {
            let naview = CustomNavigationAccessoryView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44.0))
            naview.tintColor = UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1)
            naview.doneButton.target = self
            naview.doneButton.action = #selector(dismisskeyboard)
            return naview
        }()
        
        let deleteAction = SwipeAction(
            style: .destructive,
            title: "Delete",
            handler: { (action, row, completionHandler) in
                if let rowIndex = row.indexPath?.row {
                    self.form.last!.remove(at: rowIndex)
                    completionHandler?(true)
                }
        })
        
        if humidor != nil {
            trayList = (humidor!.trays?.allObjects as! [Tray]).sorted(by: { $0.orderID < $1.orderID })
            if UserSettings.currentHumidor.value == humidor!.name {
                isCurrentHumidor = true
            }
        }
        
        
        
        form +++ Section()
            <<< TextRow ("Name") {
               $0.placeholder = NSLocalizedString("Humidor Name", comment: "")
                $0.add(rule: RuleRequired(msg: "required"))
                $0.value = humidor?.name
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
                            
                            /* Edit Mode
                             Enables save button only if value has been changed
                             */
                            if self.humidor != nil {
                                if self.humidor!.name! != row.value! {
                                    self.saveButton.isEnabled = true
                                }
                                else{
                                    //Checks if the humidity field has been modified. If not, disables save button, otherwise not
                                    let humidityRow = self.form.rowBy(tag: "Humidity Level") as! SliderRow
                                    if (Int16(humidityRow.value!) == self.humidor!.humidity) && self.dividersHaveBeenEdited == false{
                                        self.saveButton.isEnabled = false
                                    }
                                    else{
                                        self.saveButton.isEnabled = true
                                    }
                                }
                            }
                            else{
                                self.saveButton.isEnabled = true
                            }
                        }
                    }
                    else{
                        self.saveButton.isEnabled = false
                    }
                    
            }
            +++ Section(footer: NSLocalizedString("Too low or too high levels of humidty might affect your items.", comment: ""))
            
            <<< SliderRow("Humidity Level"){
                $0.title = NSLocalizedString("Humidity Level", comment: "")
                $0.displayValueFor = {
                     return String(Int($0!))
                }
                if humidor != nil{
                    $0.value = Float((humidor?.humidity)!)
                }
                else{
                    $0.value =  75
                }
                $0.steps = 100
                
                $0.maximumValue = 100
                $0.minimumValue = 50
                }.cellSetup({ (cell, row) in
                    cell.height = ({return 80})
                }).cellUpdate{ cell, row in
                    /* Edit Mode
                      Enables save button only if value has been changed
                     */
                    if self.humidor != nil {
                        if self.humidor!.humidity != Int16(row.value!){
                            self.saveButton.isEnabled = true
                        }
                        else{
                            //Checks if the name field has been modified. If not, disables save button, otherwise not
                            let nameRow = self.form.rowBy(tag: "Name") as! TextRow
                            if nameRow.value! == self.humidor!.name! {
                                self.saveButton.isEnabled = false
                            }
                        }
                    }
                }
            
            +++ Section()

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
                                    $0.add(rule: RuleRequired(msg: "required"))
                                    $0.validationOptions = .validatesOnChange
                                    $0.trailingSwipe.actions.append(deleteAction)
                                    }.cellSetup { (cell, row) in
                                        cell.textField.autocorrectionType = .yes
                                }.onCellHighlightChanged({ (cell, row) in
                                    if row.isHighlighted == false {
                                        if self.humidor != nil {
                                            if row.value != nil {
                                                let name = row.value?.trimmingCharacters(in: NSCharacterSet.whitespaces)
                                                if name != "" {
                                                    let found = CoreDataController.sharedInstance.searchTray(humidor: self.humidor!, searchTray: name!)
                                                    //Shows alert and cancels text
                                                    if found != nil {
                                                        self.showAlertButtonTapped(title: "", message: NSLocalizedString("There is already a divisor with same name.", comment: ""))
                                                        row.value! = ""
                                                        
                                                    }
                                                    else{
                                                        let newTray = CoreDataController.sharedInstance.addNewTray(name: name!, humidor: self.humidor!, orderID: 0, save: false)
                                                        self.trayList?.append(newTray)
                                                        self.saveButton.isEnabled = true
                                                        self.dividersHaveBeenEdited = true
                                                        
                                                    }
                                                }
                                            }
                                        }

                                    }
                                })
                            }
                             if humidor == nil{
                                $0 <<< NameRow() {
                                $0.placeholder = NSLocalizedString("Divider Name", comment: "")
                                $0.add(rule: RuleRequired(msg: "required"))
                                $0.validationOptions = .validatesOnChange
                                }.cellSetup { (cell, row) in
                                    cell.textField.autocorrectionType = .yes
                                }
                            }
                }
        
        

        if humidor != nil{
            var section = form.sectionBy(tag: "trays")
            for tray in trayList!.reversed(){
                let row =  NameRow() {
                    $0.value = tray.name!
                     $0.trailingSwipe.actions.append(deleteAction)
                    }.cellSetup { (cell, row) in
                        cell.textField.autocorrectionType = .yes
                    }.onCellHighlightChanged({ (cell, row) in
                        if row.isHighlighted == false {
            
                        let name = row.value?.trimmingCharacters(in: NSCharacterSet.whitespaces)
                            if name != "" && name != tray.name!{
                                let found = CoreDataController.sharedInstance.searchTray(humidor: self.humidor!, searchTray: name!)
                                //Shows alert and cancels text
                                if found != nil {
                                    self.showAlertButtonTapped(title: "", message: NSLocalizedString("There is already a divisor with same name.", comment: ""))
                                    row.value! = tray.name!
                                    
                                }
                                else{
                                    if name != tray.name! {
                                        tray.name = name!
                                        self.saveButton.isEnabled = true
                                        self.dividersHaveBeenEdited = true
                                    }
                                    
                                }
                            }

                        }
                    })
                section?.insert(row, at: 0)
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
   
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath){
        self.dismisskeyboard()
        if self.humidor != nil {
            self.saveButton.isEnabled = true
            self.dividersHaveBeenEdited = true
            let section = form.last! as! MultivaluedSection
            let rowToMove = section[sourceIndexPath.row] as? NameRow
            let rowDestination = section[sourceIndexPath.row] as? NameRow
            if rowToMove?.value != nil && rowDestination?.value != nil {
                let rowToMoveValue = rowToMove?.value?.trimmingCharacters(in: NSCharacterSet.whitespaces)
                let rowDestinationValue = rowDestination?.value?.trimmingCharacters(in: NSCharacterSet.whitespaces)
                if rowToMoveValue! != "" && rowDestinationValue != "" {
                    trayList!.rearrange(from: sourceIndexPath.row, to: destinationIndexPath.row)
                    for (index, tray) in trayList!.enumerated() {
                        tray.orderID = Int16(index)
                    }
                }
            }
            
            self.isDeleting = false
        }
    }
    
    override func rowsHaveBeenAdded(_ rows: [BaseRow], at indexes: [IndexPath]) {
        super.rowsHaveBeenAdded(rows, at: indexes)
    }
    
    
    override func rowsHaveBeenRemoved(_ rows: [BaseRow], at indexes: [IndexPath]) {
        if self.isDeleting == true {
            self.dismisskeyboard()
            if humidor != nil{
                let row = rows[0] as! NameRow
                if row.value != nil {
                    let name = row.value?.trimmingCharacters(in: NSCharacterSet.whitespaces)
                    if name != "" {
                        let tray = CoreDataController.sharedInstance.searchTray(humidor: self.humidor!, searchTray: name!)
                        if name != nil {
                            CoreDataController.sharedInstance.deleteTray(tray: tray!, save: false)
                        }
                    }
                }

                self.saveButton.isEnabled = true
                self.dividersHaveBeenEdited = true
            }
    

            self.tableView.beginUpdates()
            self.tableView.deleteRows(at: indexes, with: .right)
            self.tableView.endUpdates()

        }

        self.isDeleting = true
    }
 
    
    @objc func dismisskeyboard() {
        view.endEditing(true)
    }
    
    //MARK: -Keyboard
    
    override func textInputShouldReturn<T>(_ textInput: UITextInput, cell: Cell<T>) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
        if humidor != nil {
            CoreDataController.sharedInstance.discardContext()
        }
        self.view.window!.rootViewController?.dismiss(animated: true, completion: nil)
    }
    

    
    @IBAction func save(_ sender: UIBarButtonItem) {
        let formValues = self.form.values()
        let name = formValues["Name"] as? String
        let humidity = formValues["Humidity Level"] as! Float
        if humidor != nil {
            if humidor!.name! != name! && CoreDataController.sharedInstance.searchHumidor(name: name!) != nil  {
                    showAlertButtonTapped(title: NSLocalizedString("Humidor already exists!", comment: ""), message: NSLocalizedString("You can't have multiple humidors with the same name.", comment: ""))
            }
            else{
                /* Updates eventual humidor info changes */
                humidor!.name! = name!
                if isCurrentHumidor{
                    UserSettings.currentHumidor.value = humidor!.name!
                }
                humidor!.humidity = Int16(humidity)
                
                /* Add new trays and assign new orderID */
                
                let trays = (self.form.sectionBy(tag: "trays") as! MultivaluedSection).values()
                

                if trays.count == 0 {
                    _ = CoreDataController.sharedInstance.addNewTray(name: NSLocalizedString("Main Divider", comment: ""), humidor: humidor!, orderID: 0, save: false)
                }
               
                
                UserSettings.shouldReloadView.value = true
                
                UserEngagement.logEvent(.editHumidor)
                CoreDataController.sharedInstance.saveContext()
                if UIDevice.current.userInterfaceIdiom == .pad{
                    delegate?.newHumidorForceReload()
                }
                self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
                delegate?.dismissedHumidorView()
            }
        }
        else{
            if (CoreDataController.sharedInstance.searchHumidor(name: name!) != nil){
                showAlertButtonTapped(title: NSLocalizedString("Humidor already exists!", comment: ""), message: NSLocalizedString("You can't have multiple humidors with the same name.", comment: ""))
            }
            else{
                UserEngagement.logEvent(.addHumidor)
                let humidorOrderID = CoreDataController.sharedInstance.countHumidors()
                let newHumidor = CoreDataController.sharedInstance.addNewHumidor(name: name!, humidityLevel: Int16(humidity),orderID: Int16(humidorOrderID))
                let trays = (self.form.sectionBy(tag: "trays") as! MultivaluedSection).values()
                
                switch trays.count{
                case 0:
                    _ = CoreDataController.sharedInstance.addNewTray(name: NSLocalizedString("Main Divider", comment: ""), humidor: newHumidor, orderID: 0, save: true)
                case 1:
                    let trayTrimmed = (trays[0] as! String).trimmingCharacters(in: NSCharacterSet.whitespaces)
                    if trayTrimmed == ""{
                        _ = CoreDataController.sharedInstance.addNewTray(name: NSLocalizedString("Main Divider", comment: ""), humidor: newHumidor, orderID: 0, save: true)
                    }
                    else{
                        _ = CoreDataController.sharedInstance.addNewTray(name: trayTrimmed, humidor: newHumidor, orderID: 0, save: true)
                    }
                case 1...:
                    var orderID: Int16 = 0
                    let traysUnique = removeDuplicates(array: trays as! [String])
                    for tray in traysUnique{
                        let trayTrimmed = tray.trimmingCharacters(in: NSCharacterSet.whitespaces)
                        if trayTrimmed != ""{
                            _ = CoreDataController.sharedInstance.addNewTray(name: trayTrimmed, humidor: newHumidor, orderID: orderID, save: true)
                            orderID += 1
                        }
                    }
                default: break
                }
                
                if UserSettings.openHumidor.value == true{
                    UserSettings.currentHumidor.value = name!
                    UserSettings.shouldReloadView.value = true
                }
                dismiss(animated: true, completion: nil)
                if UIDevice.current.userInterfaceIdiom == .pad{
                    delegate?.newHumidorForceReload()
                }
                delegate?.dismissedHumidorView()
            }
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

extension Array {
    mutating func rearrange(from: Int, to: Int) {
        insert(remove(at: from), at: to)
    }
}


