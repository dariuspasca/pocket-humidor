//
//  CoreDataController.swift
//  Cigar Stack
//
//  Created by Darius Pasca on 16/01/2018.
//  Copyright © 2018 Darius Pasca. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class CoreDataController {
    private var context: NSManagedObjectContext
    static let sharedInstance = CoreDataController()
    
    private init(){
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        self.context = (appDelegate?.persistentContainer.viewContext)!
    }
    
    /* New Humidor */
    func addNewHumidor(name: String, humidityLevel: Int16, notes: String?, orderID: Int16) -> Humidor {
        let entityHumidor = NSEntityDescription.entity(forEntityName: "Humidor", in: self.context)
        let newHumidor = Humidor (entity: entityHumidor!, insertInto: context)
        
        newHumidor.name = name
        newHumidor.createDate = Date()
        newHumidor.humidity = humidityLevel
        newHumidor.orderID = orderID
        newHumidor.notes = notes
        self.saveContext()
        
        return newHumidor
    }
    
    /* New Tray */
    func addNewTray (name: String,humidor: Humidor, orderID: Int16) -> Tray {
        let entityTray = NSEntityDescription.entity(forEntityName: "Tray", in: self.context)
        let newTray = Tray (entity: entityTray!, insertInto: context)
        
        newTray.name = name
        newTray.orderID = orderID
        humidor.addToTrays(newTray)
        self.saveContext()
        
        return newTray
    }
    
    
    /* New Cigar */
    func addNewCigar (tray: Tray, name: String, origin: String, quantity: Int32 , size: String, purchaseDate: Date?, from: String?, price: Double?, ageDate: Date?,image: Data?, notes: String?) -> Cigar {
        let currentDate = Date()
        let entityCigar = NSEntityDescription.entity(forEntityName: "Cigar", in: self.context)
        let newCigar = Cigar (entity: entityCigar!, insertInto: context)
        newCigar.name = name
        newCigar.origin = origin
        newCigar.quantity = quantity
        newCigar.size = size
        newCigar.purchaseDate = purchaseDate
        newCigar.from = from
        newCigar.price = price!
        newCigar.ageDate = ageDate
        newCigar.notes = notes
        newCigar.creationDate = currentDate
        newCigar.editDate = currentDate
        newCigar.image = image
        tray.addToCigars(newCigar)
        updateHumidorValues(tray: tray, quantity: quantity, value: price!, add: true)
        self.saveContext()
        
        return newCigar
        
    }
    
    func countHumidors() -> Int{
        var count: Int = NSNotFound
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Humidor")
        do {
            count = try context.count(for: request)
            return count
        }
        catch let error as NSError{
            print("Error: \(error.localizedDescription)")
            return 0
        }
    }
    
    
    func moveCigar(destinationTray: Tray, cigar: Cigar){
        if cigar.tray!.humidor! != destinationTray.humidor!{
            self.updateHumidorValues(tray: cigar.tray!, quantity: cigar.quantity, value: cigar.price, add: false)
            self.updateHumidorValues(tray: destinationTray, quantity: cigar.quantity, value: cigar.price, add: true)
        }
        cigar.tray! = destinationTray
        self.saveContext()
    }
    
    
    
    func updateCigarQuantity(cigar: Cigar, quantity: Int32, add: Bool){
        let pricePerCigar = cigar.price/Double(cigar.quantity)
        if add{
            cigar.quantity = cigar.quantity + quantity
            cigar.price = Double(cigar.quantity) * pricePerCigar
            self.updateHumidorValues(tray: cigar.tray!, quantity: quantity, value: Double(quantity) * pricePerCigar, add: true)
        }
        else{
            cigar.quantity = cigar.quantity - quantity
            cigar.price = Double(cigar.quantity) * pricePerCigar
            self.updateHumidorValues(tray: cigar.tray!, quantity: quantity, value: Double(quantity) * pricePerCigar, add: false)
        }
        self.saveContext()
    }
 
    func deleteHumidor(humidor:Humidor){
        self.context.delete(humidor)
        self.saveContext()
    }
    
    func setHumidorOrderID(humidor: Humidor, orderID: Int16){
        humidor.orderID = orderID
        self.saveContext()
    }
    
    
    func deleteCigar(cigar: Cigar){
        self.context.delete(cigar)
        self.updateHumidorValues(tray: cigar.tray!, quantity: cigar.quantity, value: cigar.price, add: false)
        self.saveContext()
    }
    
    
    /* Updates humidor cigar quantity */
    func updateHumidorValues (tray: Tray, quantity: Int32, value: Double, add: Bool){
        var currentNumberOfCigarsHumidor = tray.humidor?.value(forKey: "quantity") as! Int32
        var currentValue = tray.humidor?.value(forKey: "value") as! Double
        if add{
            currentValue += value
            currentNumberOfCigarsHumidor += quantity
        }
        else{
            currentValue -= value
            currentNumberOfCigarsHumidor -= quantity
            }
        tray.humidor?.quantity = currentNumberOfCigarsHumidor
        tray.humidor?.value = currentValue
    }
    
    /* Humidors can't have same name */
    func searchHumidor(name: String) -> Humidor? {
        var humidor: Humidor?
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Humidor")
        request.predicate = NSPredicate(format: "name = %@", name)
        request.returnsObjectsAsFaults = false
        
        do {
            let result: NSArray = try context.fetch(request) as NSArray
            switch result.count {
            case 0:  // not found
                return nil
                
            case 1: // found
                humidor = result[0] as? Humidor
                return humidor!
            default:
                return nil
            }
            
        } catch let error {
            let fetchError = error as NSError
            print(fetchError)        }
        
        return nil
    }
    
    
    func fetchHumidors() -> [Humidor] {
        let humidors: [Humidor]
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Humidor")
        let sort = NSSortDescriptor(key: #keyPath(Humidor.orderID), ascending: true)
        request.sortDescriptors = [sort]
        do {
            humidors = try context.fetch(request) as! [Humidor]
        } catch {
            fatalError("Failed to fetch humidors: \(error)")
        }
        return humidors
    }
    
    
    
    func searchTray(humidor: Humidor, searchTray: String) -> Tray? {
        let traysArray = humidor.trays?.allObjects as! [Tray]
        for tray in traysArray{
            if tray.name! == searchTray{
                return tray
            }
            
        }
        return nil
    }
    
     /* Save Context */
    private func saveContext(){
        do {
            try self.context.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
    
    
}
