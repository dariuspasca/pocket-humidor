//
//  CigarDetailViewController.swift
//  CigarStack
//
//  Created by Darius Pasca on 17/07/2018.
//  Copyright © 2018 Darius Pasca. All rights reserved.
//

import UIKit
import CoreData
import FlagKit

class CigarDetailViewController: UIViewController {
    
    var cigar: Cigar!
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var nameViewHeight: NSLayoutConstraint!
    
    
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var notesView: UITextView!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var pricePerCigarLabel: UILabel!
    @IBOutlet weak var priceTotalLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var ageDateLabel: UILabel!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var fromDateLabel: UILabel!
    @IBOutlet weak var addedOn: UILabel!
    
    
    //Gift
    @IBOutlet weak var giftedStack: UIStackView!
    @IBOutlet weak var giftedToLabel: UILabel!
    @IBOutlet weak var giftedDateLabel: UILabel!
    @IBOutlet weak var giftNotes: UITextView!
    @IBOutlet weak var giftNotesStack: UIStackView!
    
    //Review
    @IBOutlet weak var reviewStack: UIStackView!
    @IBOutlet weak var rate: UILabel!
    @IBOutlet weak var appearance: UILabel!
    @IBOutlet weak var texture: UILabel!
    @IBOutlet weak var draw: UILabel!
    @IBOutlet weak var ash: UILabel!
    @IBOutlet weak var strength: UILabel!
    @IBOutlet weak var flavor: UILabel!
    @IBOutlet weak var reviewNotes: UITextView!
    @IBOutlet weak var reviewNotesStack: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let font = UIFont.systemFont(ofSize: 21.0, weight: .semibold)
        nameViewHeight.constant = heightForView(text: cigar.name!, font: font, width: nameLabel.frame.width)
        
        notesView.isScrollEnabled = false
        notesView.text = cigar.notes ?? NSLocalizedString("No notes", comment: "")
        notesView.sizeToFit()
       
 
        sizeLabel.text = cigar.size
        nameLabel.text = cigar.name
        countryLabel.text = Locale.current.localizedString(forRegionCode: cigar.origin!)
        
        quantityLabel.text = String(cigar.quantity)
        
        if cigar.quantity < 2 {
            pricePerCigarLabel.text = cigar.price.asLocalCurrency
        }
        else{
            let price = cigar.price/Double(cigar.quantity)
            let priceRounded = Double(round(1000*price)/1000)
            pricePerCigarLabel.text = String(priceRounded.asLocalCurrency)
        }
        priceTotalLabel.text = cigar.price.asLocalCurrency
        
