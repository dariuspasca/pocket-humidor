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
    func smokeCigarDelegate(quantity: Int32,review: Review)
}

class SmokeCigarController: FormViewController {
    
    var cigar: Cigar!
    var quantity: Int32!
    var delegate: smokeCigarViewDelegate!
    
    var score: Int16 = 71
    var appeareance: Appearance = .uniform
    var texture: Texture = .spongy
    var draw: Draw = .normal
    var ash: Ash = .compact
    var strength: Strenght = .medfull
    var flavor: Flavor = .medfull

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
                    self.score = Int16(row.value!)
            }
        
      +++ Section()
            <<< LabelRow () {
                $0.title = NSLocalizedString("Appearance", comment: "")
                $0.cellStyle = .default
                }.cellUpdate({ (cell, row) in
                    cell.textLabel?.textAlignment = .center
                })
        
            <<< SegmentedRow<String>(){
                $0.options =  [Appearance.veins.displayName, Appearance.notUniform.displayName, Appearance.uniform.displayName, Appearance.perfect.displayName]
                $0.value = appeareance.displayName
                }.onChange{row in
                    self.appeareance = Appearance(rawValue: row.cell.segmentedControl.selectedSegmentIndex)!
            }
       +++ Section()
            <<< LabelRow () {
                $0.title = NSLocalizedString("Texture", comment: "")
                $0.cellStyle = .default
                }.cellUpdate({ (cell, row) in
                    cell.textLabel?.textAlignment = .center
                })
            
            <<< SegmentedRow<String>(){
               $0.options =  [Texture.crumbly.displayName, Texture.dry.displayName, Texture.spongy.displayName, Texture.perfect.displayName]
                $0.value = texture.displayName
                }.onChange{row in
                    self.texture = Texture(rawValue: row.cell.segmentedControl.selectedSegmentIndex)!
            }
        
       +++ Section()
            <<< LabelRow () {
                $0.title = NSLocalizedString("Draw", comment: "")
                $0.cellStyle = .default
                }.cellUpdate({ (cell, row) in
                    cell.textLabel?.textAlignment = .center
                })
            
            <<< SegmentedRow<String>(){
                $0.options =  [Draw.hard.displayName, Draw.tight.displayName, Draw.normal.displayName, Draw.excellent.displayName]
                $0.value = draw.displayName
                }.onChange{row in
                    self.draw = Draw(rawValue: row.cell.segmentedControl.selectedSegmentIndex)!
            }
        +++ Section()
        <<< LabelRow () {
            $0.title = NSLocalizedString("Ash", comment: "")
            $0.cellStyle = .default
            }.cellUpdate({ (cell, row) in
                cell.textLabel?.textAlignment = .center
            })
        
        <<< SegmentedRow<String>(){
            $0.options =  [Ash.britlte.displayName, Ash.normal.displayName, Ash.compact.displayName, Ash.solid.displayName]
            $0.value = ash.displayName
            }.onChange{row in
                self.ash = Ash(rawValue: row.cell.segmentedControl.selectedSegmentIndex)!
            }
        +++ Section()
        <<< LabelRow () {
            $0.title = NSLocalizedString("Strength", comment: "")
            $0.cellStyle = .default
            }.cellUpdate({ (cell, row) in
                cell.textLabel?.textAlignment = .center
            })
        
        <<< SegmentedRow<String>(){
            $0.options =  [Strenght.light.displayName, Strenght.medium.displayName, Strenght.medfull.displayName, Strenght.full.displayName]
            $0.value = strength.displayName
            }.onChange{row in
                self.strength = Strenght(rawValue: row.cell.segmentedControl.selectedSegmentIndex)!
            }
        +++ Section()
        <<< LabelRow () {
            $0.title = NSLocalizedString("Flavor", comment: "")
            $0.cellStyle = .default
            }.cellUpdate({ (cell, row) in
                cell.textLabel?.textAlignment = .center
            })
            
        <<< SegmentedRow<String>(){
            $0.options =  [Flavor.light.displayName, Flavor.medium.displayName, Flavor.medfull.displayName, Flavor.full.displayName]
            $0.value = flavor.displayName
            }.onChange{row in
                 self.flavor = Flavor(rawValue: row.cell.segmentedControl.selectedSegmentIndex)!
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
        let notes = form.rowBy(tag: "Notes") as? TextAreaRow
         let review = CoreDataController.sharedInstance.createReview(score: score, appearance: Int16(appeareance.rawValue), flavour: Int16(flavor.rawValue), ash: Int16(ash.rawValue), draw: Int16(draw.rawValue), texture: Int16(texture.rawValue), strength: Int16(strength.rawValue), notes: notes?.value)
        
        
        delegate?.smokeCigarDelegate(quantity: quantity, review: review)
        dismiss(animated: true, completion: nil)
    }
}



