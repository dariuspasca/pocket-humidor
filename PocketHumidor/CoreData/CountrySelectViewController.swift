//
//  CountrySelectViewController.swift
//  CigarStack
//
//  Created by Darius Pasca on 24/03/2018.
//  Copyright © 2018 Darius Pasca. All rights reserved.
//

import UIKit
import FlagKit

struct Countries{
    let countries: [(countryCode: String, countryName: String)]
    let letter: String
}

class CountrySelectViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var countryTable: UITableView!
    var isSearching = false
    var filteredData = [(countryCode: String, countryName: String)]()
    
    var selectedCell: IndexPath!
    var countryList = [Countries]()
    var countryListSections = [String]()
    
    var delegateCountryCode: String!
    var delegate: SelectCountryDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.placeholder = NSLocalizedString("Search", comment: "")
        prepareCountriesList()
        selectedCell = searchCellWithValue(countryCode: delegateCountryCode)
        searchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        self.countryTable.scrollToRow(at: selectedCell, at: .middle, animated: false)
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if isSearching{
            return 1
        }
        return countryList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching{
            return filteredData.count
        }
        return countryList[section].countries.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if isSearching{
            return nil
        }
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "countryHeader") as! CountryTableViewHeader
        headerCell.title.text = String(countryList[section].letter)
        return headerCell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "countryCell", for: indexPath) as! CountryTableViewCell
        if isSearching{
            cell.countryName.text = filteredData[indexPath.row].countryName
            cell.countryFlag.image = Flag(countryCode: filteredData[indexPath.row].countryCode)?.image(style: .circle)
            
        }
        else{
            let country = countryList[indexPath.section].countries[indexPath.row]

            
            cell.countryName.text = country.countryName
            cell.countryFlag.image = Flag(countryCode: country.countryCode)?.image(style: .circle)
            
            if indexPath == selectedCell {
                cell.accessoryType = .checkmark
                selectedCell = indexPath
            }
            else {
                cell.accessoryType = .none
            }
        }
        return cell
    }
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
        if isSearching{
            delegateCountryCode = filteredData[indexPath.row].countryCode
        }
        else{
            delegateCountryCode = countryList[indexPath.section].countries[indexPath.row].countryCode
        }
        sendData(countryCode: delegateCountryCode)
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return countryListSections
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }
    
    //MARK: - Search
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == "" {
            isSearching = false
            view.endEditing(true)
            self.countryTable.reloadData()
        }
        else{
            isSearching = true
            filteredData.removeAll()
            for country in countryList{
                filteredData += country.countries.filter({$0.countryName.lowercased().hasPrefix(searchBar.text!.lowercased())})
                self.countryTable.reloadData()
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        self.searchBar.endEditing(true)
    }
    
    func searchCellWithValue(countryCode: String) ->IndexPath{
        var found = false
        var indexPath: IndexPath!
        for (section, countries) in countryList.enumerated(){
            if found{
                break
            }
            else{
                for (row, country) in countries.countries.enumerated(){
                    if country.countryCode == countryCode{
                        indexPath = IndexPath(row: row, section: section)
                        found = true
                        break
                    }
                }
            }
        }
        
        if found{
            return indexPath
        }
        else{
            return IndexPath(row: 0, section: 0)
        }
    }
    
   
    //MARK: - Navigation
    
    func sendData(countryCode: String){
        delegate?.completeDelegate(countryNameDelegate: countryCode)
        popView()
        
    }
    
    func popView() {
        let when = DispatchTime.now() + 0.1 // change to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func prepareCountriesList(){
        var allCountries = [(countryCode: String, countryName: String)]()
        
        for country in Flag.all{
                 allCountries.append((countryCode: country.countryCode, countryName: country.localizedName))
        }

        
        var allCountriesSorted = allCountries.sorted(by: {$0.countryName < $1.countryName})
        allCountriesSorted = allCountriesSorted.filter({$0.countryName != "Other"})
        
        var letter = String(allCountriesSorted[0].countryName.first!)
        
        var countriesArray = [(countryCode: String, countryName: String)]()
        for country in allCountriesSorted{
            let countryFirstLetter = String(country.countryName.first!).folding(options: .diacriticInsensitive, locale: nil)
            if letter == countryFirstLetter{
                countriesArray.append(country)
            }
            else{
                let countriesElement = Countries(countries: countriesArray, letter: letter)
                countryList.append(countriesElement)
                countryListSections.append(String(letter))
                countriesArray.removeAll()
                letter = String(country.countryName.first!)
                countriesArray.append(country)
            }
        }
    }

}

