//
//  ViewController.swift
//  ValleyQuestApp
//
//  Created by John Kotz on 9/29/15.
//  Copyright © 2015 Valley Quest App Dev. All rights reserved.
//

import UIKit
import Parse
import CoreSpotlight
import SCLAlertView
import Crashlytics

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}

class QuestController: UITableViewController, UIViewControllerPreviewingDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var revealButton: UIBarButtonItem!
    
    let searchController = UISearchController(searchResultsController: nil)
    var quests = [Quest]()
    var filteredQuests = [Quest]()
    var savedQuests = [Quest]()
    var loading = false
    
    var topGestureRecognizer = UIGestureRecognizer()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "Quests"
        
        if( traitCollection.forceTouchCapability == .Available){
            
            registerForPreviewingWithDelegate(self, sourceView: view)
            
        }
        
        if let delegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            delegate.registerMainViewController(self)
        }
        
        // Add a search bar
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.scopeButtonTitles = ["Name", "Location"]
        searchController.searchBar.tintColor = UIColor.whiteColor()
        searchController.searchBar.backgroundColor = UIColor(netHex: 0x4DC45F)
        searchController.searchBar.barTintColor = UIColor(netHex: 0x4DC45F)
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        // Add a refresh control
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl?.backgroundColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
        self.refreshControl?.tintColor = UIColor.whiteColor()
        self.refreshControl?.addTarget(self, action: #selector(QuestController.refreshData), forControlEvents: UIControlEvents.ValueChanged)
        
        self.refreshControl?.beginRefreshing()
//        setUpHamberger()
        refreshData()
        
        let infoButton = UIButton(type: .InfoLight)
        infoButton.addTarget(self, action: #selector(QuestController.showInfo), forControlEvents: .TouchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: infoButton)
        
        if NSUserDefaults.standardUserDefaults().objectForKey("hasLaunched") == nil || !NSUserDefaults.standardUserDefaults().boolForKey("hasLaunched") {
            showInfo()
        }
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "hasLaunched")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        State.loadQuestInProgress { (quest, error) in
            if let _ = quest where error == nil {
                self.tableView.reloadData()
            }
        }
    }
    
    func tappedTopNavBar() {
        self.tableView.setContentOffset(CGPointMake(0, -self.searchController.searchBar.frame.height * 1.4), animated: true)
    }
    
    func showInfo() {
        self.performSegueWithIdentifier("firstOpen", sender: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        if quests.count == 0 && loading {
            self.refreshControl?.beginRefreshing()
        }
    }
    
    func setUpHamberger() {
        if let revealViewController = self.revealViewController() {
            self.revealButton.target = self
            self.revealButton.action = #selector(QuestController.toggleSide)
            self.navigationController?.navigationBar.addGestureRecognizer(revealViewController.panGestureRecognizer())
            self.view.addGestureRecognizer(revealViewController.panGestureRecognizer())
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        if self.loading {
            self.tableView.setContentOffset(CGPointMake(0, -self.refreshControl!.frame.size.height), animated: true)
            self.refreshControl?.beginRefreshing()
        }
        
        self.tableView.reloadData()
        refreshData()
        
        topGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(QuestController.tappedTopNavBar))
        self.navigationController?.navigationBar.addGestureRecognizer(topGestureRecognizer)
        
//        self.navigationController?.navigationBar.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
//        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }
    
    override func viewWillDisappear(animated: Bool) {
//        self.view.removeGestureRecognizer(self.revealViewController().panGestureRecognizer())
        self.navigationController?.navigationBar.removeGestureRecognizer(topGestureRecognizer)
    }
    
    func toggleSide() {
        self.revealViewController().revealToggle(nil)
    }
    
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        self.updateSearchResultsForSearchController(searchController)
    }
    
    func isSearching() -> Bool {
        return self.searchController.active && self.searchController.searchBar.text != ""
    }
    
    func getQuestAt(indexPath: NSIndexPath) -> Quest {
        return getQuestListAt(indexPath.section)[indexPath.row]
    }
    
    func getQuestListAt(section: Int) -> [Quest] {
        if self.isSearching() {
            return filteredQuests
        }
        
        switch section {
        case 0:
            if let questInProgress = State.questInProgress where State.hasQuestLoaded() {
                return [questInProgress]
            }else if savedQuests.count > 0 {
                return savedQuests
            }else{
                return quests
            }
        case 1:
            if savedQuests.count > 0 && State.hasQuestLoaded() {
                return savedQuests
            }else{
                return quests
            }
        default:
            return quests
        }
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filteredQuests = quests.filter({ (quest) -> Bool in
            if searchController.searchBar.scopeButtonTitles![searchController.searchBar.selectedScopeButtonIndex] == "Name" {
                return quest.Name.lowercaseString.containsString(searchController.searchBar.text!.lowercaseString)
            }else{
                return quest.Location.lowercaseString.containsString(searchController.searchBar.text!.lowercaseString)
            }
        })
        self.tableView.reloadData()
    }
    
    func refreshData() {
        loading = true
        self.refreshControl?.beginRefreshing()
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Refreshing...")
        let object = PFQuery(className: "serverMove")
        object.findObjectsInBackgroundWithBlock { (objects, error) in
            if let objects = objects where objects.count > 0 {
                SCLAlertView().showNotice("Server moved", subTitle: "The sever has been moved to a new location. Please update the app to get the right data")
            }
            
            let reach = Reachability.reachabilityForInternetConnection()
            
            let firstQuery: PFQuery = PFQuery(className: "Quests")
            firstQuery.limit = 1000
            firstQuery.fromLocalDatastore()
            firstQuery.findObjectsInBackgroundWithBlock({ (objects, error) in
                if let objects = objects as? [Quest] {
                    self.savedQuests.removeAll()
                    for object in objects {
                        if State.questInProgress != nil && object.objectId != State.questInProgress?.objectId {
                            self.savedQuests.append(object)
                        }else if State.questInProgress == nil {
                            self.savedQuests.append(object)
                        }
                    }
                    Quest.sortQuests(&self.savedQuests)
                    self.tableView.reloadData()
                }
            })
            
            if (reach.currentReachabilityStatus() != NotReachable) {
                let query: PFQuery = PFQuery(className: "Quests")
                query.limit = 1000
                self.completeRefreshQuery(query){ (success, error) in
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                    self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
                    self.loading = false
                }
            }
        }
    }
    
    func completeRefreshQuery(query: PFQuery, callback: (Bool, NSError?) -> Void) {
        query.findObjectsInBackgroundWithBlock { (results: [PFObject]?, error: NSError?) -> Void in
            
            if let checkedResults = results {
                CSSearchableIndex.defaultSearchableIndex().deleteAllSearchableItemsWithCompletionHandler(nil)
                self.quests = Quest.getQuestsFromPFOBjects(checkedResults)
                Quest.sortQuests(&self.quests)
                callback(true, error)
                return
            }
            callback(false, error)
        }
    }
    
    // For providing that side scroll thing. Not decided
//    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
//        return ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
//    }
    
    func hideRefreshControl() {
        self.refreshControl?.endRefreshing()
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        // Tells the cell how tall to be
        return 90
    }
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
        showViewController(viewControllerToCommit, sender: nil)
    }
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        let indexPath = self.tableView.indexPathForRowAtPoint(location)!
        
        let cell = self.tableView.cellForRowAtIndexPath(indexPath)!
        
        if let detailView = storyboard?.instantiateViewControllerWithIdentifier("QuestDetailViewController") as? QuestDetailViewController {
        
            let quest = self.getQuestAt(indexPath)
            detailView.setQuestObject(quest)
            detailView.delegate = self
            
            detailView.preferredContentSize = CGSize(width: 0.0, height: 500)
            previewingContext.sourceRect = cell.frame
            
            Answers.logCustomEventWithName("Quest Preview", customAttributes: [:])
            
            return detailView
        }
        return nil;
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // This is the number of cells to show
        return getQuestListAt(section).count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.isSearching() {
            return nil
        }
        
        if self.savedQuests.count > 0 && !self.isSearching() {
            if State.hasQuestLoaded() {
                if section == 0 {
                    return "Active Quest"
                }else if section == 1 {
                    return "Saved Quests"
                }else{
                    return "All Quests"
                }
            }else{
                if section == 0 {
                    return "Saved Quests"
                }else{
                    return "All Quests"
                }
            }
        }
        
        if State.hasQuestLoaded() {
            if section == 0 {
                return "Active Quest"
            }else{
                return "All Quests"
            }
        }
        
        return nil
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // We have no need for sections, but we have to have one
        if isSearching() {
            return 1
        }
        
        return 1 + (self.savedQuests.count > 0 ? 1 : 0) + (State.hasQuestLoaded() ? 1 : 0)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Gets a cell with the tableView style under the QuestCell class
        var cell: UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("QuestCell")
        
        // If it can't find one, then we will load it from the actuall class
        if cell == nil {
            let nib: NSArray = NSBundle.mainBundle().loadNibNamed("QuestCell", owner: self, options: nil)
            cell = nib.objectAtIndex(0) as? UITableViewCell
        }
        
        let quest = getQuestAt(indexPath)
        
        // We need to prove that it is a Quest cell if we want to do all this
        if let checkedCell = cell as? QuestCell {
            // Setting the title and description
            checkedCell.setTitle(quest.Name)
            checkedCell.setSubTitle("Location: " + quest.Location + " - Difficulty: " + quest.Difficulty)
            checkedCell.subTitleLabel.textColor = UIColor.grayColor()
            if quest.isClosed() {
                checkedCell.setSubTitle("Closed")
                checkedCell.subTitleLabel.textColor = UIColor(red: 1.0, green: 0.5, blue: 0.5, alpha: 1.0)
            }
        }
        return cell!
    }
    
    func loadQuestView(id: String) {
        if let quest = PFObject(withoutDataWithClassName: "Quests", objectId: id) as? Quest {
            quest.fetchIfNeededInBackgroundWithBlock({ (quest, error) -> Void in
                if error == nil {
                    // We got a valid quest
                    // Lets pop all the view controllers
                    self.navigationController?.popViewControllerAnimated(true);
                    
                    self.performSegueWithIdentifier("showQuestDetail", sender: quest)
                }else{
                    print("Failed to load quest view!")
                }
            })
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let detailController = segue.destinationViewController as? QuestDetailViewController {
            // Check to see if the destination is detail view for a quest
            if let quest = sender as? Quest {
                detailController.setQuestObject(quest)
            }
            detailController.delegate = self
        }
        
        if let destination = segue.destinationViewController as? FirstLoadViewController {
            destination.goString = "Done"
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // This way we deselect the cell
        tableView.cellForRowAtIndexPath(indexPath)?.setSelected(false, animated: true)
        // A cell was clicked, so we will go to it's detail page
        self.performSegueWithIdentifier("showQuestDetail", sender: self.getQuestAt(indexPath))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
}

