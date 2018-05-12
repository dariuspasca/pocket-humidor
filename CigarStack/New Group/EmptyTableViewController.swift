//
//  EmptyTableViewController.swift
//  CigarStack
//
//  Created by Darius Pasca on 12/05/2018.
//  Copyright © 2018 Darius Pasca. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class EmptyTableViewController: UITableViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    var humidorNumber:Int?
    var superViewHeight: CGFloat!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        humidorNumber = CoreDataController.sharedInstance.countHumidors()
        tableView.tableFooterView = UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return humidorNumber ?? 0
    }
    
    // MARK: - DZNEmptyDataSet
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        
        let attributes =
            [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 20, weight: .light),
             NSAttributedStringKey.foregroundColor : UIColor.black,
             NSAttributedStringKey.backgroundColor : UIColor.clear]
        return NSAttributedString(string: NSLocalizedString("You don't have any humidors yet.", comment: ""), attributes: attributes)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attributes =
            [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 18, weight: .light),
             NSAttributedStringKey.foregroundColor : UIColor.darkGray,
             NSAttributedStringKey.backgroundColor : UIColor.clear]
        return NSAttributedString(string: NSLocalizedString("To add a humidor, tap the plus button in the right top corner.", comment: ""), attributes: attributes)
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "empty - humidor")
    }

    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        let offset = superViewHeight - 144.0 - (superViewHeight/2)
        return -offset/2
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
