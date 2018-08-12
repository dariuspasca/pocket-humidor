//
//  AddCigarController.swift
//  CigarStack
//
//  Created by Darius Pasca on 18/01/2018.
//  Copyright © 2018 Darius Pasca. All rights reserved.
//

import UIKit
import Eureka
import FlagKit

protocol AddCigarDelegate{
    func addCigarForceReload()
    func cigarTriggerReview()
}

class AddCigarController: FormViewController, SelectCountryDelegate {
    
    var sizes = ["Cigarillo" , "Small Panetela" , "Slim Panetela" , "Short Panetela" , "Pantetela" , "Long Panetela" , "Toscanello" , "Toscano",
                 "Petit Corona" , "Corona", "Long Corona" , "Lonsdale" , "Corona Extra" , "Grand Corona" , "Double Corona" ,
                 "Giant Corona" , "Churchill" , "Petit Robusto" , "Robusto" , "Robusto Extra", "Double Robusto" , "Giant Robusto" , "Toro" ,
                 "Culebra" , "Oetut Pyramid" , "Pyramid" , "Double Pyramid" , "Petit Perfecto" , "Perfecto" , "Double Perfecto" , "Giant Perfecto" ]
    
    var delegate:AddCigarDelegate?
    var cigarToEdit: Cigar?
    @IBOutlet weak var saveButton: UIBarButtonItem!
    var dismissKeyboard = false
    var navigationAccessoryIsHidden = true
    
    var selectedCountryCode:String!
    var humidor: Humidor!
    var humidorTrays: [Tray]!
    var changesStatus: [Bool]?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = NSLocalizedString("Add Cigar", comment: "")
        //Default Country
        selectedCountryCode = "CU"
        humidor = CoreDataController.sharedInstance.searchHumidor(name: UserSettings.currentHumidor.value)
        
        if cigarToEdit != nil {
            changesStatus = Array(repeating: false, count: 11)
            selectedCountryCode = cigarToEdit?.origin!
            valuateSaveButonStatus()
        }
        
        self.form.keyboardReturnType = KeyboardReturnTypeConfiguration(nextKeyboardType: .send, defaultKeyboardType: .send)
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = 44.0
      
