//
//  HomeViewController.swift
//  CigarStack
//
//  Created by Darius Pasca on 13/03/2018.
//  Copyright © 2018 Darius Pasca. All rights reserved.
//

import UIKit
import PagingKit
import SideMenu

class HomeViewController: UIViewController, UIScrollViewDelegate, ContainerTableDelegate, UISideMenuNavigationControllerDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentViewHeight: NSLayoutConstraint!
    @IBOutlet weak var topBar: UIView!
    
    var humidor: Humidor?
    var trays: [Tray]!
    
    /* Humidor Informations */
    @IBOutlet weak var humidorName: UILabel!
    @IBOutlet weak var humidorHumidity: UILabel!
    @IBOutlet weak var humidorCigars: UILabel!
    @IBOutlet weak var humidorValue: UILabel!
    
    @IBOutlet weak var moreButton: UIBarButtonItem!
    
    var menuViewController: PagingMenuViewController?
    var contentViewController: PagingContentViewController?
    @IBOutlet weak var menuViewControllerContainerView: UIView!
    @IBOutlet weak var contentViewControllerContainer: UIView!
    
    static var sizingCell = TitleLabelMenuViewCell(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
    var dataSource = [(menu: String, content: UIViewController)]()
    
    
    lazy var firstLoad: (() -> Void)? = { [weak self, menuViewController, contentViewController] in
        menuViewController?.reloadData()
        contentViewController?.reloadData()
        self?.firstLoad = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.shadowImage = UIImage()
        scrollView.delegate = self
        setupSideMenu()
        
        //Resets sort order to default
        UserSettings.tableSortOrder = TableSortOrder(rawValue: UserSettings.defaultSortOrder.value)!
        
        menuViewController?.register(type: TitleLabelMenuViewCell.self, forCellWithReuseIdentifier: "identifier")
        menuViewController?.registerFocusView(view: UnderlineFocusView())
        contentViewController?.scrollView.isScrollEnabled = false
        
        if UserSettings.currentHumidor.value == "" {
            topBar.isHidden = true
            menuViewControllerContainerView.isHidden = true
            moreButton.isEnabled = false
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        firstLoad?()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Check if there is a humidor
        if UserSettings.currentHumidor.value != "" {
            
            //Reloads the entire view content
            if UserSettings.shouldReloadView.value{
             
                moreButton.isEnabled = true // If is the first humidor @moreButton is disabled and need to be enabled
                scrollView.contentOffset.y = 0.0  //Goes back to top when changing humidor
                fetchHumidorData()
                setupMenuViewData()
                
                // When adding first humidor the topBar and the navigation menu is hidden ( the content view not because it is used for the dnzempty)
                if topBar.isHidden{
                    self.topBar.isHidden = false
                    self.menuViewControllerContainerView.isHidden = false
                    //Fede in animation
                    UIView.animate(withDuration: 1.0, delay: 0, options: [], animations: {
                        self.topBar.alpha = 1;
                        self.menuViewControllerContainerView.alpha = 1
                    }, completion: nil)
                    setupHumidorViewData(withAnimation: false)
                }
                else{
                    setupHumidorViewData(withAnimation: true)
                }
                
                // Reloads data from first menu - if not specified generates layout mess
                menuViewController?.reloadData(with: 0, completionHandler: nil)
                contentViewController?.reloadData(with: 0, completion: nil)
                
                //Set the container view height
                let firstView = dataSource[0].content as! ContentTableViewController
                firstView.isSelected()
                UserSettings.shouldReloadView.value = false
            }
                
                // Reloads only the container view ( eg: when cigar has been added )
            else if UserSettings.shouldReloadData.value{
                setupMenuViewData()
                setupHumidorViewData(withAnimation: true)
                contentViewController?.reloadData()
                
                //Sets the container view height
                let selectedView = dataSource[(menuViewController?.currentFocusedIndex)!].content as! ContentTableViewController
                selectedView.isSelected()
                UserSettings.shouldReloadData.value = false
            }
        }
            
        //This is called when all humidors are deleted or there are none
        else{
            setupMenuViewData()
            
            //gives the container a standard height otherwise results 0 when deleting all humidors ( 100 top bar , 44 menu)
            contentViewHeight.constant = self.view.frame.height - 144.0
            
            //If the moreButton is enabled means that all humidors have been deleted, otherwise would be disabled from viewDidLoad
            if moreButton.isEnabled {
                moreButton.isEnabled = false
                 //More animations
                
                UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
                    self.topBar.alpha = 0;
                    self.menuViewControllerContainerView.alpha = 0
                    self.contentViewControllerContainer.alpha = 0
                }, completion: { _ in
                    self.topBar.isHidden = true;
                    self.menuViewControllerContainerView.isHidden = true;
                    self.contentViewController?.reloadData();
                    self.menuViewController?.reloadData();
                    UIView.animate(withDuration: 0.5, delay: 0, options: [], animations: {
                        self.contentViewControllerContainer.alpha = 1
                    }, completion: nil)
                })
            }
            UserSettings.shouldReloadView.value = false
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let offSet = scrollView.contentOffset.y
            if offSet > 34 {
                self.navigationItem.title = UserSettings.currentHumidor.value
            }
                
            else if offSet < 28{
                self.navigationItem.title = ""
            }
    }
    
    
    //MARK: - Setups
     func setupSideMenu() {
        SideMenuManager.default.menuLeftNavigationController = storyboard!.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as? UISideMenuNavigationController
        SideMenuManager.default.menuAddPanGestureToPresent(toView: self.navigationController!.navigationBar)
        SideMenuManager.default.menuFadeStatusBar = false
    }
    
    func setupHumidorViewData(withAnimation: Bool){
        if withAnimation{
            humidorName.fadeTransition(1.1)
            humidorHumidity.fadeTransition(1.1)
            humidorCigars.fadeTransition(1.1)
            humidorValue.fadeTransition(1.1)
        }
        humidorName.text = humidor!.name
        humidorHumidity.text = String(humidor!.humidity) + " %"
        humidorCigars.text = String((humidor!.quantity))
        humidorValue.text = humidor!.value.asLocalCurrency
    }
    
    func setupMenuViewData(){
        dataSource.removeAll()
        if UserSettings.currentHumidor.value != ""{
            for  i in 0...trays.count-1{
                let vc = UIStoryboard(name: "ContentTableViewController", bundle: nil).instantiateInitialViewController() as! ContentTableViewController
                vc.tray = trays[i]
                vc.delegate = self
                dataSource.append((menu: trays[i].name!, content: vc))
            }
        }
        else{
            let vc = EmptyTableViewController()
            vc.superViewHeight = self.view.frame.height
            dataSource.append((menu: "", content: vc))
        }
    }
    
    //MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "newHumidor"{
            if UserSettings.isPremium.value == false {
                let count = CoreDataController.sharedInstance.countHumidors()
                if count > 1{
                    print("fart")
                }
            }
        }
        
        /* Setup PagingKit */
        if let vc = segue.destination as? PagingMenuViewController {
            menuViewController = vc
            menuViewController?.dataSource = self
            menuViewController?.delegate = self
        } else if let vc = segue.destination as? PagingContentViewController {
            contentViewController = vc
            contentViewController?.delegate = self
            contentViewController?.dataSource = self
        }
    }
    
    
    //MARK: - Data
    func fetchHumidorData(){
        humidor = CoreDataController.sharedInstance.searchHumidor(name: UserSettings.currentHumidor.value)
        trays = (humidor!.trays?.allObjects as! [Tray]).sorted(by: { $0.orderID < $1.orderID })
    }
    
    //MARK: - Sort Alert
    
    @IBAction func more(_ sender: UIBarButtonItem) {
        
        let optionMenu = UIAlertController(title: nil, message: NSLocalizedString("Sort by", comment: ""), preferredStyle: .actionSheet)
        optionMenu.view.tintColor = UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1)
        let sortEnum: [TableSortOrder] = [.byDate, .byName, .byQuantity, .byPrice, .byCountry, .byAge]
        for enumOption in sortEnum{
            let alert = UIAlertAction(title: enumOption.displayName, style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                UserSettings.tableSortOrder = enumOption
                UserSettings.shouldReloadView.value = true
                self.viewWillAppear(true)
            })
            if alert.title! == UserSettings.tableSortOrder.displayName{
                alert.setValue(true, forKey: "checked")
                UserSettings.shouldReloadView.value = false
            }
            optionMenu.addAction(alert)
        }

        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in })
        
        optionMenu.addAction(cancelAction)
        optionMenu.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    
    //MARK: - Delegates
    
    /* Changes the tableview container height based on content hight*/
    func dataChanged(height: CGFloat) {
        contentViewHeight.constant = height
        self.view.layoutIfNeeded()
    }
    
    func updateData(container: Tray){
        var found = false
        for data in dataSource{
            if data.menu == container.name!{
                found = true
                setupMenuViewData()
                contentViewController?.reloadData()
                break
            }
        }
        if !found{
            self.fetchHumidorData()
            self.setupHumidorViewData(withAnimation: true)
        }
    }
    
    func deleteDelegate() {
        fetchHumidorData()
        setupHumidorViewData(withAnimation: true)
    }
    
}

