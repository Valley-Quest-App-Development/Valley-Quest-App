//
//  FeedbackCluesViewController.swift
//  Valley Quest App
//
//  Created by John Kotz on 3/22/16.
//  Copyright © 2016 vitalCommunities. All rights reserved.
//

import Foundation

class FeedbackCluesViewController: UITableViewController {
    
    
    override func viewDidLoad() {
        self.title = "Feedback - Clues"
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        }else{
            return 1
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Clues"
        }else{
            return "More"
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 1 {
            return 150
        }
        
        return 44
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 || indexPath.row == 1 {
                let cell: SegmentedCell = tableView.dequeueReusableCellWithIdentifier("SegmentedCell") as! SegmentedCell
                
                if indexPath.row == 0 {
                    cell.setTitle("Accuracy")
                    cell.setSegments(Feedback.cluesAccuracyOptions)
                }else {
                    cell.setTitle("Clarity")
                    cell.setSegments(Feedback.cluesUnderstandableOptions)
                }
                
                return cell
            }else{
                let cell: CheckBoxCell = tableView.dequeueReusableCellWithIdentifier("checkBoxCell") as! CheckBoxCell
                
                cell.titleLabel.text = "Clues need updating"
                
                return cell
            }
        }else{
            let cell = FeedbackTextViewCell()
            
            return cell
        }
    }
}