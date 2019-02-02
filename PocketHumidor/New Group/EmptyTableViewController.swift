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
        return NSAttributedString(string: NSLocalizedString("To add a humidor, tap the + button in the right top corner.", comment: ""), attributes: attributes)
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "empty - humidor")
    }

    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        let offset = superViewHeight - 144.0 - (superViewHeight/2)
        return -offset/1.2
    }


}
