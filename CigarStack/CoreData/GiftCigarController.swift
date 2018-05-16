//
//  GiftCigarController.swift
//  CigarStack
//
//  Created by Darius Pasca on 13/05/2018.
//  Copyright © 2018 Darius Pasca. All rights reserved.
//

import UIKit
import Eureka

protocol giftCigarViewDelegate{
    func giftCigarDelegate(to: String, notes: String?, quantity: Int32)
}


class GiftCigarController: FormViewController {
    
    var cigar: Cigar!
    var quantity: Int32!
    var dismissKeyboard = false
    var navigationAccessoryIsHidden = true
    var delegate:giftCigarViewDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Regala", comment: ""),style: .plain, target: self, action: #selector(giftCigar))
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        self.form.keyboardReturnType = KeyboardReturnTypeConfiguration(nextKeyboardType: .send, defaultKeyboardType: .send)
        self.navigationItem.title =  cigar.name!
        
        navigationAccessoryView = {
            let naview = CustomNavigationAccessoryView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44.0))
            naview.tintColor = UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1)
            naview.doneButton.target = self
            naview.doneButton.action = #selector(dismisskeyboard)
            return naview
        }()
        
        quantity = 1
        self.view.tintColor = UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1)
        
        form +++ Section()
            
            <<< TextRow("To"){
                $0.title = NSLocalizedString("Gift to:", comment: "")
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
                            self.navigationItem.rightBarButtonItem?.isEnabled = true
                        }
                    }
                    else{
                        self.navigationItem.rightBarButtonItem?.isEnabled = false
                    }
                    
            }
            
            <<< PickerInputRow<String>("Picker Row") {
                $0.title = NSLocalizedString("Quantity", comment: "")
                var options = [String]()
                for i in 1...Int(cigar.quantity){
                    options.append("\(i)")
                }
                $0.value = options.first!
                $0.options = options
                if cigar.quantity > 1 {
                    $0.hidden = false
                }
                else{
                    $0.hidden = true
                }
                }.cellSetup { cell, row in cell.tintColor = UIColor.black }.cellUpdate { cell, row in
                    if self.navigationAccessoryIsHidden{
                        self.navigationAccessoryIsHidden = false
                    }
                    cell.inputAccessoryView?.isHidden = self.navigationAccessoryIsHidden
                    self.quantity = Int32(row.value!)
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !dismissKeyboard{
            let row: TextRow! = self.form.rowBy(tag: "To")
            row.cell.textField.becomeFirstResponder()
            dismissKeyboard = true
        }
        
    }
    
    @objc func dismisskeyboard() {
        view.endEditing(true)
    }
    
    @objc func cancel(sender: UIBarButtonItem) {
        self.view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func giftCigar(){
        let formValues = self.form.values()
        let toForm = formValues["To"] as! String
        let notesForm = formValues["To"] as? String
        
        delegate.giftCigarDelegate(to: toForm, notes: notesForm, quantity: quantity)
        dismiss(animated: true, completion: nil)
        
    }
}

