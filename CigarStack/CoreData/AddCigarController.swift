//
//  AddCigarController.swift
//  CigarStack
//
//  Created by Darius Pasca on 18/01/2018.
//  Copyright © 2018 Darius Pasca. All rights reserved.
//

import UIKit
import Eureka
import ImageRow
import FlagKit

class AddCigarController: FormViewController, SelectCountryDelegate {
    
    var sizes = ["Cigarillo" , "Small Panetela" , "Slim Panetela" , "Short Panetela" , "Pantetela" , "Long Panetela" , "Toscanello" , "Toscano",
                 "Petit Corona" , "Corona", "Long Corona" , "Lonsdale" , "Corona Extra" , "Grand Corona" , "Double Corona" ,
                 "Giant Corona" , "Churchill" , "Petit Robusto" , "Robusto" , "Robusto Extra", "Double Robusto" , "Giant Robusto" ,
                 "Culebra" , "Oetut Pyramid" , "Pyramid" , "Double Pyramid" , "Petit Perfecto" , "Perfecto" , "Double Perfecto" , "Giant Perfecto" ]
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    var dismissKeyboard = false
    var navigationAccessoryIsHidden = true
    
    var selectedCountryCode:String!
    var humidor: Humidor!
    var humidorTrays: [Tray]!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = NSLocalizedString("Add Cigar", comment: "")
        //Default Country
        selectedCountryCode = "CU"
        humidor = CoreDataController.sharedInstance.searchHumidor(name: UserSettings.currentHumidor.value)
        
        
        self.form.keyboardReturnType = KeyboardReturnTypeConfiguration(nextKeyboardType: .send, defaultKeyboardType: .send)
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = 44.0
      
        navigationAccessoryView = {
            let naview = CustomNavigationAccessoryView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44.0))
            naview.tintColor = UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1)
            naview.doneButton.target = self
            naview.doneButton.action = "navigationDone:"
            return naview
        }()
 
        form +++ Section()
            <<< TextRow ("Name") {
                $0.placeholder = NSLocalizedString("Cigar Name", comment: "")
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
            
            <<< PushRow<String>("Size"){
                $0.title = NSLocalizedString("Size", comment: "")
                $0.value = sizes.first
                $0.selectorTitle = $0.tag
                $0.options = sizes
                }.onPresent{ from, to in
                    to.selectableRowCellUpdate = { cell, _ in cell.tintColor = UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1)}
                    to.enableDeselection = false
            }
            <<< LabelRow ("Country of origin") {
                $0.title = NSLocalizedString("Country of origin", comment: "")
                $0.value =  Locale.current.localizedString(forRegionCode: selectedCountryCode)
                $0.cell.accessoryType = .disclosureIndicator
                }
                .onCellSelection { cell, row in
                    self.performSegue(withIdentifier: "countrySelect", sender: self)
                }

            
            +++ Section()
            <<< IntRow("Quantity"){
                $0.title = NSLocalizedString("Quantity", comment: "")
                $0.value = 1
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
            }
            
            <<< DecimalRow("Price"){
                $0.useFormatterDuringInput = true
                $0.title = NSLocalizedString("Price", comment: "")
                let formatter = CurrencyFormatter()
                formatter.locale = NSLocale.current
                formatter.numberStyle = NumberFormatter.Style.currency
                $0.formatter = formatter
                $0.value = 0
                }.cellUpdate { cell, row in
                    if self.navigationAccessoryIsHidden{
                        self.navigationAccessoryIsHidden = false
                    }
                    cell.inputAccessoryView?.isHidden = self.navigationAccessoryIsHidden
                }
        
            
        
        
            +++ Section()
            <<< TextRow("From"){
                $0.title = NSLocalizedString("From", comment: "")
                $0.placeholder = NSLocalizedString("Shop Name", comment: "")
                }.cellUpdate { cell, row in
                    if !self.navigationAccessoryIsHidden{
                        self.navigationAccessoryIsHidden = true
                    }
                    cell.inputAccessoryView?.isHidden = self.navigationAccessoryIsHidden
                }
            <<< DateInlineRow("Purchase Date"){
                $0.title = NSLocalizedString("Purchase Date", comment: "")
                $0.maximumDate = Date()
                $0.value = Date()
        }
            <<< SwitchRow("Has been aged"){
                $0.title = NSLocalizedString("Has been aged", comment: "")
        }
            <<< DateInlineRow("Since"){
                $0.title = NSLocalizedString("Since", comment: "")
                $0.maximumDate = Date()
                $0.value = Date()
                $0.hidden = .function(["Has been aged"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "Has been aged")
                    return row.value ?? false == false
                })
        }
        
            +++ Section()
            <<< TextAreaRow("Notes"){
                $0.placeholder = NSLocalizedString("Notes", comment: "")
                }.cellUpdate { cell, row in
                    if self.navigationAccessoryIsHidden{
                        self.navigationAccessoryIsHidden = false
                    }
                    cell.inputAccessoryView?.isHidden = self.navigationAccessoryIsHidden
            }
            
            +++ Section()
            <<< ImageRow("Cigar picture") { row in
                row.title = NSLocalizedString("Photo", comment: "")
                row.sourceTypes = [.PhotoLibrary, .Camera]
                row.placeholderImage = UIImage(named: "plus")
                row.clearAction = .yes(style: UIAlertActionStyle.destructive)
                }.cellUpdate { cell, row in
                    cell.accessoryView?.layer.cornerRadius = 8
                    cell.accessoryView?.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
            }
        
        +++ Section(NSLocalizedString("Location", comment: ""))
            <<< PushRow<String>("Humidor"){
                $0.title = NSLocalizedString("Humidor", comment: "")
                $0.value = humidor.name!
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
                }
            <<< PushRow<String>("Tray"){
                let traysOptions = getTraysList(humidor: humidor)
                $0.title = NSLocalizedString("Divider", comment: "")
                $0.value = traysOptions.first!
                $0.selectorTitle = $0.tag
                $0.options = traysOptions
                }.onPresent{ from, to in
                    to.selectableRowCellUpdate = { cell, _ in cell.tintColor = UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1)}
                    to.enableDeselection = false
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
        for humidor in humidorsObject{
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
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        var imageData: Data?
        
        let formValues = self.form.values()
        let nameForm = formValues["Name"] as! String
        let sizeForm = formValues["Size"] as! String
        let quantityForm = formValues["Quantity"] as! Int
        let priceForm = formValues["Price"] as! Double
        let fromForm = formValues["From"] as? String
        let purchaseDateForm = formValues["Purchase Date"] as! Date
        let ageDateForm = formValues["Since"] as? Date
        let notesForm = formValues["Notes"] as? String
        let imageForm = formValues["Cigar picture"] as? UIImage
        let humidorForm = formValues["Humidor"] as! String
        let trayForm = formValues["Tray"] as! String
        
        if imageForm != nil {
            imageData = UIImageJPEGRepresentation(imageForm!, 1)
        }
        
        let humidor = CoreDataController.sharedInstance.searchHumidor(name: humidorForm)
        let location = CoreDataController.sharedInstance.searchTray(humidor: humidor!, searchTray: trayForm)
        _ = CoreDataController.sharedInstance.addNewCigar(tray: location!, name: nameForm, origin: selectedCountryCode, quantity: Int32(quantityForm), size: sizeForm, purchaseDate: purchaseDateForm, from: fromForm, price: priceForm, ageDate: ageDateForm , image: imageData, notes: notesForm)
        if humidorForm == UserSettings.currentHumidor.value {
             UserSettings.shouldReloadData.value = true
        }
        dismiss(animated: true, completion: nil)
        
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