        navigationAccessoryView = {
            let naview = CustomNavigationAccessoryView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44.0))
            naview.tintColor = UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1)
            naview.doneButton.target = self
            naview.doneButton.action = #selector(dismisskeyboard)
            return naview
        }()
 
        form +++ Section()
            <<< TextRow ("Name") {
                $0.placeholder = NSLocalizedString("Cigar Name", comment: "")
                $0.value = cigarToEdit?.name! ?? nil
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
                            if self.cigarToEdit != nil{
                                if self.cigarToEdit!.name != row.value!{
                                    self.changesStatus![0] = true
                                }
                                else{
                                    self.changesStatus![0] = false
                                }
                                self.valuateSaveButonStatus()
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
            
            <<< PushRow<String>("Size"){
                $0.title = NSLocalizedString("Size", comment: "")
                $0.value = cigarToEdit?.size ?? sizes.first
                $0.selectorTitle = $0.tag
                $0.options = sizes
                }.onPresent{ from, to in
                    to.selectableRowCellUpdate = { cell, _ in cell.tintColor = UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1)}
                    to.enableDeselection = false
            }.cellUpdate { cell, row in
                if self.cigarToEdit != nil {
                    if self.cigarToEdit?.size != row.value! {
                        self.changesStatus![1] = true
                    }
                    else{
                        self.changesStatus![1] = false
                    }
                    self.valuateSaveButonStatus()
                }
            }
            <<< LabelRow ("Country of origin") {
                $0.title = NSLocalizedString("Country of origin", comment: "")
                $0.value =  Locale.current.localizedString(forRegionCode: selectedCountryCode)
                $0.cell.accessoryType = .disclosureIndicator
                }
                .onCellSelection { cell, row in
                    self.performSegue(withIdentifier: "countrySelect", sender: self)
                }.cellUpdate { cell, row in
                    if self.cigarToEdit != nil {
                        if self.cigarToEdit?.origin != self.selectedCountryCode {
                            self.changesStatus![2] = true
                        }
                        else{
                            self.changesStatus![2] = false
                        }
                        self.valuateSaveButonStatus()
                    }
            }

            
            +++ Section()
            <<< IntRow("Quantity"){
                $0.title = NSLocalizedString("Quantity", comment: "")
                var quantity = 1
                if cigarToEdit != nil{
                    quantity = Int(cigarToEdit!.quantity)
                }
                $0.value =  quantity
                $0.cell.inputAccessoryView?.isHidden = false
        }.cellUpdate { cell, row in
            if self.navigationAccessoryIsHidden{
                self.navigationAccessoryIsHidden = false
                }
                    cell.inputAccessoryView?.isHidden = self.navigationAccessoryIsHidden
            
                if row.value! == 0 {
                    row.value = 1
                    cell.update()
                }
        
                if self.cigarToEdit != nil {
                    if (self.cigarToEdit?.quantity)! != Int32(row.value!) {
                        self.changesStatus![3] = true
                    }
                    else{
                        self.changesStatus![3] = false
                    }
                    self.valuateSaveButonStatus()
                }

            }
            
            <<< DecimalRow("Price"){
                $0.useFormatterDuringInput = true
                $0.title = NSLocalizedString("Total Price", comment: "")
                let formatter = CurrencyFormatter()
                formatter.locale = NSLocale.current
                formatter.numberStyle = NumberFormatter.Style.currency
                $0.formatter = formatter
                $0.value = cigarToEdit?.price ?? 0
                }.cellUpdate { cell, row in
                    if self.navigationAccessoryIsHidden{
                        self.navigationAccessoryIsHidden = false
                    }
                    cell.inputAccessoryView?.isHidden = self.navigationAccessoryIsHidden

                    if self.cigarToEdit != nil {
                        if self.cigarToEdit?.price != row.value! {
                            self.changesStatus![4] = true
                        }
                        else{
                            self.changesStatus![4] = false
                        }
                    self.valuateSaveButonStatus()
                    }

                }
        
            
        
        
            +++ Section()
            <<< TextRow("From"){
                $0.title = NSLocalizedString("From", comment: "")
                $0.placeholder = NSLocalizedString("Shop Name", comment: "")
                $0.value = cigarToEdit?.from ?? nil
                }.cellUpdate { cell, row in
                    if !self.navigationAccessoryIsHidden{
                        self.navigationAccessoryIsHidden = true
                    }
                    cell.inputAccessoryView?.isHidden = self.navigationAccessoryIsHidden
                    
                    if self.cigarToEdit != nil {
                        if self.cigarToEdit?.from != row.value {
                            self.changesStatus![5] = true
                        }
                        else{
                            self.changesStatus![5] = false
                        }
                        self.valuateSaveButonStatus()
                    }
                }
            <<< DateInlineRow("Purchase Date"){
                $0.title = NSLocalizedString("Purchase Date", comment: "")
                $0.value = cigarToEdit?.purchaseDate ?? Date()
                $0.maximumDate = Date()
                }.onChange({ (row) in
                    let sinceRow = self.form.rowBy(tag: "Since") as! DateInlineRow
                    sinceRow.maximumDate = row.value!
                    if sinceRow.value! > row.value!{
                        sinceRow.value = row.value
                        sinceRow.reload()
                    }
                    
                    if self.cigarToEdit != nil {
                        if self.cigarToEdit?.purchaseDate != row.value {
                            self.changesStatus![6] = true
                        }
                        else{
                            self.changesStatus![6] = false
                        }
                        self.valuateSaveButonStatus()
                    }
                })
            <<< SwitchRow("Has been aged"){
                $0.title = NSLocalizedString("Has been aged", comment: "")
                if cigarToEdit != nil{
                    $0.value = true
                }
                else{
                    $0.value = false
                }
                }
            
            <<< DateInlineRow("Since"){
                $0.title = NSLocalizedString("Since", comment: "")
                $0.maximumDate = cigarToEdit?.purchaseDate ?? Date()
                $0.value = cigarToEdit?.ageDate ?? Date()
                $0.hidden = .function(["Has been aged"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "Has been aged")
                    return row.value ?? false == false
                })
                }.onChange({ (row) in
                    if self.cigarToEdit != nil {
                        if self.cigarToEdit?.purchaseDate != row.value {
                            self.changesStatus![7] = true
                        }
                        else{
                            self.changesStatus![7] = false
                        }
                        self.valuateSaveButonStatus()
                    }
                })
        
            +++ Section()
            <<< TextAreaRow("Notes"){
                $0.placeholder = NSLocalizedString("Notes", comment: "")
                $0.value = cigarToEdit?.notes ?? nil
                }.cellUpdate { cell, row in
                    if self.navigationAccessoryIsHidden{
                        self.navigationAccessoryIsHidden = false
                    }
                    cell.inputAccessoryView?.isHidden = self.navigationAccessoryIsHidden
                    
                    if self.cigarToEdit != nil {
                        if self.cigarToEdit?.notes != row.value {
                            self.changesStatus![8] = true
                        }
                        else{
                            self.changesStatus![8] = false
                        }
                        self.valuateSaveButonStatus()
                    }
            }
        
        +++ Section(NSLocalizedString("Location", comment: ""))
            <<< PushRow<String>("Humidor"){
                $0.title = NSLocalizedString("Humidor", comment: "")
                $0.value = cigarToEdit?.tray?.humidor?.name ?? humidor.name!
                $0.selectorTitle = $0.tag
                $0.options = getHumidorsList()
                }.onPresent{ from, to in
                    to.selectableRowCellUpdate = { cell, _ in cell.tintColor = UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1)}
                    to.enableDeselection = false
                    
                }.onChange { row in
                    self.humidor = CoreDataController.sharedInstance.searchHumidor(name: row.value!)
                    let trayRow: PushRow! = self.form.rowBy(tag: "Tray") as! PushRow<String>
                    let traysOptions = self.getTraysList(humidor: self.humidor)
                    trayRow.value = traysOptions.first!
                    trayRow.options = traysOptions
                    trayRow.updateCell()
                    
                    if self.cigarToEdit != nil {
                        if self.cigarToEdit?.tray?.humidor?.name != row.value {
                            self.changesStatus![9] = true
                        }
                        else{
                            self.changesStatus![9] = false
                        }
                        self.valuateSaveButonStatus()
                    }
                }
            <<< PushRow<String>("Tray"){
                let traysOptions = getTraysList(humidor: humidor)
                $0.title = NSLocalizedString("Divider", comment: "")
                $0.value =  cigarToEdit?.tray?.name! ??  traysOptions.first!
                $0.selectorTitle = $0.tag
                $0.options = traysOptions
                }.onPresent{ from, to in
                    to.selectableRowCellUpdate = { cell, _ in cell.tintColor = UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1)}
                    to.enableDeselection = false
                }.onChange{ row in
                    if self.cigarToEdit != nil {
                        if self.cigarToEdit?.tray?.name != row.value {
                            self.changesStatus![10] = true
                        }
                        else{
                            self.changesStatus![10] = false
                        }
                        self.valuateSaveButonStatus()
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
    
    
    override func viewWillDisappear(_ animated: Bool) {
        self.view.endEditing(true)
    }
    
    func valuateSaveButonStatus(){
        if !changesStatus!.contains(true){
            self.saveButton.isEnabled = false
        }
        else{
            let nameRow = self.form.rowBy(tag: "Name") as! TextRow
            if nameRow.value == nil {
                self.saveButton.isEnabled = false
            }
            else{
                self.saveButton.isEnabled = true
            }
        }
    }
    
    
    //MARK: -Keyboard
    
    override func textInputShouldReturn<T>(_ textInput: UITextInput, cell: Cell<T>) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    // MARK: Data
    func getTraysList(humidor: Humidor) -> [String]{
        let humidorTrays = (humidor.trays!.allObjects as! [Tray]).sorted(by: { $0.orderID < $1.orderID })
        var trays = [String]()
        for tray in humidorTrays{
            trays.append(tray.name!)
        }
        return trays
    }
    
    func getHumidorsList() -> [String]{
        let humidorsObject = CoreDataController.sharedInstance.fetchHumidors()
        var humidors = [String]()
        for humidor in humidorsObject!{
            if humidor.name! == self.humidor.name!
            {
                humidors.insert(humidor.name!, at: 0)
            }
            else{
                humidors.append(humidor.name!)
            }
        }
        return humidors
    }
    
    // MARK: - Navigation

    @IBAction func cancel(_ sender: UIBarButtonItem) {
        	dismiss(animated: true, completion: nil)
    }
    
    @objc func dismisskeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
       
        if !UserSettings.isPremium.value{
            var countCigars:Int32 = 0
            let humidors = CoreDataController.sharedInstance.fetchHumidors()
            for humidor in humidors!{
                countCigars = countCigars + humidor.quantity
            }
            let cigarQuantity = Int32((form.rowBy(tag: "Quantity") as! IntRow).value!)
            if (countCigars + cigarQuantity) > 24{
                // create the alert
                let alert = UIAlertController(title: NSLocalizedString("CigarStack Premium", comment: ""), message: NSLocalizedString("CigarStack Premium allows you to add as many cigars as you want. You are using the free version which allows you to add a maximum of 25 cigars. You have", comment: "") + " " + String(25-countCigars) +
                     " " + NSLocalizedString("cigars left.", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                
                // add an action (button)
                alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: NSLocalizedString("Get Premium", comment: ""), style: .destructive) { _ in
                    let storyboard = UIStoryboard(name: "Settings", bundle: nil)
                    let destVC = storyboard.instantiateViewController(withIdentifier: "premiumController") as! PurchaseViewController
                    destVC.hideCloseButton = false
                    destVC.modalPresentationStyle = .formSheet
                    destVC.modalTransitionStyle = .coverVertical
                    self.present(destVC, animated: true, completion: nil)
                    
                })
                alert.view.tintColor = UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1)
                
                // show the alert
                self.present(alert, animated: true, completion: nil)
            }
            else{
                saveCigar()
            }
            
        }
        else{
            saveCigar()
        }
        
 
    }
    
    
    func saveCigar(){
        let formValues = self.form.values()
        let nameForm = formValues["Name"] as! String
        let sizeForm = formValues["Size"] as! String
        let quantityForm = formValues["Quantity"] as! Int
        let priceForm = formValues["Price"] as! Double
        let fromForm = formValues["From"] as? String
        let purchaseDateForm = formValues["Purchase Date"] as! Date
        var ageDateForm = formValues["Since"] as? Date
        let notesForm = formValues["Notes"] as? String
        let humidorForm = formValues["Humidor"] as! String
        let trayForm = formValues["Tray"] as! String
        
        if ageDateForm == nil{
            ageDateForm = purchaseDateForm
        }
        
        
        let humidor = CoreDataController.sharedInstance.searchHumidor(name: humidorForm)
        let location = CoreDataController.sharedInstance.searchTray(humidor: humidor!, searchTray: trayForm)
        
        if cigarToEdit != nil {
            cigarToEdit?.name = nameForm
            cigarToEdit?.size = sizeForm
            cigarToEdit?.origin = selectedCountryCode
            let quantity = Int32(quantityForm)
            //Update humidor quantity
            if cigarToEdit?.quantity != quantity {
                humidor?.quantity = (humidor?.quantity)! - (cigarToEdit?.quantity)!
                humidor?.quantity = (humidor?.quantity)! + quantity
            }
            
            cigarToEdit?.quantity = quantity
            cigarToEdit?.purchaseDate = purchaseDateForm
            cigarToEdit?.ageDate = ageDateForm
            cigarToEdit?.from = fromForm
            //Update humidor value
            if cigarToEdit?.price != priceForm {
                humidor?.value = (humidor?.value)! - (cigarToEdit?.price)!
                humidor?.value = (humidor?.value)! + priceForm
            }
            cigarToEdit?.price = priceForm
            cigarToEdit?.notes = notesForm
            cigarToEdit?.editDate = Date()
            
            if changesStatus![10] == true{
                cigarToEdit?.tray = location
            }
            
            CoreDataController.sharedInstance.saveContext()
        }
        else{
            _ = CoreDataController.sharedInstance.addNewCigar(tray: location!, name: nameForm, origin: selectedCountryCode, quantity: Int32(quantityForm), size: sizeForm, purchaseDate: purchaseDateForm, from: fromForm, price: priceForm, ageDate: ageDateForm , notes: notesForm)
        }
        
        if humidorForm == UserSettings.currentHumidor.value {
            UserSettings.shouldReloadData.value = true
        }
        
        dismiss(animated: true, completion: nil)
        if UIDevice.current.userInterfaceIdiom == .pad{
            delegate?.addCigarForceReload()
        }
        
        delegate?.cigarTriggerReview()
    }

    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "countrySelect" {
            let destinationVC = segue.destination as! CountrySelectViewController
            destinationVC.delegateCountryCode = selectedCountryCode
            destinationVC.delegate = self
        }
    }
    
    // MARK: - Delegate
    
    func completeDelegate(countryNameDelegate: String) {
        let row = (form.rowBy(tag: "Country of origin") as! LabelRow)
        row.value = Locale.current.localizedString(forRegionCode: countryNameDelegate)
        selectedCountryCode = countryNameDelegate
        row.cell.update()
    }

}

    //MARK: - Custom NavigationAccessoryView
