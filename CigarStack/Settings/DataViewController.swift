//
//  DataViewController.swift
//  CigarStack
//
//  Created by Darius Pasca on 04/08/2018.
//  Copyright © 2018 Darius Pasca. All rights reserved.
//

import UIKit
import SVProgressHUD

class DataViewController: UIViewController {

    @IBOutlet weak var container: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


class ExportImportTableView: UITableViewController {
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = 44.0
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (0, 0): exportData()
        case (1, 0): print("Import")
        default: break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func exportData(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh-mm"
        
        let fileName = "CigarStack - \(UIDevice.current.name) - \(dateFormatter.string(from: Date())).cigarstack"
        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        SVProgressHUD.setDefaultStyle(.dark)
         SVProgressHUD.show(withStatus: NSLocalizedString("Generating...", comment: ""))
         var csvText = "Name,Size,Origin,Quantity,Price,From,Purchase Date,Aging Date,Notes,Creation Date,Last Edit,Gift Date,Gift To,Gift Notes,Review Date,Score,Appearance,Ash,Draw,Flavor,Strength,Texture,Review Notes,Humidor,Divisor\n"
         let cigars = CoreDataController.sharedInstance.fetchCigars()
        if cigars != nil {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .none
            dateFormatter.locale = Locale(identifier: "en_GB")
            
            for cigar in cigars! {
                
                var cigarGiftDate = ""
                var cigarReviewDate = ""
                var score = ""
                var appeareance = ""
                var ash = ""
                var draw = ""
                var flavor = ""
                var strenght = ""
                var texture = ""
                
                if cigar.review != nil || cigar.gift != nil {
                    if cigar.review != nil{
                        cigarReviewDate = dateFormatter.string(from: cigar.review!.reviewDate!)
                        score = String(cigar.review!.score)
                        appeareance = String(cigar.review!.appearance)
                        ash = String(cigar.review!.ash)
                        draw = String(cigar.review!.draw)
                        flavor = String(cigar.review!.flavour)
                        texture = String(cigar.review!.texture)
                        strenght = String(cigar.review!.strength)
                    }
                    else{
                        cigarGiftDate = dateFormatter.string(from: cigar.gift!.giftDate!)
                    }
                }
                
                
                let newLine = "\(cigar.name!),\(cigar.size!),\(cigar.origin!),\(String(cigar.quantity)),\(String(cigar.price)),\(cigar.from ?? ""),\(dateFormatter.string(from: cigar.purchaseDate!)),\(dateFormatter.string(from: cigar.ageDate!)),\(cigar.notes ?? ""),\(dateFormatter.string(from: cigar.creationDate!)),\(dateFormatter.string(from: cigar.editDate!)),\(cigarGiftDate),\(cigar.gift?.to ?? ""),\(cigar.gift?.notes ?? ""),\(cigarReviewDate), \(score), \(appeareance), \(ash), \(draw), \(flavor), \(strenght), \(texture), \(cigar.review?.notes ?? ""),\(cigar.tray!.humidor!.name!), \(cigar.tray!.name!)\n"
                csvText.append(contentsOf: newLine)
            }
            do {
                try csvText.write(to: path!, atomically: true, encoding: String.Encoding.utf8)
                let vc = UIActivityViewController(activityItems: [path!], applicationActivities: [])
                SVProgressHUD.dismiss(withDelay: 1, completion: {self.present(vc, animated: true, completion: nil)})
                
              
                
            } catch {
                let alert = UIAlertController(title: NSLocalizedString("There Is A Problem", comment: ""), message: NSLocalizedString("Sorry, something unexpected happened.If the error persists write us at support@cigarstack.app", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                print("\(error)")
            }
        }
        
    }

    
    
}
