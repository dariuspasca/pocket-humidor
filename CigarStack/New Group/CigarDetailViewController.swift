//
//  CigarDetailViewController.swift
//  CigarStack
//
//  Created by Darius Pasca on 17/07/2018.
//  Copyright © 2018 Darius Pasca. All rights reserved.
//

import UIKit
import CoreData

class CigarDetailViewController: UIViewController {
    
    var cigar: Cigar!
    
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        sizeLabel.text = cigar.size
        nameLabel.text = cigar.name
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation{
        return .slide
    }
    
    @IBAction func cancel(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }

}
