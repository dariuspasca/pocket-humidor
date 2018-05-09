//
//  SearchViewController.swift
//  CigarStack
//
//  Created by Darius Pasca on 09/05/2018.
//  Copyright © 2018 Darius Pasca. All rights reserved.
//

import UIKit
import FlagKit

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var isSearching = false
    var searchResults:[Cigar]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        searchBar.placeholder = NSLocalizedString("Search", comment: "")
        self.tableView.tableFooterView = UIView()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        searchResults?.removeAll()
        searchBar.text = ""
        self.tableView.reloadData()
    }
    

    // MARK: - Search
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
        searchResults = CoreDataController.sharedInstance.searchCigarThatContains(key: searchBar.text!)
        CoreDataController.sharedInstance.fetchAllCigars()
        self.tableView.reloadData()
        isSearching = false
        self.searchBar.endEditing(true)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.setShowsCancelButton(false, animated: true)
        searchResults?.removeAll()
        tableView.reloadData()
        view.endEditing(true)
    }
    
    // MARK: - TableView

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchResults != nil {
            return searchResults!.count
        }
        else{
            return 0
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! ContentTableViewCell
        let cigar = searchResults![indexPath.row]
        let pastDate = cigar.ageDate!
        let (years, months) = computeAge(pastDate: pastDate, currentDate: Date())
        
        var percentage = Double(months)/12
        if years > 0 && months == 0 {
            percentage = 0.01
        }
        
        let progressCircle = circleView(frame: CGRect(x: 0, y: 0, width: cell.progress.frame.width, height: cell.progress.frame.height), percent: percentage)
        cell.quantity.text = String(cigar.quantity)
        cell.countryFlag.image =  Flag(countryCode: cigar.origin!)?.image(style: .circle)
        cell.name.text =  cigar.name!
        cell.price.text = cigar.price.asLocalCurrency
        cell.progress.addSubview(progressCircle)
        cell.years.text = String(years)
        cell.yearsLabel.text = NSLocalizedString("Years", comment: "")
        return cell
    }
    
    func computeAge(pastDate: Date,currentDate: Date) -> (years: Int, months: Int) {
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.month, .year], from: pastDate, to: currentDate)
        let theYears = components.year!
        let theMonths = components.month!
        return (theYears, theMonths)
    }


}
