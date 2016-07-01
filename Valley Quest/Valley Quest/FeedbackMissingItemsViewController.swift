//
//  FeedbackMissingItemsViewController.swift
//  Valley Quest App
//
//  Created by John Kotz on 4/25/16.
//  Copyright © 2016 vitalCommunities. All rights reserved.
//

import Foundation
import UIKit

class FeedbackMissingItemsViewController: UITableViewController {
    var items: [String]?
    var selectedIndexes: [Int] = []
    var selectedItems: [String] {
        get {
            var selected = [String]()
            for index in selectedIndexes {
                selected.append(items![index])
            }
            
            return selected
        }
        set {
            for value in newValue {
                if let index = items?.indexOf(value) {
                    selectedIndexes.append(index)
                }
            }
        }
    }
    
    var finishedChoosing: (() -> Void)?
    
    override func viewDidLoad() {
        self.title = "Missing Items"
    }
    
    func setMyItems(items: [String]) {
        self.items = items
        self.tableView.reloadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        if let finishedChoosing = finishedChoosing {
            finishedChoosing()
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            if (cell.accessoryType == .Checkmark) {
                cell.accessoryType = .None
                if let index = selectedIndexes.indexOf(indexPath.row) {
                    selectedIndexes.removeAtIndex(index)
                }
            }else{
                cell.accessoryType = .Checkmark
                if selectedIndexes.indexOf(indexPath.row) == nil {
                    selectedIndexes.append(indexPath.row)
                }
            }
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let text = items![indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")
        
        cell?.textLabel?.text = text;
        
        if selectedIndexes.indexOf(indexPath.row) != nil {
            cell?.accessoryType = .Checkmark
        }else{
            cell?.accessoryType = .None
        }
        
        return cell!;
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items!.count
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
}