//
//  HumidorDetailViewController.swift
//  CigarStack
//
//  Created by Darius Pasca on 01/06/2018.
//  Copyright © 2018 Darius Pasca. All rights reserved.
//

import UIKit
import Eureka

class HumidorDetailViewController: UIViewController {
    
    @IBOutlet weak var tableFormView: FormViewController!
    
    @IBOutlet weak var humidorNameLabel: UILabel!
    
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
        AVGPriceLabel.text = NSLocalizedString("Average cigar price:", comment: "")
        AVGAgeLabel.text = NSLocalizedString("Average cigar age:" , comment: "")
        
        computeStatistics()
        
      //  tableFormView.form +++ MultivaluedSection(multivaluedOptions: [.Reorder, .Delete,])
        
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
            olderstValue.text = String(oldest.years) + " " + NSLocalizedString("Years", comment: "") + " " + NSLocalizedString("and", comment: "") + " " + String(oldest.months) + " " + NSLocalizedString("Months", comment: "")
            let avgAgeValue = Double(avgAge)/Double(humidor.quantity)
            let splitAge = modf(avgAgeValue)
            AVGAgeValue.text = String(Int(splitAge.0)) + " " + NSLocalizedString("Years", comment: "") + " " + NSLocalizedString("and", comment: "") + " " + String(Int(splitAge.1*10)) + " " + NSLocalizedString("Months", comment: "")
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
    

}


