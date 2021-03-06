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
import MessageUI

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

let NEAR_DISTANCE = 1000 // miles

class QuestController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIViewControllerPreviewingDelegate, UISearchResultsUpdating, UISearchBarDelegate, MFMailComposeViewControllerDelegate {
    @IBOutlet weak var selector: NPSegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topSelector: NSLayoutConstraint!
    
    let searchController = UISearchController(searchResultsController: nil)
    var refreshControl = UIRefreshControl()
    var quests = [Quest]()
    var filteredQuests = [Quest]()
    var savedQuests = [Quest]()
    var nearQuests = [(Quest, String)]()
    
    let backColor = UIColor(netHex: 0x78db82)
    var loading = false
    var loggedSearch = false
    var showingNearMe = false
    var hasGPS = false
    var showNearMeSelector: Bool {
        set {
            selector.hidden = !newValue
            if !newValue {
                topSelector.constant = 0;
            }else{
                topSelector.constant = 50;
            }
        }
        get {
            return !selector.hidden
        }
    }
    
    var currentLocation: CLLocation?
    
    var topGestureRecognizer = UIGestureRecognizer()

    override func viewDidLoad() {
        super.viewDidLoad()
        showNearMeSelector = false
        
        if let delegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            delegate.locationController = LocationController()
            delegate.locationController?.getOneLocation({ (location) in
                self.currentLocation = location
                self.searchForNearQuests()
            })
        }
        
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "Quests"
        
        if( traitCollection.forceTouchCapability == .Available){
            
            registerForPreviewingWithDelegate(self, sourceView: view)
            
        }
        
        selector.cursor = UIImageView(image: UIImage(named: "tabindicator"))
        selector.setItems(["All quests", "Near me"]);
        selector.backgroundColor = backColor
        selector.unselectedFont = UIFont(name: "AvenirNext", size: 16)
        selector.selectedFont = UIFont(name: "AvenirNext-Bold", size: 16)
        selector.unselectedTextColor = UIColor(white: 1, alpha: 0.8)
        selector.unselectedColor = UIColor.clearColor()
        selector.selectedTextColor = UIColor(white: 1, alpha: 1)
        selector.selectedColor = UIColor(red: 67/255, green: 198/255, blue: 88/255, alpha: 1)
        
