//
//  CloudDataManager.swift
//  PocketHumidor
//
//  Created by Darius Pasca on 16/03/2019.
//  Copyright © 2019 Darius Pasca. All rights reserved.
//

import Foundation

class CloudDataManager {
    
    var containerUrl: URL? {
        return FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents")
    }
    
    let temporaryDirectoryURL = NSURL.fileURL(withPath: NSTemporaryDirectory(), isDirectory: true)
    
    func doBackup() {
        
        if self.isCloudEnabled(){
            self.checkIfContainerExists()
            
            let exporter = CigarCSVExporter()
            exporter.exportData(saveFileTo: temporaryDirectoryURL, completion: { (fileURL) in
                if fileURL != nil {
                    if FileManager.default.fileExists(atPath: containerUrl!.appendingPathComponent(fileURL!.lastPathComponent).path) {
                        self.removeFile(fileURL: containerUrl!.appendingPathComponent(fileURL!.lastPathComponent))
                    }
                    self.moveFile(temporaryFileURL: fileURL!, fileURL: containerUrl!.appendingPathComponent(fileURL!.lastPathComponent))
                }
                
            })
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
    
    func moveFile(temporaryFileURL: URL, fileURL: URL) {
        do {
            try FileManager.default.moveItem(at: temporaryFileURL,to: fileURL)
        } catch let error as NSError {
            print("Failed moving file : \(error)")
        }
    }
    
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
            catch {
                print(error.localizedDescription)
            }
        }
    }

    
}
