//
//  CigarCSVImporter.swift
//  CigarStack
//
//  Created by Darius Pasca on 06/08/2018.
//  Copyright © 2018 Darius Pasca. All rights reserved.
//

import Foundation
import CoreData
import CSV

protocol CigarCSVImporterDelegate{
    func importFinishedUnsuccessful(message: String)
    func importFinishedSuccessful(status: CigarCSVImportResults)
}

struct CigarCSVImportResults {
    let success: Int
    let error: Int
    let duplicate: Int
}

class CigarCSVImporter{
    
    var delegate: CigarCSVImporterDelegate?
    var csv:CSVReader!
    let headerCSV = ["Name", "Size", "Origin", "Quantity", "Price", "From", "Purchase Date", "Aging Date", "Notes", "Creation Date", "Last Edit", "Gift Date", "Gift To", "Gift Notes", "Review Date", "Score", "Appearance", "Ash", "Draw", "Flavor", "Strength", "Texture", "Review Notes", "Humidor", "Humidor Humidity,", "Divisor"]
    
    
    private var duplicateCount = 0
    private var invalidCount = 0
    private var successCount = 0
    
    
    
    func startImport(fromFileAt fileLocation: URL){
        let stream = InputStream(fileAtPath: fileLocation.path)!
        csv = try! CSVReader(stream: stream, hasHeaderRow: true)
        let header = csv.headerRow
        
        
        //Check if header is valid
        if header != nil {
            parseRows()
        }
        else{
            if header == nil {
                delegate?.importFinishedUnsuccessful(message: NSLocalizedString("File header is missing.", comment: ""))
            }
            else{
                delegate?.importFinishedUnsuccessful(message: NSLocalizedString("File header is not formated correctly.", comment: ""))
            }
        }
        
    }
    
    
    func parseRows() {
        while csv.next() != nil {
            if rowIsValid(){
                addCigar()
            }
            else{
                invalidCount += 1
            }
        }
        delegate?.importFinishedSuccessful(status: CigarCSVImportResults(success: successCount, error: invalidCount, duplicate: duplicateCount))
    }
    
    
    func addCigar(){
       var humidor = CoreDataController.sharedInstance.searchHumidor(name: csv["Humidor"]!)
        
        //Creates a new humidor if there isn't one yet
        if humidor == nil {
            let humidorOrderID = CoreDataController.sharedInstance.countHumidors()
            humidor = CoreDataController.sharedInstance.addNewHumidor(name: csv["Humidor"]!, humidityLevel: Int16(csv["Humidor Humidity"]!)!, orderID: Int16(humidorOrderID))
        }
        
        var divisor = CoreDataController.sharedInstance.searchTray(humidor: humidor!, searchTray: csv["Divisor"]!)
        
        //Creates a new divisor if there isn't one yet
        if divisor == nil {
            let trayOrderID = humidor!.trays!.count
            divisor = CoreDataController.sharedInstance.addNewTray(name: csv["Divisor"]!, humidor: humidor!, orderID: Int16(trayOrderID), save: true)
        }
        
        //Create a cigar
        let cigar = CoreDataController.sharedInstance.addNewCigar(tray: divisor!, name: csv["Name"]!, origin: csv["Origin"]!, quantity: Int32(csv["Quantity"]!)!, size: csv["Size"]!, purchaseDate: Date(iso: csv["Purchase Date"]!), from: csv["From"]!, price: Double(csv["Price"]!)!, ageDate: Date(iso: csv["Aging Date"]!), notes: csv["Notes"]!)
        cigar.creationDate =  Date(iso: csv["Creation Date"]!)
        cigar.editDate =  Date(iso: csv["Last Edit"]!)
        
        var gift:Gift? = nil
        var review:Review? = nil
        
        // Check and adds review or gift if is present
        if csv["Gift Date"]! != "" {
            gift = CoreDataController.sharedInstance.createGift(to: csv["Gift To"]!, notes: csv["Gift Notes"]!, date: Date(iso: csv["Gift Date"])!)
        }
        else if csv["Review Date"]! != "" {
            review = CoreDataController.sharedInstance.createReview(score: Int16(csv["Score"]!)!, appearance: Int16(csv["Appearance"]!)!, flavour: Int16(csv["Flavor"]!)!, ash: Int16(csv["ash"]!)!, draw: Int16(csv["Draw"]!)!, texture: Int16(csv["Texture"]!)!, strength: Int16(csv["Strength"]!)!, notes: csv["Review Notes"]!, reviewDate: Date(iso: csv["Review Date"])!)
        }
        
        CoreDataController.sharedInstance.updateCigar(cigar: cigar, gift: gift, review: review)
        CoreDataController.sharedInstance.saveContext()
        
       
        //Checks if the new cigar is duplicate, if is it deletes it
        if isDuplicate(cigarToCompare: cigar){
            CoreDataController.sharedInstance.deleteCigar(cigar: cigar, withUpdate: true)
            duplicateCount += 1
        }
        else{
            successCount += 1
        }
 
        
    }
    
    
    func isDuplicate(cigarToCompare: Cigar) -> Bool {
        //fetch all cigars with the same name
        let cigars = CoreDataController.sharedInstance.searchCigarThatNameContains(name: cigarToCompare.name!)

        
        //removes cigar from different humidor
        if cigars != nil {
            for cigar in cigars! {
                
                //skip the cigar just added before
                if cigarToCompare.objectID != cigar.objectID {
                if cigar.origin! == cigarToCompare.origin, cigar.quantity == cigarToCompare.quantity, cigar.size == cigarToCompare.size , cigar.purchaseDate == cigarToCompare.purchaseDate,
                     cigar.from == cigarToCompare.from, cigar.price == cigarToCompare.price, cigar.ageDate == cigarToCompare.ageDate, cigar.notes == cigarToCompare.notes, cigar.creationDate == cigarToCompare.creationDate {
                    
                    
                    //if cigars are equal, checks for review or gift , they might be different
                    if (cigarToCompare.review != nil && cigar.review != nil ) || (cigarToCompare.gift != nil && cigar.gift != nil ) {
                        if cigarToCompare.review != nil {
                            if cigarToCompare.gift!.giftDate == cigar.gift!.giftDate, cigarToCompare.gift!.to == cigar.gift!.to, cigarToCompare.gift!.notes == cigar.gift!.notes{
                                return true
                            }
                            else{
                                return false
                            }
                        }
                        else if cigarToCompare.gift != nil {
                            if cigarToCompare.review!.reviewDate == cigar.review!.reviewDate, cigarToCompare.review!.notes == cigar.review!.notes, cigarToCompare.review!.ash == cigar.review!.ash, cigarToCompare.review!.appearance == cigar.review!.appearance, cigarToCompare.review!.draw == cigar.review!.draw, cigarToCompare.review!.texture == cigar.review!.texture, cigarToCompare.review!.flavour == cigar.review!.flavour, cigarToCompare.review!.strength == cigar.review!.strength, cigarToCompare.review!.score == cigar.review!.score {
                                
                                    return true
                            }
                            else {
                                return false
                            }
                        }
                        
                    }
                    // otherwise they are n the same
                    else{
                        return true
                    }
                }
                else{
                    return false
                }
            }
        }
        }
            
        else{
            return false
        }
        
        return false
    }
    
    func rowIsValid() -> Bool{
        let rowNotOptionalValues:[String] = [csv["Name"]!,csv["Size"]!,csv["Origin"]!,csv["Quantity"]!,csv["Price"]!,csv["Purchase Date"]!,csv["Aging Date"]!,csv["Creation Date"]!,csv["Last Edit"]!]
        var status = true
        for value in rowNotOptionalValues{
            if value == "" {
                status = false
                return status
            }
        }
        return status
    }

}

public extension Date {
    init?(iso: String?) {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = "yyyy-MM-dd"
        dateStringFormatter.locale = Locale(identifier: "en_US_POSIX")
        guard let iso = iso, let date = dateStringFormatter.date(from: iso) else { return nil }
        self.init(timeInterval: 0, since: date)
}
}


