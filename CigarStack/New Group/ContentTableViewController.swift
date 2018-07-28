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
    func presentCigarDetailSegue(cigar: Cigar)
    func updateHumidorView()
}

class ContentTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, moveCigarViewDelegate, giftCigarViewDelegate, smokeCigarViewDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    var delegate: ContainerTableDelegate?
    var tray: Tray!
    var cigars: [Cigar]?
    var cigarIndex: IndexPath?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
        cigars = sortData(ascending: UserSettings.sortAscending.value)
        //Remove extra empty cells in TableView
        self.tableView.tableFooterView = UIView()
        self.tableView.estimatedRowHeight = 70.0
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tableView.setEditing(false, animated: false)
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
        cell.price.text = cigar.price.asLocalCurrency
        cell.size.text = cigar.size!
        cell.progress.addSubview(progressCircle)
        cell.years.text = String(years)
        cell.yearsLabel.text = NSLocalizedString("Years", comment: "")
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    //Paging Kit
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
    
    // MARK: - SwipeAction
    
    //Right
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = self.contextualDeleteAction(forRowAtIndexPath: indexPath)
        let smokeAction = self.contextualSmokeAction(forRowAtIndexPath: indexPath)
        let giftAction = self.contextualGiftAction(forRowAtIndexPath: indexPath)
        let swipeConfig = UISwipeActionsConfiguration(actions: [deleteAction, smokeAction, giftAction])
        return swipeConfig
    }
    
    //Left
     func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if CoreDataController.sharedInstance.countHumidors() > 1 || (tray.humidor?.trays?.count)! > 1{
            let moveAction = self.contextualMoveAction(forRowAtIndexPath: indexPath)
            let swipeConfig = UISwipeActionsConfiguration(actions: [moveAction])
            return swipeConfig
        }
        else{
            return nil
        }
        
    }

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
            self.isSelected()
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
                                        self.isSelected()
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
                    CoreDataController.sharedInstance.deleteCigar(cigar: tempCigar, withUpdate: true)
                    self.delegate?.updateHumidorView()
                }
            }
            self.tableView.setEditing(false, animated: true)
            completionHandler(true)
        }

        action.backgroundColor = UIColor(red: 255/255, green: 59/255, blue: 48/255, alpha: 1)
        return action
    }
    
    func contextualGiftAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal,
                                        title: NSLocalizedString("Gift", comment: "")) { (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
                                            
                                            /* Prepare the selected cigar to be sent to the segue */
                                            self.cigarIndex = indexPath
                                            let vc = GiftCigarController()
                                            vc.cigar = self.cigars![indexPath.row]
                                            vc.delegate = self
                                            
                                            let navigationController = UINavigationController(rootViewController: vc)
                                            navigationController.navigationBar.tintColor = UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1)
                                            
                                            navigationController.modalPresentationStyle = .formSheet
                                            navigationController.modalTransitionStyle = .coverVertical

                                            
                                            self.present(navigationController, animated: true, completion: nil)
                                            self.tableView.setEditing(false, animated: true)
                                            completionHandler(true)
        }
        
        action.backgroundColor = UIColor(red: 255/255, green: 108/255, blue: 136/255, alpha: 1)
        
        return action
    }
    
    func contextualSmokeAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal,
                                        title: NSLocalizedString("Smoke", comment: "")) { (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
                                            
                                            /* Prepare the selected cigar to be sent to the segue */
                                            self.cigarIndex = indexPath
                                            let vc = SmokeCigarController()
                                            vc.cigar = self.cigars![indexPath.row]
                                            vc.delegate = self
                                            
                                            let navigationController = UINavigationController(rootViewController: vc)
                                            navigationController.navigationBar.tintColor = UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1)
                                            
                                            navigationController.modalPresentationStyle = .formSheet
                                            navigationController.modalTransitionStyle = .coverVertical
                                            
                                            
                                            self.present(navigationController, animated: true, completion: nil)
                                            self.tableView.setEditing(false, animated: true)
                                            completionHandler(true)
        }
        
        action.backgroundColor = UIColor(red: 255/255, green: 149/255, blue: 0/255, alpha: 1)
        
        return action
    }
    
    
    func contextualMoveAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal,
                                        title: NSLocalizedString("Move", comment: "")) { (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
                                            
                                            /* Prepare the selected cigar to be sent to the segue */
                                            self.cigarIndex = indexPath
                                            let vc = MoveCigarViewController()
                                            vc.cigar = self.cigars![self.cigarIndex!.row]
                                            vc.delegate = self
                                            
                                            let navigationController = UINavigationController(rootViewController: vc)
                                            navigationController.navigationBar.tintColor = UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1)
                                            
                                            navigationController.modalPresentationStyle = .formSheet
                                            navigationController.modalTransitionStyle = .coverVertical
                                            
                                            self.present(navigationController, animated: true, completion: nil)
                                            self.tableView.setEditing(false, animated: true)
                                            completionHandler(true)
        }
        
        action.backgroundColor = UIColor(red: 49/255, green: 130/255, blue: 217/255, alpha: 1)
        return action
    }
    
    func moveCigarDelegate(toTray: Tray, quantity: Int32) {
        if cigarIndex != nil{
            var move = true
            /* Better implementation using .copy */
            let cigarToMove = cigars![cigarIndex!.row]
            let initialQuantity = cigarToMove.quantity
            let initialPrice = cigarToMove.price
            self.tableView.beginUpdates()
            if cigarToMove.quantity == quantity {
                self.cigars!.remove(at: cigarIndex!.row)
                self.tableView.deleteRows(at:[cigarIndex!], with: .none)
            }
            else{
                cigars![cigarIndex!.row].price = cigarToMove.price - (Double(quantity)*(cigarToMove.price/Double(initialQuantity)))
                cigars![cigarIndex!.row].quantity = initialQuantity - quantity
                self.tableView.reloadRows(at: [cigarIndex!], with: .none)
            }
            self.tableView.endUpdates()
            self.isSelected()
            
            let snackbar = TTGSnackbar(message: NSLocalizedString("Cigar moved", comment: ""),
                                       duration: .short,
                                       actionText: NSLocalizedString("Undo", comment: ""),
                                       actionBlock: { (snackbar) in
                                        /* Undo button action*/
                                        self.tableView.beginUpdates()
                                        if initialQuantity == quantity{
                                            self.cigars!.insert(cigarToMove, at: self.cigarIndex!.row)
                                            self.tableView.insertRows(at: [self.cigarIndex!], with: .right)
                                        }
                                        else{
                                            self.cigars![self.cigarIndex!.row].quantity = initialQuantity
                                            self.cigars![self.cigarIndex!.row].price = initialPrice
                                            self.tableView.reloadRows(at: [self.cigarIndex!], with: .none)
                                        }
                                        self.tableView.endUpdates()
                                        self.isSelected()
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
                        cigarToMove.price = initialPrice
                        
                        //Create copy of original cigar than update the quantity
                        let newCigar = CoreDataController.sharedInstance.addNewCigar(tray: toTray, name: cigarToMove.name!, origin: cigarToMove.origin!, quantity: initialQuantity, size: cigarToMove.size!, purchaseDate: cigarToMove.purchaseDate, from: cigarToMove.from, price: cigarToMove.price, ageDate: cigarToMove.ageDate, image: cigarToMove.image, notes: cigarToMove.notes)
                        
                        CoreDataController.sharedInstance.updateCigarQuantity(cigar: cigarToMove, quantity: quantity, add: false)
                        CoreDataController.sharedInstance.updateCigarQuantity(cigar: newCigar, quantity: cigarToMove.quantity, add: false)
                    }
                    self.delegate?.updateData(container: self.tray)
                }
            }
        }
    }
    
    func giftCigarDelegate(to: String, notes: String?, quantity: Int32){
        if cigarIndex != nil{
            var gift = true
            /* Better implementation using .copy */
            let cigarToGift = cigars![cigarIndex!.row]
            let initialQuantity = cigarToGift.quantity
            let initialPrice = cigarToGift.price
            self.tableView.beginUpdates()
            if cigarToGift.quantity == quantity {
                self.cigars!.remove(at: cigarIndex!.row)
                self.tableView.deleteRows(at:[cigarIndex!], with: .none)
            }
            else{
                cigars![cigarIndex!.row].price = cigarToGift.price - (Double(quantity)*(cigarToGift.price/Double(initialQuantity)))
                cigars![cigarIndex!.row].quantity = initialQuantity - quantity
                self.tableView.reloadRows(at: [cigarIndex!], with: .none)
            }
            self.tableView.endUpdates()
            self.isSelected()
            
            let snackbar = TTGSnackbar(message: NSLocalizedString("Cigar gifted", comment: ""),
                                       duration: .short,
                                       actionText: NSLocalizedString("Undo", comment: ""),
                                       actionBlock: { (snackbar) in
                                        /* Undo button action*/
                                        self.tableView.beginUpdates()
                                        if initialQuantity == quantity{
                                            self.cigars!.insert(cigarToGift, at: self.cigarIndex!.row)
                                            self.tableView.insertRows(at: [self.cigarIndex!], with: .right)
                                        }
                                        else{
                                            self.cigars![self.cigarIndex!.row].quantity = initialQuantity
                                            self.cigars![self.cigarIndex!.row].price = initialPrice
                                            self.tableView.reloadRows(at: [self.cigarIndex!], with: .none)
                                        }
                                        self.tableView.endUpdates()
                                        self.isSelected()
                                        /* Set delete to false thus the context won't be changed */
                                        gift = false
            })
            snackbar.backgroundColor = UIColor.darkGray
            snackbar.show()
            
            /* Action after dismiss of undo view
             Removes the item from context if user hasn't selected otherwise
             */
            snackbar.dismissBlock = {
                (snackbar: TTGSnackbar) -> Void in if (gift == true) {
                    let gift = CoreDataController.sharedInstance.createGift(to: to, notes: notes)
                    if initialQuantity == quantity {
                        CoreDataController.sharedInstance.updateCigar(cigar: cigarToGift, gift: gift, review: nil)
                        CoreDataController.sharedInstance.updateHumidorValues(tray: cigarToGift.tray!, quantity: cigarToGift.quantity, value: cigarToGift.price, add: false)
                    }
                    else{
                        cigarToGift.quantity = initialQuantity
                        cigarToGift.price = initialPrice
                        
                        //Create copy of original cigar than update the quantity
                        let newCigar = CoreDataController.sharedInstance.addNewCigar(tray: cigarToGift.tray!, name: cigarToGift.name!, origin: cigarToGift.origin!, quantity: quantity, size: cigarToGift.size!, purchaseDate: cigarToGift.purchaseDate, from: cigarToGift.from, price: (Double(quantity)*(cigarToGift.price/Double(cigarToGift.quantity))), ageDate: cigarToGift.ageDate, image: cigarToGift.image, notes: cigarToGift.notes)
                        
                        CoreDataController.sharedInstance.updateCigarQuantity(cigar: cigarToGift, quantity: quantity, add: false)
                        CoreDataController.sharedInstance.updateHumidorValues(tray: newCigar.tray!, quantity: newCigar.quantity, value: newCigar.price, add: false)
                        
                        CoreDataController.sharedInstance.updateCigar(cigar: newCigar, gift: gift, review: nil)
                    }
                    self.delegate?.updateHumidorView()
                }
            }
    }
    }
    
    func smokeCigarDelegate(quantity: Int32, review: Review) {
        if cigarIndex != nil{
            var smoke = true
            /* Better implementation using .copy */
            let cigarToSmoke = cigars![cigarIndex!.row]
            let initialQuantity = cigarToSmoke.quantity
            let initialPrice = cigarToSmoke.price
            self.tableView.beginUpdates()
            if cigarToSmoke.quantity == quantity {
                self.cigars!.remove(at: cigarIndex!.row)
                self.tableView.deleteRows(at:[cigarIndex!], with: .none)
            }
            else{
                cigars![cigarIndex!.row].price = cigarToSmoke.price - (Double(quantity)*(cigarToSmoke.price/Double(initialQuantity)))
                cigars![cigarIndex!.row].quantity = initialQuantity - quantity
                self.tableView.reloadRows(at: [cigarIndex!], with: .none)
            }
            self.tableView.endUpdates()
            self.isSelected()
            let snackbar = TTGSnackbar(message: NSLocalizedString("Cigar smoked", comment: ""),
                                       duration: .short,
                                       actionText: NSLocalizedString("Undo", comment: ""),
                                       actionBlock: { (snackbar) in
                                        /* Undo button action*/
                                        CoreDataController.sharedInstance.deleteReview(review: review)
                                        self.tableView.beginUpdates()
                                        if initialQuantity == quantity{
                                            self.cigars!.insert(cigarToSmoke, at: self.cigarIndex!.row)
                                            self.tableView.insertRows(at: [self.cigarIndex!], with: .right)
                                        }
                                        else{
                                            self.cigars![self.cigarIndex!.row].quantity = initialQuantity
                                            self.cigars![self.cigarIndex!.row].price = initialPrice
                                            self.tableView.reloadRows(at: [self.cigarIndex!], with: .none)
                                        }
                                        self.tableView.endUpdates()
                                        self.isSelected()
                                        /* Set delete to false thus the context won't be changed */
                                        smoke = false
            })
            snackbar.backgroundColor = UIColor.darkGray
            snackbar.show()
            
            /* Action after dismiss of undo view
             Removes the item from context if user hasn't selected otherwise
             */
            snackbar.dismissBlock = {
                (snackbar: TTGSnackbar) -> Void in if (smoke == true) {
                    
                    if initialQuantity == quantity {
                        CoreDataController.sharedInstance.updateCigar(cigar: cigarToSmoke, gift: nil, review: review)
                        CoreDataController.sharedInstance.updateHumidorValues(tray: cigarToSmoke.tray!, quantity: cigarToSmoke.quantity, value: cigarToSmoke.price, add: false)
                    }
                    else{
                        cigarToSmoke.quantity = initialQuantity
                        cigarToSmoke.price = initialPrice
                        
                        //Create copy of original cigar than update the quantity
                        let newCigar = CoreDataController.sharedInstance.addNewCigar(tray: cigarToSmoke.tray!, name: cigarToSmoke.name!, origin: cigarToSmoke.origin!, quantity: quantity, size: cigarToSmoke.size!, purchaseDate: cigarToSmoke.purchaseDate, from: cigarToSmoke.from, price: (Double(quantity)*(cigarToSmoke.price/Double(cigarToSmoke.quantity))), ageDate: cigarToSmoke.ageDate, image: cigarToSmoke.image, notes: cigarToSmoke.notes)
                        
                        CoreDataController.sharedInstance.updateCigarQuantity(cigar: cigarToSmoke, quantity: quantity, add: false)
                        CoreDataController.sharedInstance.updateHumidorValues(tray: newCigar.tray!, quantity: newCigar.quantity, value: newCigar.price, add: false)
                        
                        CoreDataController.sharedInstance.updateCigar(cigar: newCigar, gift: nil, review: review)
                    }
                    self.delegate?.updateHumidorView()
                }
            }
        }
    }
    
    // MARK: - Segue
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        delegate?.presentCigarDetailSegue(cigar: cigars![indexPath.row])
        
       // performSegue(withIdentifier: "detailCigar", sender: self)
    }
    
    /*
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailCigar"{
            let storyboard = UIStoryboard(name: "DetailCigar", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "DetailCigar") as! CigarDetailViewController
            vc.cigar = cigars![cigarIndex!.row]
            
            self.present(vc, animated: true, completion: nil)
            
        }
        
    }
    */
    // MARK: - Data
    
    func fetchData(){
        let unfilteredCigars = tray.cigars?.allObjects as? [Cigar]
        cigars = unfilteredCigars?.filter() { $0.gift == nil && $0.review == nil }
    }
    
    func sortData(ascending: Bool)-> [Cigar]{
        var sortArray = [Cigar]()
        switch UserSettings.tableSortOrder.rawValue {
        case 0:
            if ascending{
                sortArray = cigars!.sorted(by: { $0.creationDate! < $1.creationDate! })
            }
            else{
                sortArray = cigars!.sorted(by: { $0.name! > $1.name! })
            }
        case 1:
            if ascending{
                sortArray = cigars!.sorted(by: { $0.name! < $1.name! })
            }
            else{
                sortArray = cigars!.sorted(by: { $0.name! > $1.name! })
            }
        case 2:
            if ascending{
                sortArray = cigars!.sorted(by: { $0.quantity < $1.quantity })
            }
            else{
                sortArray = cigars!.sorted(by: { $0.quantity > $1.quantity })
            }
        case 3:
            if ascending{
                sortArray = cigars!.sorted(by: { $0.price < $1.price })
            }
            else{
                sortArray = cigars!.sorted(by: { $0.price > $1.price })
            }
        case 4:
            if ascending{
                sortArray = cigars!.sorted(by: { $0.origin! < $1.origin! })
            }
            else{
                sortArray = cigars!.sorted(by: { $0.origin! > $1.origin! })
            }
        case 5:
            if ascending{
                sortArray = cigars!.sorted(by: { $0.ageDate! < $1.ageDate! })
            }
            else{
                sortArray = cigars!.sorted(by: { $0.ageDate! > $1.ageDate! })
            }
        default:
            break
        }
        return sortArray
    }
    
    func computeAge(pastDate: Date,currentDate: Date) -> (years: Int, months: Int) {
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.month, .year], from: pastDate, to: currentDate)
        let theYears = components.year!
        let theMonths = components.month!
        return (theYears, theMonths)
    }
}





