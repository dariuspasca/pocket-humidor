//
//  MoveCigarViewController.swift
//  CigarStack
//
//  Created by Darius Pasca on 02/05/2018.
//  Copyright © 2018 Darius Pasca. All rights reserved.
//

import UIKit
import Eureka

protocol moveCigarViewDelegate{
    func moveCigarDelegate(toTray: Tray, quantity: Int32)
}

class MoveCigarViewController: FormViewController {
    
    var cigar: Cigar!
    var humidorsList = [String]()
    var traysList = [String]()
    var selectedHumidor = 0
    var quantity: Int32!
    var delegate:moveCigarViewDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Move", comment: ""),style: .plain, target: self, action: #selector(moveCigar))

        self.form.keyboardReturnType = KeyboardReturnTypeConfiguration(nextKeyboardType: .send, defaultKeyboardType: .send)
        
        
        self.navigationItem.title =  cigar.name!
        quantity = cigar.quantity
        let currentTray = cigar.tray?.name!
        
        populateHumidorsList()
        populateTraysList(humidorName: UserSettings.currentHumidor.value)
        
        form +++ Section(){
            if self.cigar.quantity > 1 {
                $0.hidden = false
            }
            else{
                $0.hidden = true
            }
            
            }
            
            <<< PickerInputRow<String>("Picker Row") {
                $0.title = NSLocalizedString("Quantity", comment: "")
                var options = [String]()
                for i in 1...Int(quantity){
                    options.append("\(i)")
                }
                $0.value = options.last!
                $0.options = options

                }.cellUpdate { cell, row in
                    self.quantity = Int32(row.value!)
            }
            
            
            +++ Section()
            
            <<< PushRow<String>(NSLocalizedString("Move to", comment: "")){
                $0.title = $0.tag
                $0.value = humidorsList.first!
                $0.selectorTitle = $0.tag
                $0.options = humidorsList
                }.onPresent{ from, to in
                    to.selectableRowCellUpdate = { cell, _ in cell.tintColor = UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1)
                        to.navigationController?.navigationBar.tintColor = UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1)
                    }
                }.onChange{[weak self] row in
                    row.deselect()
                    if let index = self?.humidorsList.index(where: {$0 == row.value }){
                        self?.populateTraysList(humidorName: (self?.humidorsList[index])!)
                        self?.selectedHumidor = index
                        row.updateCell()
                        self?.updateSection()
                    }
            }
            
            
            +++ SelectableSection<ListCheckRow<String>>(NSLocalizedString("Dividers", comment: ""), selectionType: .singleSelection(enableDeselection: false ))
        var flag = false
        for tray in traysList {
            form.last! <<< ListCheckRow<String>(tray){ listRow in
                listRow.title = tray
                listRow.selectableValue = tray
                if selectedHumidor == 0 {
                    if tray == currentTray{
                        listRow.disabled = true
                    }
                    else{
                        if flag == false {
                            listRow.value = listRow.title
                            flag = true
                        }
                        else{
                            listRow.value = nil
                        }
                    }
                }
                else{
                    if listRow.title == traysList.first!{
                        listRow.value = listRow.title
                    }
                    else{
                        listRow.value = nil
                    }
                }
                }.cellSetup { cell, row in cell.tintColor = UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1) }
        }
        
    }

    override var customNavigationAccessoryView: (UIView & NavigationAccessory)? {
        let naview = CustomNavigationAccessoryView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44.0))
        naview.tintColor = UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1)
        naview.doneButton.target = self
        naview.doneButton.action = #selector(dismissKeyboard)
        return naview
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if UserSettings.currentHumidor.value == humidorsList[selectedHumidor]{
            if cigar.tray?.humidor?.trays?.count == 1 {
                navigationItem.rightBarButtonItem?.isEnabled = false
            }
            else{
                navigationItem.rightBarButtonItem?.isEnabled = true
            }
        }
        else{
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
    
    
    func populateHumidorsList(){
        let humidors = CoreDataController.sharedInstance.fetchHumidors()
        if !humidors!.isEmpty {
            for humidor in humidors! {
                if humidor.name! == UserSettings.currentHumidor.value{
                    humidorsList.insert(humidor.name!, at: 0)
                }
                else{
                    humidorsList.append(humidor.name!)
                }
            }
        }
    }
    
    func populateTraysList(humidorName: String){
        traysList.removeAll()
        let humidor = CoreDataController.sharedInstance.searchHumidor(name: humidorName)
        let trays = (humidor!.trays?.allObjects as! [Tray]).sorted(by: { $0.orderID < $1.orderID })
        for tray in trays
        {
            traysList.append(tray.name!)
        }
    }
    
    func updateSection(){
        let currentTray = cigar.tray?.name!
        form.last!.removeAll()
        var flag = false
        for tray in traysList {
            form.last! <<< ListCheckRow<String>(tray){ listRow in
                listRow.title = tray
                listRow.selectableValue = tray
                if selectedHumidor == 0 {
                    if tray == currentTray{
                        listRow.disabled = true
                    }
                    else{
                        if flag == false {
                            listRow.value = listRow.title
                            flag = true
                        }
                        else{
                            listRow.value = nil
                        }
                    }
                }
                else{
                    if listRow.title == traysList.first!{
                        listRow.value = listRow.title
                    }
                    else{
                        listRow.value = nil
                    }
                }
                }.cellSetup{cell, row in
                    cell.tintColor = UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1)
            }
        }
        form.last!.reload()
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func moveCigar(){
        let selectedTray = (form.last! as! SelectableSection<ListCheckRow<String>>).selectedRow()!.value!
        let humidor = CoreDataController.sharedInstance.searchHumidor(name: humidorsList[selectedHumidor])
        let destination = CoreDataController.sharedInstance.searchTray(humidor: humidor!, searchTray: selectedTray)
        delegate.moveCigarDelegate(toTray: destination!, quantity: quantity)
        dismiss(animated: true, completion: nil)
        
    }
    
    @objc func cancel(sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}
