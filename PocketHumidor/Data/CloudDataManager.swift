//
//  CloudDataManager.swift
//  PocketHumidor
//
//  Created by Darius Pasca on 16/03/2019.
//  Copyright © 2019 Darius Pasca. All rights reserved.
//

import Foundation
import UIKit

class CloudDataManager {
    
    var containerUrl: URL? {
        return FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents")
    }


    let temporaryDirectoryURL = NSURL.fileURL(withPath: NSTemporaryDirectory(), isDirectory: true)
    
    func runBackup(completion:((Bool) -> Void)? = nil) {
        
        //Check if iCloud is enabled
        if self.isCloudEnabled(){
            //Check if there are any items, otherwise no need for a backup
            let cigars = CoreDataController.sharedInstance.fetchCigars()
            if cigars != nil && !cigars!.isEmpty{
                
                //Creates iCloud documents directory if doesn't exists
                self.checkIfContainerExists()
                
                let exporter = CigarCSVExporter()
                
                //Data formatter
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                
                
                // Device Name - Date - AppVersion.DeviceIdentifier
                let fileName = "\(UIDevice.current.name) - \(dateFormatter.string(from: Date())) - \(UserSettings.currentVersion.value).\(UIDevice.current.identifierForVendor!.uuidString)"
                
                /* Creates csv file and saves it to temp directory
                   Checks if there is already a backup from the same device in iCloud directory
                   If there is, it removes it and moves the new backup file from the temp directory to iCloud container
 
                */
    
                exporter.exportData(saveFileTo: temporaryDirectoryURL, dataFileName: fileName, completion: { (fileURL) in
                    if fileURL != nil {
                        
                       /*
                        if FileManager.default.fileExists(atPath: containerUrl!.appendingPathComponent(fileURL!.lastPathComponent).path) {
                            self.removeFile(fileURL: containerUrl!.appendingPathComponent(fileURL!.lastPathComponent))
                        }
                       */
                        self.removeFiles()
                        
                        self.moveFile(temporaryFileURL: fileURL!, fileURL: containerUrl!.appendingPathComponent(fileURL!.lastPathComponent))
                        completion?(true)
                    }
                    
                })
            }
            
        }
    }
    
    // Return true if iCloud is enabled
    
    func isCloudEnabled() -> Bool {
        if FileManager.default.ubiquityIdentityToken != nil {
            return true
        }
        else {
            return false
        }
    }
    
    // Move file from @temporaryFileURL to @fileURL
    
    func moveFile(temporaryFileURL: URL, fileURL: URL) {
        do {
            try FileManager.default.moveItem(at: temporaryFileURL,to: fileURL)
        } catch let error as NSError {
            print("Failed moving file : \(error)")
        }
    }
    
    // Delete file at URL
    
    func removeFile(fileURL: URL) {
        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch let error as NSError {
            print("Failed moving file : \(error)")
        }
    }

    
    // Delete All files at URL
    
    func deleteFilesInDirectory(url: URL?) {
        let fileManager = FileManager.default
        let enumerator = fileManager.enumerator(atPath: url!.path)
        while let file = enumerator?.nextObject() as? String {
            
            do {
                try fileManager.removeItem(at: url!.appendingPathComponent(file))
                print("Files deleted")
            } catch let error as NSError {
                print("Failed deleting files : \(error)")
            }
        }
    }
    
    //Checks if iCloud "Documents" directory exists; otherwise creates one

    func checkIfContainerExists(){
        if let url = self.containerUrl, !FileManager.default.fileExists(atPath: url.path, isDirectory: nil) {
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            }
            catch let error as NSError {
                 print("Failed to create iCloud container: \(error)")
            }
        }
    }
    
    //Removes all files with the same DeviceID
    
    func removeFiles(){
        do {
            let filePaths = try FileManager.default.contentsOfDirectory(atPath: containerUrl!.path)
            for filePath in filePaths {
                if filePath.hasSuffix(UIDevice.current.identifierForVendor!.uuidString) {
                    self.removeFile(fileURL: containerUrl!.appendingPathComponent(filePath))
                }
            }
        } catch let error as NSError {
            print("Could not clear temp folder: \(error)")
        }
        
    }

    
}
