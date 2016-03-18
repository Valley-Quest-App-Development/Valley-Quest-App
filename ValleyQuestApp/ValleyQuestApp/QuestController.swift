//
//  ViewController.swift
//  ValleyQuestApp
//
//  Created by John Kotz on 9/29/15.
//  Copyright © 2015 Valley Quest App Dev. All rights reserved.
//

import UIKit
import Parse

class QuestController: UITableViewController, UIViewControllerPreviewingDelegate, UISearchResultsUpdating {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let searchController = UISearchController(searchResultsController: nil)
    var quests = [Quest]();
    var filteredQuests = [Quest]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "Quests"
        
        if( traitCollection.forceTouchCapability == .Available){
            
            registerForPreviewingWithDelegate(self, sourceView: view)
            
        }
        
        // Add a search bar
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        // Add a refresh control
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.backgroundColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
        self.refreshControl?.tintColor = UIColor.whiteColor()
        self.refreshControl?.addTarget(self, action: "refreshData", forControlEvents: UIControlEvents.ValueChanged)
        
//        self.refreshControl?.beginRefreshing()
        refreshData()
    }
    
    func getQuestAt(indexPath: NSIndexPath) -> Quest {
        if self.searchController.active && self.searchController.searchBar.text != "" {
            return filteredQuests[indexPath.row]
        }else{
            return quests[indexPath.row]
        }
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filteredQuests = quests.filter({ (quest) -> Bool in
            return quest.Name.lowercaseString.containsString(searchController.searchBar.text!.lowercaseString)
        })
        self.tableView.reloadData()
    }
    
    func refreshData() {
        let query: PFQuery = PFQuery(className: "Quests")
        query.findObjectsInBackgroundWithBlock { (results: [PFObject]?, error: NSError?) -> Void in
            
            if let checkedResults = results {
                self.quests = Quest.getQuestsFromPFOBjects(checkedResults)
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.refreshControl?.endRefreshing()
                self.tableView.reloadData()
            })
        }
    }
    
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
        guard let indexPath = self.tableView.indexPathForRowAtPoint(location) else {return nil}
        
        guard let cell = self.tableView.cellForRowAtIndexPath(indexPath) else {return nil}
        
        guard let detailView = storyboard?.instantiateViewControllerWithIdentifier("QuestDetailViewController") as? QuestDetailViewController else {return nil}
        
        let quest = self.getQuestAt(indexPath)
        detailView.setQuestObject(quest)
        
        detailView.preferredContentSize = CGSize(width: 0.0, height: 500)
        previewingContext.sourceRect = cell.frame
        return detailView
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // This is the number of cells to show
        if self.searchController.active && self.searchController.searchBar.text != "" {
            return filteredQuests.count
        }
        return quests.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // We have no need for sections, but we have to have one
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Gets a cell with the tableView style under the QuestCell class
        var cell: UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("QuestCell")
        
        // If it can't find one, then we will load it from the actuall class
        if cell == nil {
            let nib: NSArray = NSBundle.mainBundle().loadNibNamed("QuestCell", owner: self, options: nil)
            cell = nib.objectAtIndex(0) as? UITableViewCell
        }
        
        // We need to prove that it is a Quest cell if we want to do all this
        if let checkedCell = cell as? QuestCell {
            if self.searchController.active && searchController.searchBar.text != "" {
                // Setting the title and description
                checkedCell.setTitle(filteredQuests[indexPath.row].Name)
                checkedCell.setSubTitle("Location: " + filteredQuests[indexPath.row].Location + " - Difficulty: " + filteredQuests[indexPath.row].Difficulty)
            }else{
                // Setting the title and description
                checkedCell.setTitle(quests[indexPath.row].Name)
                checkedCell.setSubTitle("Location: " + quests[indexPath.row].Location + " - Difficulty: " + quests[indexPath.row].Difficulty)
            }
            // Done. Lets give them the cell
            return checkedCell
        }
        return cell!
    }
    
    func loadQuestView(id: String) {
        if let quest = PFObject(withoutDataWithClassName: "Quests", objectId: id) as? Quest {
            quest.fetchIfNeededInBackgroundWithBlock({ (quest, error) -> Void in
                self.performSegueWithIdentifier("showQuestDetail", sender: quest)
            })
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let detailController = segue.destinationViewController as? QuestDetailViewController {
            // Check to see if the destination is detail view for a quest
            if let quest = sender as? Quest {
                detailController.setQuestObject(quest)
            }
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
}

