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
    var changesStatus: [Bool]?
    
    var score: Int16?
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
        
        if cigar.review != nil{
            changesStatus = Array(repeating: false, count: 10)
            navigationItem.rightBarButtonItem?.isEnabled = false
            score = cigar.review!.score
        }
        else {
            score = 71
        }
        
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
                if cigar.review != nil {
                    $0.hidden = true
                }
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
                switch score! {
                case 0...50:
                    $0.title = NSLocalizedString("Bad", comment: "")
                case 51...60:
                   $0.title = NSLocalizedString("Poor", comment: "")
                case 61...70:
                    $0.title = NSLocalizedString("Average", comment: "")
                case 71...80:
                    $0.title = NSLocalizedString("Good", comment: "")
                case 81...90:
                   $0.title = NSLocalizedString("Very Good", comment: "")
                case 91...100:
                    $0.title = NSLocalizedString("Excellent", comment: "")
                default:
                    break
                }
                $0.cellStyle = .default
                }.cellUpdate({ (cell, row) in
                    cell.textLabel?.textAlignment = .center
                })
            
            <<< SliderRow("Vote"){
                $0.tag = "sliderVote"
                $0.displayValueFor = {
                    return String(Int($0!))
                }
                
                if cigar.review != nil {
                    $0.value = Float(cigar.review!.score)
                    
                }
                else{
                    $0.value = 71
                }
                
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
                    
                    if self.cigar.review != nil {
                        if self.cigar.review?.score != self.score {
                            self.changesStatus![0] = true
                        }
                        else{
                            self.changesStatus![0] = false
                        }
                        self.valuateSaveButonStatus()
                    }
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
                if cigar.review != nil {
                    $0.value =  Appearance(rawValue: Int(cigar.review!.appearance))!.displayName
                }
                else{
                     $0.value =  appeareance.displayName
                }
                }.onChange{row in
                    self.appeareance = Appearance(rawValue: row.cell.segmentedControl.selectedSegmentIndex)!
                    if self.cigar.review != nil {
                        if self.cigar.review?.appearance != Int16(self.appeareance.rawValue){
                            self.changesStatus![1] = true
                        }
                        else{
                            self.changesStatus![1] = false
                        }
                        self.valuateSaveButonStatus()
                    }
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
                if cigar.review != nil {
                    $0.value =  Texture(rawValue: Int(cigar.review!.texture))!.displayName
                }
                else{
                    $0.value =  texture.displayName
                }
                }.onChange{row in
                    self.texture = Texture(rawValue: row.cell.segmentedControl.selectedSegmentIndex)!
                    if self.cigar.review != nil {
                        if self.cigar.review?.texture != Int16(self.texture.rawValue){
                            self.changesStatus![2] = true
                        }
                        else{
                            self.changesStatus![2] = false
                        }
                        self.valuateSaveButonStatus()
                    }
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
                if cigar.review != nil {
                    $0.value =  Draw(rawValue: Int(cigar.review!.draw))!.displayName
                }
                else{
                    $0.value =  draw.displayName
                }
                }.onChange{row in
                    self.draw = Draw(rawValue: row.cell.segmentedControl.selectedSegmentIndex)!
                    if self.cigar.review != nil {
                        if self.cigar.review?.draw != Int16(self.draw.rawValue){
                             self.changesStatus![3] = true
                        }
                        else{
                             self.changesStatus![3] = false
                        }
                        self.valuateSaveButonStatus()
                    }
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
            if cigar.review != nil {
                $0.value =  Ash(rawValue: Int(cigar.review!.ash))!.displayName
            }
            else{
                $0.value =  ash.displayName
            }
            }.onChange{row in
                self.ash = Ash(rawValue: row.cell.segmentedControl.selectedSegmentIndex)!
                if self.cigar.review != nil {
                    if self.cigar.review?.ash != Int16(self.ash.rawValue){
                        self.changesStatus![4] = true
                    }
                    else{
                        self.changesStatus![4] = false
                    }
                    self.valuateSaveButonStatus()
                }
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
            if cigar.review != nil {
                $0.value =  Strenght(rawValue: Int(cigar.review!.strength))!.displayName
            }
            else{
                $0.value =  strength.displayName
            }
            }.onChange{row in
                self.strength = Strenght(rawValue: row.cell.segmentedControl.selectedSegmentIndex)!
                if self.cigar.review != nil {
                    if self.cigar.review?.strength != Int16(self.strength.rawValue){
                        self.changesStatus![5] = true
                    }
                    else{
                        self.changesStatus![5] = false
                    }
                    self.valuateSaveButonStatus()
                }
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
            if cigar.review != nil {
                $0.value =  Flavor(rawValue: Int(cigar.review!.flavour))!.displayName
            }
            else{
                $0.value =  flavor.displayName
            }
            }.onChange{row in
                 self.flavor = Flavor(rawValue: row.cell.segmentedControl.selectedSegmentIndex)!
                if self.cigar.review != nil {
                    if self.cigar.review?.flavour != Int16(self.flavor.rawValue){
                        self.changesStatus![6] = true
                    }
                    else{
                        self.changesStatus![6] = false
                    }
                    self.valuateSaveButonStatus()
                }
            }
        
        +++ Section()
        <<< TextAreaRow("Notes"){
            $0.placeholder = NSLocalizedString("Additional notes", comment: "")
            }.cellUpdate { cell, row in
                if self.cigar.review != nil {
                if row.value != self.cigar.review?.notes{
                    self.changesStatus![7] = true
                }
                else{
                    self.changesStatus![7] = false
                }
                self.valuateSaveButonStatus()
            }
        }
            
         +++ Section()
            <<< DateInlineRow("Date"){
                $0.title = NSLocalizedString("Date", comment: "")
                
                if cigar.review != nil {
                    $0.value = cigar.review!.reviewDate
                }
                else {
                    $0.value = Date()
                }
                $0.minimumDate = cigar.purchaseDate!
                
                }.onChange({ (row) in
                    if self.cigar.review != nil {
                        if self.cigar.review?.reviewDate != row.value {
                            self.changesStatus![8] = true
                        }
                        else{
                            self.changesStatus![8] = false
                        }
                        self.valuateSaveButonStatus()
                        
                    }
                })
        
        
    }
    
    func valuateSaveButonStatus(){
        if !changesStatus!.contains(true){
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
        else{
            navigationItem.rightBarButtonItem?.isEnabled = true
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
        let dateForm = form.rowBy(tag: "Date") as! DateInlineRow
        let review = CoreDataController.sharedInstance.createReview(score: score!, appearance: Int16(appeareance.rawValue), flavour: Int16(flavor.rawValue), ash: Int16(ash.rawValue), draw: Int16(draw.rawValue), texture: Int16(texture.rawValue), strength: Int16(strength.rawValue), notes: notes?.value, reviewDate: dateForm.value)
        
        if cigar.review != nil {
            CoreDataController.sharedInstance.deleteReview(review: cigar.review!)
            CoreDataController.sharedInstance.updateCigar(cigar: cigar, gift: nil, review: review)
        }
        
        else{
            delegate?.smokeCigarDelegate(quantity: quantity, review: review)
        }
        dismiss(animated: true, completion: nil)
    }
}



