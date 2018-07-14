//
//  HumidorDetailViewController.swift
//  CigarStack
//
//  Created by Darius Pasca on 01/06/2018.
//  Copyright © 2018 Darius Pasca. All rights reserved.
//

import UIKit
import Eureka

class HumidorDetailViewController: UIViewController, UITableViewDelegate {

    
    @IBOutlet weak var humidorNameLabel: UILabel!
    
    //Dividers Stack
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var dividersLabel: UILabel!
    
    //About Stack
    @IBOutlet weak var aboutLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var humidityValue: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var numberValue: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var valueValue: UILabel!
    
    //Stats Stack
    @IBOutlet weak var statsLabel: UILabel!
    @IBOutlet weak var AVGPriceLabel: UILabel!
    @IBOutlet weak var AVGPriceValue: UILabel!
    @IBOutlet weak var AVGAgeLabel: UILabel!
    @IBOutlet weak var AVGAgeValue: UILabel!
    @IBOutlet weak var expensiveLabel: UILabel!
    @IBOutlet weak var expensiveValue: UILabel!
    @IBOutlet weak var olderLabel: UILabel!
    @IBOutlet weak var olderstValue: UILabel!
    
    var humidor: Humidor!
    var review: [String: Double]!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        humidorNameLabel.text = humidor!.name
        aboutLabel.text = NSLocalizedString("About", comment: "")
        humidityLabel.text = NSLocalizedString("Humidity level:", comment: "")
        humidityValue.text = String(humidor!.humidity) + " %"
        numberLabel.text = NSLocalizedString("Number of cigars:", comment: "")
        numberValue.text = String((humidor!.quantity))
        valueLabel.text = NSLocalizedString( "Humidor Value", comment: "")
        valueValue.text = humidor!.value.asLocalCurrency
        
        statsLabel.text = NSLocalizedString("Statistics", comment: "")
        expensiveLabel.text = NSLocalizedString("Most expensive:", comment: "")
        olderLabel.text = NSLocalizedString("Oldest:", comment: "")
        AVGPriceLabel.text = NSLocalizedString("Average price:", comment: "")
        AVGAgeLabel.text = NSLocalizedString("Average age:" , comment: "")
        
        dividersLabel.text = NSLocalizedString("Dividers", comment: "")
        
        computeStatistics()
        
    }
    
    func computeStatistics(){
            let trays = humidor!.trays?.allObjects as! [Tray]
            var avgPrice: Double = 0
            var avgAge: Int = 0
            let currentDate = Date()
            var mostExpensive: Double = 0
            var oldest: (years: Int, months: Int) = (0,0)
            for tray in trays{
                let unfilteredCigars = tray.cigars?.allObjects as? [Cigar]
                let cigars = unfilteredCigars?.filter() { $0.gift == nil && $0.review == nil }
                for cigar in cigars!{
                    let weightedPrice = cigar.price * Double(cigar.quantity)
                    avgPrice = avgPrice + weightedPrice
                    
                    // Checks for pricier cigar
                    let priceCigar = cigar.price / Double(cigar.quantity)
                    if priceCigar > mostExpensive {
                        mostExpensive = priceCigar
                    }
                    
                    // Checks for oldest cigar
                    let cigarAge = computeAge(pastDate: cigar.ageDate!, currentDate: currentDate)
                        if oldest.years < cigarAge.years {
                            oldest.years = cigarAge.years
                            oldest.months = cigarAge.months
                        }
                        else if oldest.years == cigarAge.years{
                            if oldest.months < cigarAge.months{
                                oldest.years = cigarAge.years
                                oldest.months = cigarAge.months
                            }
                        }
                    let cigarAgeInMonths = (cigarAge.years*12) + cigarAge.months
                    avgAge = avgAge + (cigarAgeInMonths*Int(cigar.quantity))

                }
            }
            AVGPriceValue.text = (avgPrice / Double(humidor.quantity)).asLocalCurrency
            expensiveValue.text = mostExpensive.asLocalCurrency
        
        var month: String
        var year: String
        
        if Int(oldest.years) == 1 {
            year = NSLocalizedString("Year", comment: "")
        }
        else{
            year = NSLocalizedString("Years", comment: "")
        }
        
        if Int(oldest.months) == 1 {
            month = NSLocalizedString("Month", comment: "")
        }
        else{
            month = NSLocalizedString("Months", comment: "")
        }
        
        
            olderstValue.text = String(oldest.years) + " " + year + " " + NSLocalizedString("and", comment: "") + " " + String(oldest.months) + " " +  month
            let avgAgeValue = Double(avgAge)/Double(humidor.quantity)
            let splitAge = modf(avgAgeValue)
        
        if Int(splitAge.0) == 1 {
            year = NSLocalizedString("Year", comment: "")
        }
        else{
            year = NSLocalizedString("Years", comment: "")
        }
        
        if Int(splitAge.1*10) == 1 {
            month = NSLocalizedString("Month", comment: "")
        }
        else{
            month = NSLocalizedString("Months", comment: "")
        }
        
            AVGAgeValue.text = String(Int(splitAge.0)) + " " + year + " " + NSLocalizedString("and", comment: "") + " " + String(Int(splitAge.1*10)) + " " + month
    }
    
    func computeAge(pastDate: Date,currentDate: Date) -> (years: Int, months: Int) {
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.month, .year], from: pastDate, to: currentDate)
        let theYears = components.year!
        let theMonths = components.month!
        return (theYears, theMonths)
    }
    
    @IBAction func edit(_ sender: UIBarButtonItem) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "containerSegue" {
            let destVC = segue.destination as! HumidorTrayDetails
            destVC.humidor = humidor
        }
        else if segue.identifier == "editHumidor" {
            let navVC = segue.destination as! UINavigationController
            let destVC = navVC.topViewController as! AddHumidorController
            destVC.humidor = humidor
        }
    }

}

class HumidorTrayDetails: FormViewController{
    
    
    var humidor: Humidor!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let trays = (humidor!.trays?.allObjects as! [Tray]).sorted(by: { $0.orderID < $1.orderID })
        
        tableView.backgroundColor = UIColor.white
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        
        
        form +++ Section()
        for tray in trays {
            
            form.last!
            
            <<< IntRow(){
                $0.title = tray.name!
                var count: Int32 = 0
                let unfilteredCigars = tray.cigars?.allObjects as? [Cigar]
                for cigar in unfilteredCigars!{
                    if cigar.gift == nil || cigar.review == nil {
                        count += cigar.quantity
                    }
                }
                $0.value = Int(count)
                $0.disabled = true
            }.cellUpdate({cell, row in
                 cell.textField.textColor = UIColor.darkGray
                 cell.titleLabel?.textColor = UIColor.black
            })
        }
    }
    
    
}


