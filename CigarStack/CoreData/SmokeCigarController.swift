//
//  SmokeCigarController.swift
//  CigarStack
//
//  Created by Darius Pasca on 16/05/2018.
//  Copyright © 2018 Darius Pasca. All rights reserved.
//

import UIKit
import Eureka

protocol smokeCigarViewDelegate{
    func smokeCigarDelegate()
}

class SmokeCigarController: FormViewController {
    
    var cigar: Cigar!
    var quantity: Int32!
    var delegate: smokeCigarViewDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(reviewCigar))
        
        self.view.tintColor = UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1)
        
       form +++ Section()
            <<< LabelRow () {
                $0.title = NSLocalizedString("Appareance", comment: "")
                $0.cellStyle = .default
                }.cellUpdate({ (cell, row) in
                    cell.textLabel?.textAlignment = .center
                })
        
            <<< SegmentedRow<String>(){
                $0.options =  ["Uniforme", "Non Uniforme", "Perfetto"]
                $0.value = "Perfetto"
                }
    }

   
    

    @objc func cancel(sender: UIBarButtonItem) {
        self.view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func reviewCigar(){
        
        dismiss(animated: true, completion: nil)
    }
}


