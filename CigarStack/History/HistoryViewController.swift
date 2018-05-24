//
//  HistoryViewController.swift
//  CigarStack
//
//  Created by Darius Pasca on 17/05/2018.
//  Copyright © 2018 Darius Pasca. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import FlagKit
import TTGSnackbar

struct history {
    var name: Date
    var cigars: [Cigar]
    
    init(name: Date, cigars: [Cigar]) {
        self.name = name
        self.cigars = cigars
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = history (name: name, cigars: cigars)
        return copy
    }
}

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    @IBOutlet weak var tableView: UITableView!
    var data:[history]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
       prepareData()
    }

    
    // MARK: - TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return data?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data![section].cigars.count
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCell(withIdentifier: "headerIdentifier")! as! HistoryHeaderTableViewCell
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale.current
        
        header.date.text = dateFormatter.string(from: data![section].name).capitalized
        
        dateFormatter.dateFormat = "EEEE"
        
        header.day.text = dateFormatter.string(from: data![section].name).capitalized
        
        return header.contentView
    
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! HistoryTableViewCell
        let cigar = data![indexPath.section].cigars[indexPath.row]
        let pastDate = cigar.ageDate!
        let (years, months) = computeAge(pastDate: pastDate, currentDate: Date())
        
        var percentage = Double(months)/12
        if years > 0 && months == 0 {
            percentage = 0.01
        }
        
        let progressCircle = circleView(frame: CGRect(x: 0, y: 0, width: cell.progress.frame.width, height: cell.progress.frame.height), percent: percentage)
        if cigar.quantity > 99 {
            cell.quantity.text = "+99"
            cell.quantity.font = cell.quantity.font.withSize(12)
        }
        else{
            cell.quantity.text = String(cigar.quantity)
        }
        cell.countryFlag.image =  Flag(countryCode: cigar.origin!)?.image(style: .circle)
        cell.name.text =  cigar.name!
        cell.size.text = cigar.size!
        cell.progress.addSubview(progressCircle)
        cell.years.text = String(years)
        cell.yearsLabel.text = NSLocalizedString("Years", comment: "")
        
        if cigar.review != nil {
            cell.status.text = NSLocalizedString("Rating", comment: "")
            cell.statusDetail.text = String(cigar.review!.score) + " / 100"
         }
        else{
            cell.status.text = NSLocalizedString("Gifted to", comment: "")
            cell.statusDetail.text = cigar.gift!.to!
         }
        return cell
    }
    
    
    func prepareData(){
        //fetch all cigars that have a review or gift object
        let cigars = CoreDataController.sharedInstance.fetchCigarHistory()
        
        if cigars != nil{
            
        let sortedCigars = cigars!.sorted(by: { ($0.gift?.giftDate ?? $0.review!.reviewDate!) > ($1.gift?.giftDate ?? $1.review!.reviewDate!) })
            
        for cigar in sortedCigars{
            let cigarDate = cigar.review?.reviewDate ?? cigar.gift?.giftDate
            
            //Data is empty
            if data == nil{
                    data = [history]()
                    data?.append(history(name: cigarDate!, cigars: [cigar]))
            }
                
            // Search
            else{
                var found = false
                //Search for Date
                for (index, record) in data!.enumerated() {
                    if compareDate(date1: record.name, date2: cigarDate!){
                        var currentCigars = record.cigars
                        currentCigars.append(cigar)
                        data!.remove(at: index)
                        data?.append(history(name: cigarDate!, cigars: currentCigars))
                        found = true
                        break
                    }
                }
                    
                //If not found creates record
                if !found{
                    data?.append(history(name: cigarDate!, cigars: [cigar]))
                }
            }
        }
        }
        
    }
    
    //MARK - Delete Swipe
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = self.contextualDeleteAction(forRowAtIndexPath: indexPath)
        let swipeConfig = UISwipeActionsConfiguration(actions: [deleteAction])
        return swipeConfig
    }
    
    
    func contextualDeleteAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: NSLocalizedString("Delete", comment: "")) { (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
            
            var delete = true
            var section = self.data![indexPath.section].copy() as! history
            
            if section.cigars.count > 1 {
                self.data!.remove(at: indexPath.section)
                
                var newArray = section.cigars
                newArray.remove(at: indexPath.row)
                self.data!.insert(history(name: section.name, cigars: newArray), at: indexPath.section)
                
                self.tableView.beginUpdates()
                self.tableView.deleteRows(at:[indexPath], with: .right)
                self.tableView.endUpdates()
            }
            else{
                self.data!.remove(at: indexPath.section)
                
                self.tableView.beginUpdates()
                self.tableView.deleteSections([indexPath.section], with: .right)
                self.tableView.endUpdates()
            }
            
            /* Undo view */
            let snackbar = TTGSnackbar(message: NSLocalizedString("Cigar deleted", comment: ""),
                                       duration: .middle,
                                       actionText: NSLocalizedString("Undo", comment: ""),
                                       actionBlock: { (snackbar) in
                                        /* Undo button action*/
                                        
                                        if section.cigars.count > 1 {
                                            self.data!.remove(at: indexPath.section)
                                            self.data!.insert(section, at: indexPath.section)
                                            self.tableView.beginUpdates()
                                            self.tableView.insertRows(at: [indexPath], with: .right)
                                            self.tableView.endUpdates()
                                        }
                                        else{
                                            self.data!.insert(section, at: indexPath.section)
                                            self.tableView.beginUpdates()
                                            self.tableView.insertSections([indexPath.section], with: .right)
                                            self.tableView.endUpdates()
                                        }

                                        
                                        /* Set delete to false thus the context won't be changed */
                                        delete = false
            })
            snackbar.backgroundColor = UIColor.darkGray
            snackbar.show()
            
            /* Action after dismiss of undo view
             Removes the item from context if user hasn't selected otherwise
             */
            snackbar.dismissBlock = {
                (snackbar: TTGSnackbar) -> Void in if (delete == true) {
                    CoreDataController.sharedInstance.deleteCigar(cigar: section.cigars[indexPath.row], withUpdate: false)
                }
            }
            self.tableView.setEditing(false, animated: true)
            completionHandler(true)
        }
        
        action.backgroundColor = UIColor(red: 255/255, green: 59/255, blue: 48/255, alpha: 1)
        return action
    }

    func computeAge(pastDate: Date,currentDate: Date) -> (years: Int, months: Int) {
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.month, .year], from: pastDate, to: currentDate)
        let theYears = components.year!
        let theMonths = components.month!
        return (theYears, theMonths)
    }
    
    func compareDate(date1:Date, date2:Date) -> Bool {
        let order = NSCalendar.current.compare(date1, to: date2, toGranularity: .day)
        switch order {
        case .orderedSame:
            return true
        default:
            return false
        }
    }
 

}
