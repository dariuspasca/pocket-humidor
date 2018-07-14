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
    func smokeCigarDelegate(quantity: Int32,review: [String:Int16], notes: String?)
}

class SmokeCigarController: FormViewController {
    
    var cigar: Cigar!
    var quantity: Int32!
    var delegate: smokeCigarViewDelegate!
    
    /* Some SegmentedRows returns as selectedIndex -1 if they are not changed by the user. This way I avoid this problem by giving default values that are changed only when the user interacts with the segmentedrow*/
    var review: [String: Int16] = ["score": 71, "appearance": 2, "texture": 2, "draw": 2, "ash": 2, "strength": 2, "flavor": 2]

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(reviewCigar))
        
        navigationAccessoryView = {
            let naview = CustomNavigationAccessoryView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44.0))
            naview.tintColor = UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1)
            naview.doneButton.target = self
            naview.doneButton.action = #selector(dismisskeyboard)
            return naview
        }()
        
        self.view.tintColor = UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1)
        quantity = 1
        
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
                for i in 1...Int(cigar.quantity){
                    options.append("\(i)")
                }
                $0.value = options.first!
                $0.options = options
                }.cellSetup { cell, row in cell.tintColor = UIColor.black }.cellUpdate { cell, row in
                    self.quantity = Int32(row.value!)
            }
            
            
        +++ Section(header: NSLocalizedString("How would you rate it?", comment: ""), footer: "")
            <<< LabelRow () {
                $0.tag = "reviewTitle"
                $0.title = NSLocalizedString("Good", comment: "")
                $0.cellStyle = .default
                }.cellUpdate({ (cell, row) in
                    cell.textLabel?.textAlignment = .center
                })
            
            <<< SliderRow("Vote"){
                $0.tag = "sliderVote"
                $0.displayValueFor = {
                    return String(Int($0!))
                }
                
                $0.value = 71
                $0.steps = 100
                $0.maximumValue = 100
                $0.minimumValue = 0
                }.cellSetup({ (cell, row) in
                    cell.height = ({return 80})
                }).onChange { row in
                    let titleRow = self.form.rowBy(tag: "reviewTitle") as! LabelRow?
                    
                    switch row.value! {
                    case 0...50:
                        titleRow?.title = NSLocalizedString("Bad", comment: "")
                    case 51...60:
                        titleRow?.title = NSLocalizedString("Poor", comment: "")
                    case 61...70:
                        titleRow?.title = NSLocalizedString("Average", comment: "")
                    case 71...80:
                        titleRow?.title = NSLocalizedString("Good", comment: "")
                    case 81...90:
                        titleRow?.title = NSLocalizedString("Very Good", comment: "")
                    case 91...100:
                        titleRow?.title = NSLocalizedString("Excellent", comment: "")
                    default:
                        break
                    }
                    titleRow?.updateCell()
                    self.review["score"] = Int16(row.value!)
            }
        
      +++ Section()
            <<< LabelRow () {
                $0.title = NSLocalizedString("Appearance", comment: "")
                $0.cellStyle = .default
                }.cellUpdate({ (cell, row) in
                    cell.textLabel?.textAlignment = .center
                })
        
            <<< SegmentedRow<String>(){
                $0.options =  [NSLocalizedString("Veins", comment: ""), NSLocalizedString("Not Uniform", comment: ""), NSLocalizedString("Uniform", comment: ""), NSLocalizedString("Perfect", comment: "")]
                $0.value = NSLocalizedString("Uniform", comment: "")
                }.onChange{row in
                    self.review["appearance"] = Int16(row.cell.segmentedControl.selectedSegmentIndex)
            }
       +++ Section()
            <<< LabelRow () {
                $0.title = NSLocalizedString("Texture", comment: "")
                $0.cellStyle = .default
                }.cellUpdate({ (cell, row) in
                    cell.textLabel?.textAlignment = .center
                })
            
            <<< SegmentedRow<String>(){
               $0.options =  [NSLocalizedString("Crumbly", comment: ""), NSLocalizedString("Dry", comment: ""), NSLocalizedString("Spongy", comment: ""), NSLocalizedString("Perfect", comment: "")]
                $0.value = NSLocalizedString("Spongy", comment: "")
                }.onChange{row in
                    self.review["texture"] = Int16(row.cell.segmentedControl.selectedSegmentIndex)
            }
        
       +++ Section()
            <<< LabelRow () {
                $0.title = NSLocalizedString("Draw", comment: "")
                $0.cellStyle = .default
                }.cellUpdate({ (cell, row) in
                    cell.textLabel?.textAlignment = .center
                })
            
            <<< SegmentedRow<String>(){
                $0.options =  [NSLocalizedString("Hard", comment: ""), NSLocalizedString("Tight", comment: ""), NSLocalizedString("Normal", comment: ""), NSLocalizedString("Excellent", comment: "")]
                $0.value = NSLocalizedString("Normal", comment: "")
                }.onChange{row in
                    self.review["draw"] = Int16(row.cell.segmentedControl.selectedSegmentIndex)
            }
        +++ Section()
        <<< LabelRow () {
            $0.title = NSLocalizedString("Ash", comment: "")
            $0.cellStyle = .default
            }.cellUpdate({ (cell, row) in
                cell.textLabel?.textAlignment = .center
            })
        
        <<< SegmentedRow<String>(){
            $0.options =  [NSLocalizedString("Britlte", comment: ""), NSLocalizedString("Normal", comment: ""), NSLocalizedString("Compact", comment: ""), NSLocalizedString("Solid", comment: "")]
            $0.value = NSLocalizedString("Compact", comment: "")
            }.onChange{row in
                self.review["ash"] = Int16(row.cell.segmentedControl.selectedSegmentIndex)
            }
        +++ Section()
        <<< LabelRow () {
            $0.title = NSLocalizedString("Strength", comment: "")
            $0.cellStyle = .default
            }.cellUpdate({ (cell, row) in
                cell.textLabel?.textAlignment = .center
            })
        
        <<< SegmentedRow<String>(){
            $0.options =  [NSLocalizedString("Light", comment: ""), NSLocalizedString("Medium", comment: ""), NSLocalizedString("Med-Full", comment: ""), NSLocalizedString("Full", comment: "")]
            $0.value = NSLocalizedString("Med-Full", comment: "")
            }.onChange{row in
                self.review["strength"] = Int16(row.cell.segmentedControl.selectedSegmentIndex)
            }
        +++ Section()
        <<< LabelRow () {
            $0.title = NSLocalizedString("Flavor", comment: "")
            $0.cellStyle = .default
            }.cellUpdate({ (cell, row) in
                cell.textLabel?.textAlignment = .center
            })
            
        <<< SegmentedRow<String>(){
            $0.options =  [NSLocalizedString("Light", comment: ""), NSLocalizedString("Medium", comment: ""), NSLocalizedString("Med-Full", comment: ""), NSLocalizedString("Full", comment: "")]
            $0.value = NSLocalizedString("Med-Full", comment: "")
            }.onChange{row in
                self.review["flavor"] = Int16(row.cell.segmentedControl.selectedSegmentIndex)
            }
        
        +++ Section()
        <<< TextAreaRow("Notes"){
            $0.placeholder = NSLocalizedString("Additional notes", comment: "")
            }
        
        
    }

    @objc func dismisskeyboard() {
        view.endEditing(true)
    }
    

    @objc func cancel(sender: UIBarButtonItem) {
        self.view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func reviewCigar(){
        let notes = form.rowBy(tag: "notes") as? TextAreaRow
        
        delegate?.smokeCigarDelegate(quantity: quantity, review: review, notes: notes?.value)
        dismiss(animated: true, completion: nil)
    }
}


