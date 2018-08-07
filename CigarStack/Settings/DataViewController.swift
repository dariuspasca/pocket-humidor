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


class ExportImportTableView: UITableViewController, CigarCSVImporterDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = 44.0
        SVProgressHUD.setMinimumDismissTimeInterval(1)
        SVProgressHUD.setDefaultStyle(.dark)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (0, 0): exportData()
        case (1, 0): importData()
        case (2, 0): deleteAll()
        default: break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func exportData(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh-mm"
        
        let fileName = "CigarStack - \(UIDevice.current.name) - \(dateFormatter.string(from: Date())).csv"
        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        
         SVProgressHUD.show(withStatus: NSLocalizedString("Generating...", comment: ""))
         var csvText = "Name,Size,Origin,Quantity,Price,From,Purchase Date,Aging Date,Notes,Creation Date,Last Edit,Gift Date,Gift To,Gift Notes,Review Date,Score,Appearance,Ash,Draw,Flavor,Strength,Texture,Review Notes,Humidor,Humidor Humidity,Divisor\n"
         let cigars = CoreDataController.sharedInstance.fetchCigars()
        if cigars != nil {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            
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
                
                
                let newLine = "\(cigar.name!),\(cigar.size!),\(cigar.origin!),\(String(cigar.quantity)),\(String(cigar.price)),\(cigar.from ?? ""),\(dateFormatter.string(from: cigar.purchaseDate!)),\(dateFormatter.string(from: cigar.ageDate!)),\(cigar.notes ?? ""),\(dateFormatter.string(from: cigar.creationDate!)),\(dateFormatter.string(from: cigar.editDate!)),\(cigarGiftDate),\(cigar.gift?.to ?? ""),\(cigar.gift?.notes ?? ""),\(cigarReviewDate),\(score),\(appeareance),\(ash),\(draw),\(flavor),\(strenght),\(texture),\(cigar.review?.notes ?? ""),\(cigar.tray!.humidor!.name!),\(String(cigar.tray!.humidor!.humidity)),\(cigar.tray!.name!)\n"
                csvText.append(contentsOf: newLine)
            }
            do {
                try csvText.write(to: path!, atomically: true, encoding: String.Encoding.utf8)
                let vc = UIActivityViewController(activityItems: [path!], applicationActivities: [])
                vc.completionWithItemsHandler = {(activityType: UIActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
                    //User saved file
                    if completed {
                        SVProgressHUD.showInfo(withStatus: NSLocalizedString("File Saved", comment: ""))
                        return
                    }
                }
                SVProgressHUD.dismiss(withDelay: 2, completion: {self.present(vc, animated: true, completion: nil)})
                
            } catch {
                let alert = UIAlertController(title: NSLocalizedString("There Is A Problem", comment: ""), message: NSLocalizedString("Sorry, something unexpected happened.If the error persists write us at support@cigarstack.app", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                 alert.view.tintColor = UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1)
                self.present(alert, animated: true, completion: nil)
                print("\(error)")
            }
        }
    }

    
    func importData(){
        let documentImport = UIDocumentPickerViewController(documentTypes: ["public.comma-separated-values-text"], in: .import)
        documentImport.delegate = self
        documentImport.modalPresentationStyle = .formSheet
        self.present(documentImport, animated: true, completion: nil)
    }
    
    func confirmImport(fromFile: URL){
        let alert = UIAlertController(title: NSLocalizedString("Confirm Import", comment: ""), message: NSLocalizedString("Are you sure you want to import cigars from this file? Files not generated by the application are not yet supported.", comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Import", comment: ""), style: .default) { _ in
            SVProgressHUD.show(withStatus: NSLocalizedString("Importing...", comment: ""))
            let csvParser = CigarCSVImporter()
            csvParser.delegate = self
            csvParser.startImport(fromFileAt: fromFile)
        })
        
        
         alert.view.tintColor = UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    func deleteAll() {
        
        if UserSettings.currentHumidor.value == "" {
            let alert = UIAlertController(title: "", message: NSLocalizedString("There is no data to be deleted.", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default))
            alert.view.tintColor = UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1)
            present(alert,animated: true)
        }
        else {
            // The CONFIRM DELETE action:
            let confirmDelete = UIAlertController(title: NSLocalizedString("Final Warning", comment: ""), message: NSLocalizedString("This action is irreversible. Are you sure you want to continue?", comment: ""), preferredStyle: .alert)
            confirmDelete.addAction(UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .destructive) { _ in
                CoreDataController.sharedInstance.deleteAll()
                UserSettings.currentHumidor.value = ""
                UserSettings.shouldReloadView.value = true
                SVProgressHUD.showInfo(withStatus: NSLocalizedString("Deleted", comment: ""))
                
            })
            confirmDelete.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))
            confirmDelete.view.tintColor = UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1)
            // The initial WARNING action
            let areYouSure = UIAlertController(title: NSLocalizedString("Warning", comment: ""), message: NSLocalizedString("This will delete all cigars and humidors saved in the application. Are you sure you want to continue?", comment: ""), preferredStyle: .alert)
            areYouSure.addAction(UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .destructive) { _ in
                self.present(confirmDelete, animated: true)
            })
            areYouSure.addAction(UIAlertAction(title:NSLocalizedString("Cancel", comment: ""), style: .cancel))
            areYouSure.view.tintColor = UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1)
            present(areYouSure, animated: true)

        }
    }
    
    //MARK - Delegate
    
    func importFinishedUnsuccessful(message: String) {
        SVProgressHUD.dismiss(withDelay: 1)
        let alert = UIAlertController(title: NSLocalizedString("Import Failed", comment: ""), message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
    
    func importFinishedSuccessful(status: CigarCSVImportResults) {
        SVProgressHUD.dismiss(withDelay: 1, completion: {SVProgressHUD.showSuccess(withStatus: NSLocalizedString("Import completed.", comment: "") + NSLocalizedString("Successfull:", comment: "") + String(status.success) + ", " + NSLocalizedString("Duplicates:", comment: "") + String(status.duplicate) + ", " + NSLocalizedString("Errors:", comment: "") + String(status.error))})
        
        //If there were not humidors before the import sets as default the first humidor
        if UserSettings.currentHumidor.value == "" {
            let humidors = CoreDataController.sharedInstance.fetchHumidors()
            UserSettings.currentHumidor.value = humidors!.first?.name  ?? ""
            
        }
        UserSettings.shouldReloadView.value = true
    }
    
}

extension ExportImportTableView: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        confirmImport(fromFile: url)
    }
}


