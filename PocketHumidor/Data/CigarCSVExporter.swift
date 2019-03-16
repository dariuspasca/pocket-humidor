//
//  CigarCSVExporter.swift
//  PocketHumidor
//
//  Created by Darius Pasca on 13/03/2019.
//  Copyright © 2019 Darius Pasca. All rights reserved.
//

import Foundation
import CoreData
import CSV

class CigarCSVExporter {
    
    var csv:CSVReader!
    var containerUrl: URL? {
        return FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents")
    }
    
    func exportData(saveFileTo: URL, completion: (URL?) -> ()) {
        let cigars = CoreDataController.sharedInstance.fetchCigars()
        if cigars != nil && !cigars!.isEmpty{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")


            let fileName = "PocketStack \(UserSettings.currentVersion.value) - \(UIDevice.current.name) - \(dateFormatter.string(from: Date())).csv"
            
            var csvText = "Name,Size,Origin,Quantity,Price,From,Purchase Date,Aging Date,Notes,Creation Date,Last Edit,Gift Date,Gift To,Gift Notes,Review Date,Score,Appearance,Ash,Draw,Flavor,Strength,Texture,Review Notes,Humidor,Humidor Humidity,Divisor\n"
            for cigar in cigars! {
                
                var cigarGiftDate = ""
                var cigarReviewDate = ""
                var score = ""
                var appeareance = ""
                var ash = ""
                var draw = ""
                var flavor = ""
                var strenght = ""
                var texture = ""
                
                
                if cigar.review != nil || cigar.gift != nil {
                    if cigar.review != nil{
                        cigarReviewDate = dateFormatter.string(from: cigar.review!.reviewDate!)
                        score = String(cigar.review!.score)
                        appeareance = String(cigar.review!.appearance)
                        ash = String(cigar.review!.ash)
                        draw = String(cigar.review!.draw)
                        flavor = String(cigar.review!.flavour)
                        texture = String(cigar.review!.texture)
                        strenght = String(cigar.review!.strength)
                    }
                    else{
                        cigarGiftDate = dateFormatter.string(from: cigar.gift!.giftDate!)
                    }
                }
                
                
                let newLine = "\(cigar.name!),\(cigar.size ?? ""),\(cigar.origin!),\(String(cigar.quantity)),\(String(cigar.price)),\(cigar.from ?? ""),\(dateFormatter.string(from: cigar.purchaseDate!)),\(dateFormatter.string(from: cigar.ageDate!)),\(cigar.notes ?? ""),\(dateFormatter.string(from: cigar.creationDate!)),\(dateFormatter.string(from: cigar.editDate!)),\(cigarGiftDate),\(cigar.gift?.to ?? ""),\(cigar.gift?.notes ?? ""),\(cigarReviewDate),\(score),\(appeareance),\(ash),\(draw),\(flavor),\(strenght),\(texture),\(cigar.review?.notes ?? ""),\(cigar.tray!.humidor!.name!),\(String(cigar.tray!.humidor!.humidity)),\(cigar.tray!.name!)\n"
                csvText.append(contentsOf: newLine)
            }
            do {
                let fileURL = saveFileTo.appendingPathComponent(fileName)
                try csvText.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
                completion(fileURL)
            } catch let error as NSError {
                print("Failed exporting file : \(error)")
                completion(nil)
            }
        }
    }
    
    

}
