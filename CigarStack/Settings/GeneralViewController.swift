//
//  GeneralViewController.swift
//  CigarStack
//
//  Created by Darius Pasca on 08/03/2018.
//  Copyright © 2018 Darius Pasca. All rights reserved.
//

import UIKit
import Eureka

class GeneralViewController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationAccessoryView.tintColor = UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1)
        
        func tableSortRow(_ tableSort: TableSortOrder) -> ListCheckRow<TableSortOrder> {
            return ListCheckRow<TableSortOrder>() {
                $0.title = tableSort.displayName
                $0.selectableValue = tableSort
                $0.value = UserSettings.tableSortOrder == tableSort ? tableSort : nil
                }.cellSetup{cell, row in
                    cell.tintColor = UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1)
            }
        }
        
        form +++ Section(footer: NSLocalizedString("Change the display currency. It does not convert prices from previous currency.", comment: ""))
            <<< PickerInputRow<String>(NSLocalizedString("Currency", comment: "")){
                $0.title = $0.tag
                $0.value = UserSettings.currency.value
                $0.options = Locale.commonISOCurrencyCodes
                }
                .onChange{ row in
                    UserSettings.currency.value = row.value!
            }
            
            +++ Section(footer: NSLocalizedString("Automatically open newly added humidor.", comment: ""))
            <<< SwitchRow(NSLocalizedString("Open New Humidor", comment: "")){
                $0.title = $0.tag
                $0.value = UserSettings.openHumidor.value
                }
                .onChange {
                    UserSettings.openHumidor.value = $0.value!
            }
            
            +++ SelectableSection<ListCheckRow<TableSortOrder>>(header: NSLocalizedString("Order", comment: ""), footer: NSLocalizedString("Select default display order.", comment: ""), selectionType: .singleSelection(enableDeselection: false))
            
            <<< tableSortRow(.byDate)
            <<< tableSortRow(.byName)
            <<< tableSortRow(.byQuantity)
            <<< tableSortRow(.byPrice)
            <<< tableSortRow(.byCountry)
            <<< tableSortRow(.byAge)
    }
    
    override func valueHasBeenChanged(for row: BaseRow, oldValue: Any?, newValue: Any?) {
        guard row.section === form[2] else { return }
        guard let selectedSort = (row.section as! SelectableSection<ListCheckRow<TableSortOrder>>).selectedRow()?.baseValue as? TableSortOrder else { return }
        
        UserSettings.shouldReloadData.value = true
        UserSettings.defaultSortOrder.value = selectedSort.hashValue
        UserSettings.tableSortOrder = selectedSort
    }

}