extension HomeViewController: PagingMenuViewControllerDataSource {
    func menuViewController(viewController: PagingMenuViewController, cellForItemAt index: Int) -> PagingMenuViewCell {
        let cell = viewController.dequeueReusableCell(withReuseIdentifier: "identifier", for: index)  as! TitleLabelMenuViewCell
        cell.titleLabel.text = dataSource[index].menu
        return cell
    }
    
    func menuViewController(viewController: PagingMenuViewController, widthForItemAt index: Int) -> CGFloat {
        HomeViewController.sizingCell.titleLabel.text = dataSource[index].menu
        var referenceSize = UILayoutFittingCompressedSize
        referenceSize.height = viewController.view.bounds.height
        let size = HomeViewController.sizingCell.systemLayoutSizeFitting(referenceSize)
        return size.width
    }
    
    
    func numberOfItemsForMenuViewController(viewController: PagingMenuViewController) -> Int {
        return dataSource.count
    }
}

extension HomeViewController: PagingContentViewControllerDataSource {
    func numberOfItemsForContentViewController(viewController: PagingContentViewController) -> Int {
        return dataSource.count
    }
    
    func contentViewController(viewController: PagingContentViewController, viewControllerAt Index: Int) -> UIViewController {
        return dataSource[Index].content
    }
}

extension HomeViewController: PagingMenuViewControllerDelegate {
    func menuViewController(viewController: PagingMenuViewController, didSelect page: Int, previousPage: Int) {
        let child = dataSource[page].content as! ContentTableViewController
        child.isSelected()
        contentViewController?.scroll(to: page, animated: true)
    }
}

extension HomeViewController: PagingContentViewControllerDelegate {
    func contentViewController(viewController: PagingContentViewController, didManualScrollOn index: Int, percent: CGFloat) {
        menuViewController?.scroll(index: index, percent: percent, animated: false)
    }
}

extension UIView {
    func fadeTransition(_ duration:CFTimeInterval) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name:
            kCAMediaTimingFunctionEaseInEaseOut)
        animation.type = kCATransitionFade
        animation.duration = duration
        layer.add(animation, forKey: kCATransitionFade)
    }
}