class CustomNavigationAccessoryView : NavigationAccessoryView {
        
        override init(frame: CGRect) {
            super.init(frame:  CGRect(x: 0, y: 0, width: frame.size.width, height: 44.0))
            autoresizingMask = .flexibleWidth
            setItems([flexibleSpace, doneButton], animated: false)
        }

    private var flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
 
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
    
    
    // MARK: - Currency Formatter
    
class CurrencyFormatter : NumberFormatter, FormatterProtocol {
        override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?, for string: String, range rangep: UnsafeMutablePointer<NSRange>?) throws {
            guard obj != nil else { return }
            var str = string.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "")
            if !string.isEmpty, numberStyle == .currency && !string.contains(currencySymbol) {
                // Check if the currency symbol is at the last index
                if let formattedNumber = self.string(from: 1), String(formattedNumber[formattedNumber.index(before: formattedNumber.endIndex)...]) == currencySymbol {
                    // This means the user has deleted the currency symbol. We cut the last number and then add the symbol automatically
                    str = String(str[..<str.index(before: str.endIndex)])
                    
                }
            }
            obj?.pointee = NSNumber(value: (Double(str) ?? 0.0)/Double(pow(10.0, Double(minimumFractionDigits))))
        }
        
        func getNewPosition(forPosition position: UITextPosition, inTextInput textInput: UITextInput, oldValue: String?, newValue: String?) -> UITextPosition {
            return textInput.position(from: position, offset:((newValue?.count ?? 0) - (oldValue?.count ?? 0))) ?? position
        }
    }

extension Double {
    var asLocalCurrency:String{
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter.string(from: self as NSNumber)!
    }
}


