//
//  SizeViewController.swift
//  PocketHumidor
//
//  Created by Darius Pasca on 16/02/2019.
//  Copyright © 2019 Darius Pasca. All rights reserved.
//

import UIKit
import Eureka

class SizeViewController: FormViewController {
    
    var delegateSize: String?
    var delegate: SelectSizeDelegate?
    var cigar:Cigar?
    var sizes = ["Cigarillo" , "Small Panetela" , "Slim Panetela" , "Short Panetela" , "Pantetela" , "Long Panetela" , "Toscanello" , "Toscano",
                 "Petit Corona" , "Corona", "Long Corona" , "Lonsdale" , "Corona Extra" , "Grand Corona" , "Double Corona" ,
                 "Giant Corona" , "Churchill" , "Petit Robusto" , "Robusto" , "Robusto Extra", "Double Robusto" , "Giant Robusto" , "Toro" ,
                 "Culebra" , "Oetut Pyramid" , "Pyramid" , "Double Pyramid" , "Petit Perfecto" , "Perfecto" , "Double Perfecto" , "Giant Perfecto" ]

    override func viewDidLoad() {
        super.viewDidLoad()

        self.form.keyboardReturnType = KeyboardReturnTypeConfiguration(nextKeyboardType: .send, defaultKeyboardType: .send)
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = 44.0
        
        
       form +++ Section()
        <<< TextRow ("Size") {
            $0.placeholder = NSLocalizedString("Size", comment: "")
            $0.value = cigar?.name! ?? delegateSize
        
        }
        
        prepareSuggestions(suggestions: sizes)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let row: TextRow! = self.form.rowBy(tag: "Size")
        row.cell.textField.becomeFirstResponder()

        
    }
    
    func prepareSuggestions(suggestions:[String]){
        form +++ SelectableSection<ListCheckRow<String>>("Suggestions", selectionType:.singleSelection(enableDeselection: false))
        
        for option in sizes {
            form.last! <<< ListCheckRow<String>(option){ listRow in
                listRow.title = option
                listRow.selectableValue = option
                listRow.value = nil
                listRow.onChange({ (row) in
                    row.value = nil
                })
            }
        }
    }
    
    
    override func valueHasBeenChanged(for row: BaseRow, oldValue: Any?, newValue: Any?) {
        guard row.section === form.last else { return }
        guard let selectedSuggestionRow = (row.section as! SelectableSection<ListCheckRow<String>>).selectedRow() else { return }
        
        let sizeTextField = self.form.rowBy(tag: "Size") as! TextRow
        sizeTextField.value = selectedSuggestionRow.title!
        sizeTextField.updateCell()
        delegateSize = sizeTextField.value
        sendData()
    }
    
    func sendData(){
        delegate?.completeDelegate(sizeDelegate: delegateSize)
        popView()
        
    }
    
    @objc func popView() {
        let when = DispatchTime.now() + 0.1 // change 2 to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.navigationController?.popViewController(animated: true)
        }
    }

}

protocol SelectSizeDelegate {
    func completeDelegate(sizeDelegate: String?)
}
