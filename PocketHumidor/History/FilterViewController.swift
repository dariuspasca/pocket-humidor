//
//  FilterViewController.swift
//  CigarStack
//
//  Created by Darius Pasca on 31/05/2018.
//  Copyright © 2018 Darius Pasca. All rights reserved.
//

import UIKit
import Eureka

protocol filterViewDelegate{
    func filterViewDelegate(filterDelegate: Filter)
}

class FilterViewController: FormViewController {

    @IBOutlet weak var applyButton: UIBarButtonItem!
    var historyFilter: Filter!
    var delegate:filterViewDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyButton.title = NSLocalizedString("Apply", comment: "")
        self.navigationItem.title = NSLocalizedString("History filter", comment: "")
        
        func filterRow(_ filter: Filter) -> ListCheckRow<Filter> {
            return ListCheckRow<Filter>() {
                $0.title = filter.displayName
                $0.selectableValue = filter
                $0.value = historyFilter == filter ? filter : nil
                }.cellSetup{cell, row in
                    cell.tintColor = UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1)
            }
        }
        
        form +++ SelectableSection<ListCheckRow<Filter>>(header: NSLocalizedString("Show", comment: ""), footer: NSLocalizedString("Select which items to be displayed.", comment: ""), selectionType: .singleSelection(enableDeselection: false))
            
            <<< filterRow(.smoke)
            <<< filterRow(.gift)
            <<< filterRow(.both)
    }
    
    override func valueHasBeenChanged(for row: BaseRow, oldValue: Any?, newValue: Any?) {
        guard row.section === form[0] else { return }
        guard let selectedFilter = (row.section as! SelectableSection<ListCheckRow<Filter>>).selectedRow()?.baseValue as? Filter else { return }
        historyFilter = selectedFilter
    }

    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func applyAction(_ sender: UIBarButtonItem) {
        delegate.filterViewDelegate(filterDelegate: historyFilter)
        dismiss(animated: true, completion: nil)
    }
    

}
