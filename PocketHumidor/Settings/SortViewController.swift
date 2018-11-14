//
//  SortViewController.swift
//  CigarStack
//
//  Created by Darius Pasca on 08/03/2018.
//  Copyright © 2018 Darius Pasca. All rights reserved.
//

import UIKit
import Eureka

class SortViewController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        CheckRow.defaultCellSetup = { cell, row in cell.tintColor = UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1) }
        form +++ Section(header: NSLocalizedString("Sort Order", comment: ""), footer: NSLocalizedString("Select the preferred order when sorting", comment: ""))
            <<< CheckRow("Ascending"){
                $0.title = NSLocalizedString("Ascending", comment: "")
                if UserSettings.sortAscending.value == true {
                    $0.value = true
                }
                else{
                    $0.value = false
                }
                }
                .onCellSelection { cell, ascendingRow in
                    if ascendingRow.value == true{
                        let descendingRow = self.form.rowBy(tag: "Descending") as! CheckRow
                        if descendingRow.value == true {
                            descendingRow.value = !(descendingRow.value!)
                            UserSettings.sortAscending.value = true
                            UserSettings.shouldReloadView.value = true
                            descendingRow.updateCell()
                        }
                    }
                    else{
                        ascendingRow.value! = !(ascendingRow.value!)
                        ascendingRow.updateCell()
                    }
            }
            <<< CheckRow("Descending"){
                $0.title = NSLocalizedString("Descending", comment: "")
                if UserSettings.sortAscending.value != true {
                    $0.value = true
                }
                else{
                    $0.value = false
                }
                }
                .onCellSelection { cell, descendingRow in
                    if descendingRow.value == true{
                        let ascendingRow = self.form.rowBy(tag: "Ascending") as! CheckRow
                        if ascendingRow.value == true {
                            ascendingRow.value = !(ascendingRow.value!)
                            UserSettings.sortAscending.value = false
                            UserSettings.shouldReloadView.value = true
                            ascendingRow.updateCell()
                        }
                    }
                    else{
                        descendingRow.value! = !(descendingRow.value!)
                        descendingRow.updateCell()
                    }
        }
    }

}
