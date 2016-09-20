//
//  CluesViewController.swift
//  Valley Quest App
//
//  Created by John Kotz on 11/8/15.
//  Copyright © 2015 John Kotz. All rights reserved.
//

import Foundation
import UIKit

class CluesViewController: UITableViewController {
    var object: Quest? = nil
    
    override func viewWillAppear(animated: Bool) {
        self.title = "Clues"
    }
    
    func set(object: Quest) {
        self.object = object
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let clues = object?.Clues {
            return clues.count
        }
        return 0;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: VariableHeightCell? = tableView.dequeueReusableCellWithIdentifier("cluesCell") as? VariableHeightCell
        
        if cell == nil {
            let nib: NSArray = NSBundle.mainBundle().loadNibNamed("VariableHeightCell", owner: self, options: nil)!
            cell = nib.objectAtIndex(0) as? VariableHeightCell
        }
        
        if let clueCell = cell {
            clueCell.setInfo(object?.Clues![indexPath.row])
            return clueCell
        }
        return cell!
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return VariableHeightCell.getHeightForText(self.object!.Clues![indexPath.row], font: VariableHeightCell.font, width: tableView.frame.width - 16 - 30)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? VariableHeightCell {
            cell.checkBox.setOn(!cell.checkBox.on, animated: true)
            cell.didTapCheckBox(cell.checkBox)
        }
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
}
