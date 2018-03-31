//
//  ContentViewController.swift
//  CigarStack
//
//  Created by Darius Pasca on 13/03/2018.
//  Copyright © 2018 Darius Pasca. All rights reserved.
//

import UIKit
import FlagKit

protocol ContainerTableDelegate {
    func dataChanged(height: CGFloat)
}

class ContentTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var delegate: ContainerTableDelegate?
    var tray: Tray!
    var cigars: [Cigar]?
    
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
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
}