protocol SelectCountryDelegate {
    func completeDelegate(countryNameDelegate: String)
}

class CountryTableViewCell: UITableViewCell{
    
    @IBOutlet weak var countryName: UILabel!
    @IBOutlet weak var countryFlag: UIImageView!
    
}

class CountryTableViewHeader: UITableViewCell{
    @IBOutlet weak var title: UILabel!
    
}
extension Flag {
    var localizedName: String {
        let current = Locale(identifier: Bundle.main.preferredLocalizations.first!)
        return current.localizedString(forRegionCode: countryCode) ?? "Other"
    }
    
    var firstLetter: String{
        return String(countryCode[countryCode.startIndex]).uppercased()
    }
    
    static let all: [Flag] = [
        Flag(countryCode: "AD")!,
        Flag(countryCode: "AE")!,
        Flag(countryCode: "AF")!,
        Flag(countryCode: "AG")!,
        Flag(countryCode: "AI")!,
        Flag(countryCode: "AL")!,
        Flag(countryCode: "AM")!,
        Flag(countryCode: "AO")!,
        Flag(countryCode: "AR")!,
        //Flag(countryCode: "AS")!,
        Flag(countryCode: "AT")!,
        Flag(countryCode: "AU")!,
        //Flag(countryCode: "AW")!,
        //Flag(countryCode: "AX")!,
        Flag(countryCode: "BA")!,
        Flag(countryCode: "BB")!,
        Flag(countryCode: "BD")!,
        Flag(countryCode: "BE")!,
        Flag(countryCode: "BF")!,
        Flag(countryCode: "BG")!,
        Flag(countryCode: "BH")!,
        Flag(countryCode: "BI")!,
        //Flag(countryCode: "BJ")!,
        //Flag(countryCode: "BL")!,
        Flag(countryCode: "BM")!,
        Flag(countryCode: "BN")!,
        Flag(countryCode: "BO")!,
        Flag(countryCode: "BR")!,
        Flag(countryCode: "BS")!,
        Flag(countryCode: "BT")!,
        //Flag(countryCode: "BV")!,
        Flag(countryCode: "BW")!,
        //Flag(countryCode: "BY")!,
        Flag(countryCode: "BZ")!,
        Flag(countryCode: "CA")!,
        Flag(countryCode: "CC")!,
        Flag(countryCode: "CD")!,
        //Flag(countryCode: "CF")!,
        Flag(countryCode: "CG")!,
        Flag(countryCode: "CH")!,
        Flag(countryCode: "CI")!,
        //Flag(countryCode: "CK")!,
        Flag(countryCode: "CL")!,
        Flag(countryCode: "CM")!,
        Flag(countryCode: "CN")!,
        Flag(countryCode: "CO")!,
        Flag(countryCode: "CR")!,
        Flag(countryCode: "CU")!,
        Flag(countryCode: "CV")!,
        Flag(countryCode: "CW")!,
        //Flag(countryCode: "CX")!,
        Flag(countryCode: "CY")!,
        Flag(countryCode: "CZ")!,
        Flag(countryCode: "DE")!,
        //Flag(countryCode: "DJ")!,
        Flag(countryCode: "DK")!,
        //Flag(countryCode: "DM")!,
        Flag(countryCode: "DO")!,
        Flag(countryCode: "DZ")!,
        Flag(countryCode: "EC")!,
        Flag(countryCode: "EE")!,
        Flag(countryCode: "EG")!,
        Flag(countryCode: "ER")!,
        Flag(countryCode: "ES")!,
        Flag(countryCode: "ET")!,
        Flag(countryCode: "FI")!,
        Flag(countryCode: "FJ")!,
        Flag(countryCode: "FK")!,
        Flag(countryCode: "FR")!,
        //Flag(countryCode: "FM")!,
        Flag(countryCode: "FO")!,
        //Flag(countryCode: "GA")!,
        Flag(countryCode: "GB")!,
        //Flag(countryCode: "GD")!,
        Flag(countryCode: "GE")!,
        Flag(countryCode: "GF")!,
        //Flag(countryCode: "GG")!,
        Flag(countryCode: "GH")!,
        Flag(countryCode: "GI")!,
        Flag(countryCode: "GL")!,
        //Flag(countryCode: "GM")!,
        Flag(countryCode: "GN")!,
        Flag(countryCode: "GP")!,
        Flag(countryCode: "GQ")!,
        Flag(countryCode: "GR")!,
        //Flag(countryCode: "GS")!,
        Flag(countryCode: "GT")!,
        Flag(countryCode: "GU")!,
        //Flag(countryCode: "GW")!,
        Flag(countryCode: "GY")!,
        Flag(countryCode: "HK")!,
        //Flag(countryCode: "HM")!,
        Flag(countryCode: "HN")!,
        Flag(countryCode: "HR")!,
        Flag(countryCode: "HT")!,
        Flag(countryCode: "HU")!,
        Flag(countryCode: "ID")!,
        Flag(countryCode: "IE")!,
        Flag(countryCode: "IL")!,
        //Flag(countryCode: "IM")!,
        Flag(countryCode: "IN")!,
        //Flag(countryCode: "IO")!,
        Flag(countryCode: "IQ")!,
        Flag(countryCode: "IR")!,
        Flag(countryCode: "IS")!,
        Flag(countryCode: "IT")!,
        //Flag(countryCode: "JE")!,
        Flag(countryCode: "JM")!,
        Flag(countryCode: "JO")!,
        Flag(countryCode: "JP")!,
        Flag(countryCode: "KE")!,
        //Flag(countryCode: "KG")!,
        Flag(countryCode: "KH")!,
        //Flag(countryCode: "KI")!,
        Flag(countryCode: "KM")!,
        //Flag(countryCode: "KN")!,
        Flag(countryCode: "KP")!,
        Flag(countryCode: "KR")!,
        Flag(countryCode: "KW")!,
        Flag(countryCode: "KY")!,
        Flag(countryCode: "KZ")!,
        Flag(countryCode: "LA")!,
        Flag(countryCode: "LB")!,
        //Flag(countryCode: "LC")!,
        Flag(countryCode: "LI")!,
        Flag(countryCode: "LK")!,
        Flag(countryCode: "LR")!,
        //Flag(countryCode: "LS")!,
        Flag(countryCode: "LT")!,
        Flag(countryCode: "LU")!,
        Flag(countryCode: "LV")!,
        Flag(countryCode: "LY")!,
        Flag(countryCode: "MA")!,
        Flag(countryCode: "MC")!,
        Flag(countryCode: "MD")!,
        Flag(countryCode: "ME")!,
        Flag(countryCode: "MG")!,
        //Flag(countryCode: "MH")!,
        Flag(countryCode: "MK")!,
        //Flag(countryCode: "ML")!,
        //Flag(countryCode: "MM")!,
        Flag(countryCode: "MN")!,
        //Flag(countryCode: "MO")!,
        //Flag(countryCode: "MP")!,
        //Flag(countryCode: "MQ")!,
       // Flag(countryCode: "MR")!,
        //Flag(countryCode: "MS")!,
        Flag(countryCode: "MT")!,
        Flag(countryCode: "MU")!,
        Flag(countryCode: "MV")!,
        Flag(countryCode: "MW")!,
        Flag(countryCode: "MX")!,
        Flag(countryCode: "MY")!,
        Flag(countryCode: "MZ")!,
        //Flag(countryCode: "NA")!,
        //Flag(countryCode: "NC")!,
        Flag(countryCode: "NE")!,
        //Flag(countryCode: "NF")!,
        Flag(countryCode: "NG")!,
        Flag(countryCode: "NI")!,
        Flag(countryCode: "NL")!,
        Flag(countryCode: "NO")!,
        //Flag(countryCode: "NP")!,
        //Flag(countryCode: "NR")!,
        //Flag(countryCode: "NU")!,
        Flag(countryCode: "NZ")!,
        Flag(countryCode: "OM")!,
        Flag(countryCode: "PA")!,
        Flag(countryCode: "PE")!,
        Flag(countryCode: "PF")!,
        Flag(countryCode: "PG")!,
        Flag(countryCode: "PH")!,
        Flag(countryCode: "PK")!,
        Flag(countryCode: "PL")!,
        //Flag(countryCode: "PM")!,
        //Flag(countryCode: "PN")!,
        Flag(countryCode: "PR")!,
        //Flag(countryCode: "PS")!,
        Flag(countryCode: "PT")!,
       // Flag(countryCode: "PW")!,
        Flag(countryCode: "PY")!,
        Flag(countryCode: "QA")!,
        //Flag(countryCode: "RE")!,
        Flag(countryCode: "RO")!,
        Flag(countryCode: "RS")!,
        Flag(countryCode: "RU")!,
        //Flag(countryCode: "RW")!,
        Flag(countryCode: "SA")!,
        //Flag(countryCode: "SB")!,
        //Flag(countryCode: "SC")!,
        Flag(countryCode: "SD")!,
        Flag(countryCode: "SE")!,
        Flag(countryCode: "SG")!,
        Flag(countryCode: "SI")!,
        //Flag(countryCode: "SJ")!,
        Flag(countryCode: "SK")!,
        Flag(countryCode: "SL")!,
        Flag(countryCode: "SM")!,
        Flag(countryCode: "SN")!,
        Flag(countryCode: "SO")!,
        //Flag(countryCode: "SR")!,
        //Flag(countryCode: "SS")!,
        //Flag(countryCode: "ST")!,
        Flag(countryCode: "SV")!,
        //Flag(countryCode: "SX")!,
        Flag(countryCode: "SY")!,
        //Flag(countryCode: "SZ")!,
        //Flag(countryCode: "TC")!,
        Flag(countryCode: "TD")!,
        //Flag(countryCode: "TF")!,
        Flag(countryCode: "TG")!,
        Flag(countryCode: "TH")!,
        //Flag(countryCode: "TJ")!,
        //Flag(countryCode: "TK")!,
        //Flag(countryCode: "TL")!,
        //Flag(countryCode: "TM")!,
        Flag(countryCode: "TN")!,
        //Flag(countryCode: "TO")!,
        Flag(countryCode: "TR")!,
        //Flag(countryCode: "TT")!,
        //Flag(countryCode: "TV")!,
        Flag(countryCode: "TW")!,
        Flag(countryCode: "TZ")!,
        Flag(countryCode: "UA")!,
        Flag(countryCode: "UG")!,
        //Flag(countryCode: "UM")!,
        Flag(countryCode: "US")!,
        Flag(countryCode: "UY")!,
        Flag(countryCode: "UZ")!,
        //Flag(countryCode: "VA")!,
        //Flag(countryCode: "VC")!,
        Flag(countryCode: "VE")!,
        Flag(countryCode: "VG")!,
        //Flag(countryCode: "VI")!,
        Flag(countryCode: "VN")!,
        //Flag(countryCode: "VU")!,
        //Flag(countryCode: "WF")!,
        Flag(countryCode: "WS")!,
        Flag(countryCode: "XK")!,
        Flag(countryCode: "YE")!,
        //Flag(countryCode: "YT")!,
        Flag(countryCode: "ZA")!,
        Flag(countryCode: "ZM")!,
        Flag(countryCode: "ZW")!,
        Flag(countryCode: "EU")!,
        Flag(countryCode: "GB-ENG")!,
        //Flag(countryCode: "GB-NIR")!,
        Flag(countryCode: "GB-SCT")!,
        Flag(countryCode: "GB-WLS")!,
        //Flag(countryCode: "GB-ZET")!,

        ]
}
