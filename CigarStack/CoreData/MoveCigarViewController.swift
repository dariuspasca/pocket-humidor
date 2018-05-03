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
        
        navigationAccessoryView.tintColor = UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1)
        
        self.navigationItem.title =  cigar.name!
        quantity = cigar.quantity
        let currentTray = cigar.tray?.name!
        
        populateHumidorsList()
        populateTraysList(humidorName: UserSettings.currentHumidor.value)
        form +++ Section()
            <<< SwitchRow("Move all"){
                $0.title = NSLocalizedString("Move All", comment: "")
                $0.value = true
                if quantity == 1 {
                    $0.hidden = true
                }
        }
            <<< PickerInputRow<String>("Picker Row") {
                $0.title = NSLocalizedString("Quantity", comment: "")
                var options = [String]()
                for i in 1...Int(quantity){
                    options.append("\(i)")
                }
                $0.value = options.first!
                $0.options = options
                $0.hidden = .function(["Move all"], { form -> Bool in
                    let row: RowOf<Bool>! = form.rowBy(tag: "Move all")
                    return row.value ?? true == true
                })
                }.cellSetup { cell, row in cell.tintColor = UIColor.black }.cellUpdate { cell, row in
                    self.quantity = Int32(row.value!)
            }
        
            +++ Section(NSLocalizedString("Humidors", comment: ""))
            
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
                    if let index = self?.humidorsList.index(where: {$0 == row.value }){
                        self?.populateTraysList(humidorName: (self?.humidorsList[index])!)
                        self?.selectedHumidor = index
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func populateHumidorsList(){
        let humidors = CoreDataController.sharedInstance.fetchHumidors()
        if !humidors.isEmpty {
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
            }
        }
        form.last!.reload()
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
