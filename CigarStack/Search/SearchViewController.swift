//
//  SearchViewController.swift
//  CigarStack
//
//  Created by Darius Pasca on 09/05/2018.
//  Copyright © 2018 Darius Pasca. All rights reserved.
//

import UIKit
import FlagKit
import DZNEmptyDataSet

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    var noResultsFlag: Bool!
    var clearData = true
    
    var isSearching = false
    var searchResults:[Cigar]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        searchBar.placeholder = NSLocalizedString("Search", comment: "")
        self.tableView.tableFooterView = UIView()
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        noResultsFlag = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if !clearData{
            clearData = true
        }
        else{
            searchResults?.removeAll()
            searchBar.text = ""
            noResultsFlag = false
            self.tableView.reloadData()
        }
    }
    

    // MARK: - Search
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
        if searchBar.text != ""{
            var results = CoreDataController.sharedInstance.searchCigarThatNameContains(name: searchBar.text!)
            
            let countries = self.getCountryCode(name: searchBar.text!)
            if countries != nil {
                for country in countries!{
                    let result = CoreDataController.sharedInstance.searchCigarByCountry(country: country)
                    if result != nil {
                        if results == nil {
                            results = [Cigar]()
                        }
                        results!.append(contentsOf: result!)
                    }
                }
            }
            
            let sizeResults = CoreDataController.sharedInstance.searchCigarBySize(size: searchBar.text!.capitalized)
            if sizeResults != nil {
                if results == nil {
                    results = [Cigar]()
                }
                results!.append(contentsOf: sizeResults!)
            }
            
            if results != nil {
                results! = self.removeDuplicates(cigars: results!)
            }
            
            searchResults = results?.filter() { $0.gift == nil && $0.review == nil }
            if searchResults!.isEmpty {
                noResultsFlag = true
                self.tableView.reloadEmptyDataSet()
            }
            else{
                noResultsFlag = false
            }
            self.tableView.reloadData()
            isSearching = false
            self.searchBar.endEditing(true)
        }
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
    
    
    func removeDuplicates(cigars: [Cigar]) -> [Cigar]{
        var noDuplicates = [Cigar]()
        
        for cigar in cigars{
            var found = false
            for item in noDuplicates{
                if item.objectID == cigar.objectID {
                    found = true
                    break
                }
            }
            if !found{
                noDuplicates.append(cigar)
            }
        }
        
        return noDuplicates
    }
    
    
    func getCountryCode(name: String) -> [String]?{
        var countries:[String]?
        
        for country in Flag.all{
            if country.localizedName.contains(name){
                if countries == nil {
                    countries = [String]()
                }
                countries?.append(country.countryCode)
            }
        }
        
        return countries
    }
    
    // MARK: - TableView

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults?.count ?? 0
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! SearchTableViewCell
        let cigar = searchResults![indexPath.row]
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale.current
        
        if cigar.quantity > 99 {
            cell.cigarNumber.text = "+99"
            cell.cigarNumber.font = cell.cigarNumber.font.withSize(12)
        }
        else{
            cell.cigarNumber.text = String(cigar.quantity)
        }
        
        cell.cigarCountry.image = Flag(countryCode: cigar.origin!)?.image(style: .circle)
        cell.cigarName.text = cigar.name!
        cell.cigarCreationDate.text =  dateFormatter.string(from: cigar.creationDate!)
        cell.cigarHumidor.text = cigar.tray!.humidor!.name!
        cell.cigarShape.text = cigar.size!
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        clearData = false
        tableView.deselectRow(at: indexPath, animated: true)
        let storyboard = UIStoryboard(name: "DetailCigar", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "DetailCigar") as! CigarDetailViewController
        vc.cigar = searchResults![indexPath.row]
        if UIDevice.current.userInterfaceIdiom == .pad{
            vc.modalPresentationStyle = .formSheet
            vc.modalTransitionStyle = .coverVertical
        }
        else{
            vc.modalPresentationStyle = .fullScreen
            vc.modalTransitionStyle = .coverVertical
        }
        vc.modalPresentationCapturesStatusBarAppearance = true
        self.present(vc, animated: true, completion: nil)
    }
    
    // MARK: - DZNEmptyDataSet
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        
        let attributes =
            [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 20, weight: .light),
             NSAttributedStringKey.foregroundColor : UIColor.black,
             NSAttributedStringKey.backgroundColor : UIColor.clear]
        if noResultsFlag{
            return NSAttributedString(string: NSLocalizedString("No results for", comment: ""), attributes: attributes)
        }
        else{
            return NSAttributedString(string: NSLocalizedString("Search Cigars", comment: ""), attributes: attributes)
        }
        
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        if noResultsFlag{
            let attributes =
                [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 18, weight: .bold),
                 NSAttributedStringKey.foregroundColor : UIColor.black,
                 NSAttributedStringKey.backgroundColor : UIColor.clear]
             return NSAttributedString(string: searchBar.text!, attributes: attributes)
        }
        else{
            let attributes =
                [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 18, weight: .light),
                 NSAttributedStringKey.foregroundColor : UIColor.darkGray,
                 NSAttributedStringKey.backgroundColor : UIColor.clear]
             return NSAttributedString(string: NSLocalizedString("Search cigars by name, country of origin or size.", comment: ""), attributes: attributes)
        }
       
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return  -tableView.frame.height/3
    }

}
