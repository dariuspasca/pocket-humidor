//
//  ContentViewController.swift
//  CigarStack
//
//  Created by Darius Pasca on 13/03/2018.
//  Copyright © 2018 Darius Pasca. All rights reserved.
//

import UIKit
import FlagKit
import TTGSnackbar

protocol ContainerTableDelegate {
    func dataChanged(height: CGFloat)
    func updateData(container: Tray)
}

class ContentTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, moveCigarViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var delegate: ContainerTableDelegate?
    var tray: Tray!
    var cigars: [Cigar]?
    var cigarToMoveIndex: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
        //Remove extra empty cells in TableView
        self.tableView.tableFooterView = UIView()
        self.tableView.estimatedRowHeight = 70.0
        
    }
    
    func isSelected(){
        self.view.layoutIfNeeded()
        delegate?.dataChanged(height: self.tableView.contentSize.height)
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cigars?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! ContentTableViewCell
        let cigar = cigars![indexPath.row]
        let pastDate:Date!
        if cigar.ageDate == nil {
            pastDate = cigar.creationDate!
        }
        else{
            pastDate = cigar.ageDate!
        }
        let (years, months) = computeAge(pastDate: pastDate, currentDate: Date())
        cell.quantity.text = String(cigar.quantity)
        cell.countryFlag.image =  Flag(countryCode: cigar.origin!)?.image(style: .circle)
        cell.name.text =  cigar.name!
        cell.currency.text = getSymbolForCurrencyCode(code: UserSettings.currency.value)!
        cell.price.text = String(cigar.price)
        cell.progress.image = UIImage(named: "circle")
        cell.years.text = String(years)
        cell.yearsLabel.text = NSLocalizedString("Years", comment: "")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    // MARK: - SwipeAction
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = self.contextualDeleteAction(forRowAtIndexPath: indexPath)
       // let moveAction = self.contextualMoveAction(forRowAtIndexPath: indexPath)
        let swipeConfig = UISwipeActionsConfiguration(actions: [deleteAction])
        return swipeConfig
    }
    
     func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let moveAction = self.contextualMoveAction(forRowAtIndexPath: indexPath)
        let swipeConfig = UISwipeActionsConfiguration(actions: [moveAction])
        return swipeConfig
    }
    
    // MARK: - Left SwipeAction
    func contextualDeleteAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: NSLocalizedString("Delete", comment: "")) { (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
            
            /* The item is firstly deleted from the array and only for last from the context
             This way the user can undo the delete action within a short period
             If the action hasn't been undone than the item is removed from the context
             A bool is used to rappresent user decision
             */
            
            var delete = true
            var tempCigar: Cigar!
            tempCigar = self.cigars![indexPath.row]
            self.cigars!.remove(at: indexPath.row)


            self.tableView.beginUpdates()
            self.tableView.deleteRows(at:[indexPath], with: .right)
            self.tableView.endUpdates()
            /* Undo view */
            let snackbar = TTGSnackbar(message: NSLocalizedString("Cigar deleted", comment: ""),
                                       duration: .short,
                                       actionText: NSLocalizedString("Undo", comment: ""),
                                       actionBlock: { (snackbar) in
                                        /* Undo button action*/
                                        self.cigars!.insert(tempCigar, at: indexPath.row)
                                        self.tableView.beginUpdates()
                                        self.tableView.insertRows(at: [indexPath], with: .right)
                                        self.tableView.endUpdates()
                                        
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
                    CoreDataController.sharedInstance.deleteCigar(cigar: tempCigar)
                   // self.tableView.reloadSections(NSIndexSet(index: indexPath.section) as IndexSet, with: .none)
                    self.isSelected()
                }
            }
            
            completionHandler(true)
        }
        action.backgroundColor = UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1)
        return action
    }
    
    func contextualMoveAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        
        let action = UIContextualAction(style: .normal,
                                        title: NSLocalizedString("Move", comment: "")) { (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
                                            
                                            /* Prepare the selected cigar to be sent to the segue */
                                            
                                           let vc = MoveCigarViewController()
                                           vc.cigar = self.cigars![indexPath.row]
                                           vc.delegate = self
                                           self.cigarToMoveIndex = indexPath
                                           let navigationVC = UINavigationController(rootViewController: vc)
                                           navigationVC.navigationBar.tintColor = UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1)
                                           self.present(navigationVC, animated: true, completion: nil)
                                           completionHandler(true)
        }
        
        action.backgroundColor = UIColor(red: 49/255, green: 130/255, blue: 217/255, alpha: 1)
        
        return action
    }
    
    func fetchData(){
        cigars = tray.cigars?.allObjects as? [Cigar]
    }
    
    @available(iOS 11.0, *)
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        guard let tableViewLayoutMargin = tableViewLayoutMargin else { return }
        
        tableView.layoutMargins = tableViewLayoutMargin
    }
    
    /// To support safe area, all tableViews aligned on scrollView (superview) needs to be set margin for the cell's contentView and separator.
    @available(iOS 11.0, *)
    private var tableViewLayoutMargin: UIEdgeInsets? {
        guard let superview = view.superview else {
            return nil
        }
        
        let defaultTableContentInsetLeft: CGFloat = 16
        return UIEdgeInsets(
            top: 0,
            left: superview.safeAreaInsets.left + defaultTableContentInsetLeft,
            bottom: 0,
            right: 0
        )
    }
    
    func computeAge(pastDate: Date,currentDate: Date) -> (years: Int, months: Int) {
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.month, .year], from: pastDate, to: currentDate)
        let theYears = components.year!
        let theMonths = components.month!
        return (theYears, theMonths)
    }
    
    func getSymbolForCurrencyCode(code: String) -> String?
    {
        let locale = NSLocale(localeIdentifier: code)
        return locale.displayName(forKey: NSLocale.Key.currencySymbol, value: code)
    }
    
    //MARK: - Delegates
    func moveCigarDelegate(toTray: Tray, quantity: Int32) {
        if cigarToMoveIndex != nil{
            var move = true
            let cigarToMove = cigars![cigarToMoveIndex!.row]
            let initialQuantity = cigarToMove.quantity
            let initialPRice = cigarToMove.price
            self.tableView.beginUpdates()
            if cigarToMove.quantity == quantity {
                self.cigars!.remove(at: cigarToMoveIndex!.row)
                self.tableView.deleteRows(at:[cigarToMoveIndex!], with: .none)
            }
            else{
                cigars![cigarToMoveIndex!.row].price = cigarToMove.price - (Double(quantity)*(cigarToMove.price/Double(initialQuantity)))
                cigars![cigarToMoveIndex!.row].quantity = initialQuantity - quantity
                self.tableView.reloadRows(at: [cigarToMoveIndex!], with: .none)
            }
            self.tableView.endUpdates()
            
            let snackbar = TTGSnackbar(message: NSLocalizedString("Cigar moved", comment: ""),
                                       duration: .short,
                                       actionText: NSLocalizedString("Undo", comment: ""),
                                       actionBlock: { (snackbar) in
                                        /* Undo button action*/
                                        self.tableView.beginUpdates()
                                        if initialQuantity == quantity{
                                            self.cigars!.insert(cigarToMove, at: self.cigarToMoveIndex!.row)
                                            self.tableView.insertRows(at: [self.cigarToMoveIndex!], with: .right)
                                        }
                                        else{
                                            self.cigars![self.cigarToMoveIndex!.row].quantity = cigarToMove.quantity
                                            self.tableView.reloadRows(at: [self.cigarToMoveIndex!], with: .none)
                                        }
                                        self.tableView.endUpdates()
                                        
                                        /* Set delete to false thus the context won't be changed */
                                        move = false
            })
            snackbar.backgroundColor = UIColor.darkGray
            snackbar.show()
            
            /* Action after dismiss of undo view
             Removes the item from context if user hasn't selected otherwise
             */
            snackbar.dismissBlock = {
                (snackbar: TTGSnackbar) -> Void in if (move == true) {
                    if initialQuantity == quantity{
                        CoreDataController.sharedInstance.moveCigar(destinationTray: toTray, cigar: cigarToMove)
                    }
                    else{
                        cigarToMove.quantity = initialQuantity
                        cigarToMove.price = initialPRice
                        
                        //Create copy of original cigar than update the quantity
                        let newCigar = CoreDataController.sharedInstance.addNewCigar(tray: toTray, name: cigarToMove.name!, origin: cigarToMove.origin!, quantity: initialQuantity, size: cigarToMove.size!, purchaseDate: cigarToMove.purchaseDate, from: cigarToMove.from, price: cigarToMove.price, ageDate: cigarToMove.ageDate, image: cigarToMove.image, notes: cigarToMove.notes)
                        
                        CoreDataController.sharedInstance.updateCigarQuantity(cigar: cigarToMove, quantity: quantity, add: false)
                        CoreDataController.sharedInstance.updateCigarQuantity(cigar: newCigar, quantity: cigarToMove.quantity, add: false)
                    }
                    self.isSelected()
                    self.delegate?.updateData(container: self.tray)
                }
            }
        }
    }
}