        if let delegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            delegate.registerMainViewController(self)
        }
        
        // Add a search bar
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.scopeButtonTitles = ["Name", "Location"]
        searchController.searchBar.tintColor = UIColor.whiteColor()
        searchController.searchBar.backgroundColor = backColor
        searchController.searchBar.barTintColor = backColor
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        // Add a refresh control
//        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
//        self.refreshControl.backgroundColor = backColor
//        self.refreshControl.tintColor = UIColor.whiteColor()
//        self.refreshControl.addTarget(self, action: #selector(QuestController.refreshData), forControlEvents: UIControlEvents.ValueChanged)
//        
//        self.refreshControl.beginRefreshing()
//        tableView.addSubview(refreshControl)
//        setUpHamberger()
        refreshData()
        
        let infoButton = UIButton(type: .InfoLight)
        infoButton.addTarget(self, action: #selector(QuestController.showInfo), forControlEvents: .TouchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: infoButton)
        
//        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Send feedback", style: .Plain, target: self, action: #selector(QuestController.sendFeedback))
        
        if NSUserDefaults.standardUserDefaults().objectForKey("hasLaunched") == nil || !NSUserDefaults.standardUserDefaults().boolForKey("hasLaunched") {
            showInfo()
        }
        
        State.loadQuestInProgress { (quest, error) in
            if let _ = quest where error == nil {
                self.tableView.reloadData()
            }
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients(["valleyquest@vitalcommunities.org", "John.P.Kotz.19@Dartmouth.edu"])
        mailComposerVC.setSubject("Valley Quest App feedback")
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        SCLAlertView().showError("Could not send email!", subTitle: "Your device could not send email.  Please check email configuration and try again")
    }
    
    // MARK: MFMailComposeViewControllerDelegate
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
        if result == .Sent {
            let alert = SCLAlertView()
            
            alert.addButton("Rate the app", action: { 
                UIApplication.sharedApplication().openURL(NSURL(string : "itms-apps://itunes.apple.com/app/id1083576851")!, options: [:], completionHandler: nil)
            })
                
            alert.showSuccess("Thank you!", subTitle: "We very much appreciate your feedback. If you would like to help us out further please rate the app")
        }else{
            showSendMailErrorAlert()
        }
    }
    
    func sendFeedback() {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.presentViewController(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    @IBAction func tappedNavBar(sender: AnyObject) {
        self.tableView.setContentOffset(CGPointMake(0, -self.searchController.searchBar.frame.height * 1.4), animated: true)
    }
    
    func showInfo() {
        self.performSegueWithIdentifier("firstOpen", sender: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        if quests.count == 0 && loading {
            self.refreshControl.beginRefreshing()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tableView.reloadData()
        refreshData()
    }
    
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        self.updateSearchResultsForSearchController(searchController)
    }
    
    func isSearching() -> Bool {
        return self.searchController.active && self.searchController.searchBar.text != ""
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        logSearchComplete(nil)
        loggedSearch = false
    }
    
    func logSearchComplete(quest: Quest?) {
        if !loggedSearch {
            var dict = ["type" : searchController.searchBar.scopeButtonTitles![searchController.searchBar.selectedScopeButtonIndex]]
            if let quest = quest {
                dict["selectedQuest"] = quest.Name
            }
            
            Answers.logCustomEventWithName("Searched", customAttributes: dict)
            
            
            GAI.sharedInstance().defaultTracker.send(GAIDictionaryBuilder.createEventWithCategory(USER_ACTION_KEY, action: "searched_by_" + dict["type"]!, label: quest?.objectId, value: nil).build() as [NSObject : AnyObject])
        }
        
        loggedSearch = true
    }
    
    func getQuestAt(indexPath: NSIndexPath) -> Quest {
        if showingNearMe {
            return nearQuests[indexPath.row].0
        }
        
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
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        showNearMeSelector = false
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        showNearMeSelector = hasGPS
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
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if scrollView.contentOffset.y > 50 || showingNearMe {
            selector.backgroundColor = UIColor.clearColor()
            selector.unselectedColor = backColor
        }else{
            selector.backgroundColor = backColor
            selector.unselectedColor = UIColor.clearColor()
        }
    }
    
    func searchForNearQuests() {
        print("Looking for near???")
        nearQuests.removeAll()
        if let myLoc = self.currentLocation {
            for quest in quests {
                if let delegate = UIApplication.sharedApplication().delegate as? AppDelegate where quest.hasGPS() {
                    let distance = delegate.locationController!.calculateDistance(quest.start!, end: myLoc);
                    
                    
                    print(distance.miles)
                    if distance.miles < Double(NEAR_DISTANCE) {
                        nearQuests.append((quest, "\(Int(distance.miles)) miles"));
                    }
                }
            }
            
            nearQuests.sortInPlace({ (obj1, obj2) -> Bool in
                return obj1.1 >= obj2.1;
            })
        }
    }
    
    func refreshData() {
        loading = true
            
        let reach = Reachability.reachabilityForInternetConnection()
        
        if (reach.currentReachabilityStatus() != NotReachable) {
            let query: PFQuery = PFQuery(className: "Quests")
            query.limit = 1000
            self.completeRefreshQuery(query){ (success, error) in
                self.tableView.reloadData()
                self.loading = false
            }
        }
        
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
    }
    
    func completeRefreshQuery(query: PFQuery, callback: (Bool, NSError?) -> Void) {
        query.findObjectsInBackgroundWithBlock { (results: [PFObject]?, error: NSError?) -> Void in
            
            if let checkedResults = results {
                CSSearchableIndex.defaultSearchableIndex().deleteAllSearchableItemsWithCompletionHandler(nil)
                let result = Quest.getQuestsFromPFOBjects(checkedResults)
                self.quests = result.0
                self.showNearMeSelector = result.1
                self.hasGPS = result.1
                Quest.sortQuests(&self.quests)
                
                
                if let delegate = UIApplication.sharedApplication().delegate as? AppDelegate where result.1 {
                    delegate.locationController?.getOneLocation({ (location) in
                        self.currentLocation = location
                        self.searchForNearQuests()
                    })
                }
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
        self.refreshControl.endRefreshing()
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // This is the number of cells to show
        if showingNearMe {
            return nearQuests.count
        }
        
        return getQuestListAt(section).count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if showingNearMe {
            return nil
        }
        
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
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // We have no need for sections, but we have to have one
        if showingNearMe {
            return 1
        }
        
        if isSearching() {
            return 1
        }
        
        return 1 + (self.savedQuests.count > 0 ? 1 : 0) + (State.hasQuestLoaded() ? 1 : 0)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Gets a cell with the tableView style under the QuestCell class
        var cell: UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("QuestCell")
        
        // If it can't find one, then we will load it from the actuall class
        if cell == nil {
            let nib: NSArray = NSBundle.mainBundle().loadNibNamed("QuestCell", owner: self, options: nil)!
            cell = nib.objectAtIndex(0) as? UITableViewCell
        }
        
        let quest = !showingNearMe ? getQuestAt(indexPath) : nearQuests[indexPath.row].0
        
        // We need to prove that it is a Quest cell if we want to do all this
        if let checkedCell = cell as? QuestCell {
            // Setting the title and description
            checkedCell.setTitle(quest.Name)
            checkedCell.setSubTitle("\(quest.Location) (\(quest.Difficulty))")
            if showingNearMe {
                checkedCell.setSubTitle("\(quest.Location) (Distance: \(nearQuests[indexPath.row].1))")
            }
            
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
            if NSUserDefaults.standardUserDefaults().boolForKey("hasLaunched") {
                destination.goString = "Done"
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // This way we deselect the cell
        tableView.cellForRowAtIndexPath(indexPath)?.setSelected(false, animated: true)
        
        let quest = self.getQuestAt(indexPath)
        if isSearching() {
            logSearchComplete(quest)
        }
        // A cell was clicked, so we will go to it's detail page
        self.performSegueWithIdentifier("showQuestDetail", sender: quest)
    }
    
    @IBAction func selectorChangedValue(sender: NPSegmentedControl) {
        self.showingNearMe = sender.selectedIndex() == 1
        
        tableView.tableHeaderView = sender.selectedIndex() == 1 ? nil : searchController.searchBar
        
        
        sender.backgroundColor = sender.selectedIndex() == 1 ? UIColor.clearColor() : backColor
        sender.unselectedColor = sender.selectedIndex() == 1 ? backColor : UIColor.clearColor()
        
        refreshControl.backgroundColor = sender.selectedIndex() == 1 ? UIColor.whiteColor() : backColor
        
        self.refreshControl.tintColor = sender.selectedIndex() == 1 ? UIColor.blackColor() : UIColor.whiteColor()
        
        searchForNearQuests()
        self.tableView.reloadData()
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