        fromLabel.text = cigar.from ?? "N/A"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale.current
        fromDateLabel.text = dateFormatter.string(from: cigar.purchaseDate!).capitalized
        addedOn.text = dateFormatter.string(from: cigar.creationDate!).capitalized
        ageDateLabel.text = dateFormatter.string(from: cigar.ageDate!).capitalized
        
        
        let (years, months) = computeAge(pastDate: cigar.ageDate!, currentDate: Date())
        if years == 1 {
            if months == 1 {
                ageLabel.text = String(years) + " " + NSLocalizedString("Year", comment: "") + " / " + String(months) + " " + NSLocalizedString("Month", comment: "")
            }
            else{
                ageLabel.text = String(years) + " " + NSLocalizedString("Year", comment: "") + " / " + String(months) + " " + NSLocalizedString("Months", comment: "")
            }
        }
        else{
            if months == 1 {
                ageLabel.text = String(years) + " " + NSLocalizedString("Years", comment: "") + " / " + String(months) + " " + NSLocalizedString("Month", comment: "")
            }
            else{
                ageLabel.text = String(years) + " " + NSLocalizedString("Years", comment: "") + " / " + String(months) + " " + NSLocalizedString("Months", comment: "")
            }
        }
        if cigar.gift != nil || cigar.review != nil {
            if cigar.gift != nil {
                reviewStack.isHidden = true
                giftedStack.isHidden = false
                giftedToLabel.text = cigar.gift!.to!
                giftedDateLabel.text = dateFormatter.string(from: cigar.gift!.giftDate!).capitalized
                
                if cigar.gift?.notes != nil {
                    giftNotes.isScrollEnabled = false
                    giftNotes.text = cigar.gift!.notes
                    giftNotes.sizeToFit()
                }
                else{
                    giftNotesStack.isHidden=true
                }
            }
            else{
                reviewStack.isHidden = false
                giftedStack.isHidden = true
                rate.text = String(cigar.review!.score) + " / 100"

                appearance.text = Appearance(rawValue: Int(cigar.review!.appearance))?.displayName
                texture.text = Texture(rawValue: Int(cigar.review!.texture))?.displayName
                draw.text = Draw(rawValue: Int(cigar.review!.draw))?.displayName
                ash.text = Ash(rawValue: Int(cigar.review!.ash))?.displayName
                strength.text = Strenght(rawValue: Int(cigar.review!.strength))?.displayName
                flavor.text = Flavor(rawValue: Int(cigar.review!.flavour))?.displayName
                
                if cigar.review?.notes != nil {
                    reviewNotes.isScrollEnabled = false
                    reviewNotes.text = cigar.review!.notes
                    reviewNotes.sizeToFit()
                }
                else{
                    reviewNotesStack.isHidden=true
                }
            }
        }
        else{
            giftedStack.isHidden = true
            reviewStack.isHidden = true
        }
        
        
        
      
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func deleteCigar(_ sender: UIButton) {
        let alert = UIAlertController(title: NSLocalizedString("Do you want to delete this cigar?", comment: ""), message: NSLocalizedString("Your cannot undo this action.", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .destructive, handler: delete))
        self.present(alert, animated: true, completion: nil)
    }
    
    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return label.frame.height
    }
    
    func delete(alert: UIAlertAction){
        CoreDataController.sharedInstance.deleteCigar(cigar: cigar, withUpdate: true)
        UserSettings.shouldReloadData.value = true
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func editCigar(_ sender: UIButton) {
        if cigar.gift != nil || cigar.review != nil {
            if cigar.gift != nil{
                let vc = GiftCigarController()
                vc.cigar = cigar
                let navigationController = UINavigationController(rootViewController: vc)
                navigationController.navigationBar.tintColor = UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1)
                
                navigationController.modalPresentationStyle = .formSheet
                navigationController.modalTransitionStyle = .coverVertical
                self.present(navigationController, animated: true, completion: nil)
            }
            else{
                let vc = SmokeCigarController()
                vc.cigar = cigar
                
                let navigationController = UINavigationController(rootViewController: vc)
                navigationController.navigationBar.tintColor = UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1)
                
                navigationController.modalPresentationStyle = .formSheet
                navigationController.modalTransitionStyle = .coverVertical
                
                
                self.present(navigationController, animated: true, completion: nil)
            }
        }
        else {
            let destVC = UIStoryboard(name: "NewCigar", bundle: nil).instantiateInitialViewController() as! UINavigationController
            let vc = destVC.topViewController as! AddCigarController
            vc.cigarToEdit = cigar
            destVC.modalPresentationStyle = .formSheet
            destVC.modalTransitionStyle = .coverVertical
        
            if UIDevice.current.userInterfaceIdiom == .pad{
                destVC.preferredContentSize = CGSize(width: 500, height: 700)
            }
            present(destVC, animated: true, completion: nil)
        }
    }
  
    
    @IBAction func cancel(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    
    func computeAge(pastDate: Date,currentDate: Date) -> (years: Int, months: Int) {
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.month, .year], from: pastDate, to: currentDate)
        let theYears = components.year!
        let theMonths = components.month!
        return (theYears, theMonths)
    }

}
