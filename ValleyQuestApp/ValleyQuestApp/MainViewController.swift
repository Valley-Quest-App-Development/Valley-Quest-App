//
//  ViewController.swift
//  ValleyQuestApp
//
//  Created by John Kotz on 9/29/15.
//  Copyright © 2015 Valley Quest App Dev. All rights reserved.
//

import UIKit
import Parse

class MainViewController: UITableViewController {
    var quests: Array<Quest> = [];
    
    override func viewWillAppear(animated: Bool) {
        if let dictionary = PListReader().getQuests() {
            quests = Quest.getQuestsFromDictionary(dictionary)
            Quest.sortQuests(&quests)
        }
        self.title = "Quests"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let object: PFObject = PFObject(className: "Messages")
        object.setValue("John", forKey: "user_1")
        object.setValue("Shuoqi", forKey: "user_2")
        object.setValue("All, ready!", forKey: "Message")
        object.saveInBackground()
        
        let query: PFQuery = PFQuery(className: "Quests")
        query.findObjectsInBackgroundWithBlock { (results: [PFObject]?, error: NSError?) -> Void in
            
            if let checkedResults = results {
                for result: PFObject in checkedResults {
                    print(result["Name"])
                }
            }
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        // Tells the cell how tall to be
        return 70
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // This is the number of cells to show
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
            // Setting the title and description
            checkedCell.setTitle(quests[indexPath.row].title)
            checkedCell.setSubTitle("Location: " + quests[indexPath.row].location + " - Difficulty: " + quests[indexPath.row].difficulty)
            // Done. Lets give them the cell
            return checkedCell
        }
        return cell!
    }
    
    func loadQuestView(id: String) {
        if let quest = Quest.getQuestForId(quests, id: id) {
            self.performSegueWithIdentifier("showQuestDetail", sender: quest)
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
        self.performSegueWithIdentifier("showQuestDetail", sender: quests[indexPath.row])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

