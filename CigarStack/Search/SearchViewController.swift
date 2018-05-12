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

}
