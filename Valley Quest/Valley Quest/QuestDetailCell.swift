//
//  QuestDetailCell.swift
//  Valley Quest App
//
//  Created by John Kotz on 3/28/16.
//  Copyright © 2016 Vital Communities. All rights reserved.
//

import Foundation
import UIKit
import SCLAlertView

class QuestDetailCell: UITableViewCell {
    @IBOutlet weak var nameOfQuestLabel: UILabel!
    @IBOutlet weak var difficultyLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var staticItemsHeight: NSLayoutConstraint!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var saveHeight: NSLayoutConstraint!
    @IBOutlet weak var saveButtonBackground: UIImageView!
    
    private static let descriptionFont = UIFont.systemFontOfSize(15)
    private static let lineFragmentPadding: CGFloat = 10
    private var descriptionText: String = ""
    private var difficulty: String?
    private var duration: String?
    private var closed = false
    var delegate: QuestDetailViewController?
    
    func initialize() {
        self.saveButtonBackground.clipsToBounds = true;
        self.saveButtonBackground.layer.cornerRadius = 10
        self.descriptionTextView.setContentOffset(CGPointMake(0, 0), animated: false)
    }
    
    func setDescription(text: String) {
        descriptionTextView.text = text
        self.descriptionText = text
        descriptionTextView.setContentOffset(CGPointZero, animated: true)
        descriptionTextView.textContainer.lineFragmentPadding = QuestDetailCell.lineFragmentPadding
        descriptionTextView.font = QuestDetailCell.descriptionFont
    }
    
    func setDifficulty(text: String) {
        difficulty = text
        self.updateDifficultyAndDuration()
    }
    
    func setDuration(text: String) {
        duration = text;
        self.updateDifficultyAndDuration()
    }
    
    @IBAction func save(sender: UIButton) {
        if let delegate = delegate {
            if NSUserDefaults.standardUserDefaults().objectForKey("saveDone") == nil || !NSUserDefaults.standardUserDefaults().boolForKey("saveDone") && !delegate.saved {
                let alert = SCLAlertView(appearance: noCloseButton)
                
                alert.addButton("Continue", action: { 
                    delegate.saveQuest()
                })
                alert.addButton("Nevermind", action: {})
                
                alert.showInfo("Saving a Quest", subTitle: "By saving this quest, your phone will store everything about it so you can access it offline")
            }else{
                delegate.saveQuest()
            }
        }
    }
    
    func makeClosed() {
        self.closed = true
        self.updateDifficultyAndDuration()
    }
    
    func startLoadingSave() {
        self.activity.startAnimating()
        self.saveButton.enabled = false
    }
    
    func endLoadingSave(saved: Bool) {
        self.activity.stopAnimating()
        self.saveButton.enabled = true
        if saved {
            self.saveButton.setTitle("✓ Saved", forState: .Normal)
        }else{
            self.saveButton.setTitle("Save", forState: .Normal)
        }
    }
    
    private func updateDifficultyAndDuration() {
        if !self.closed {
        if let difficulty = difficulty {
            self.difficultyLabel.text = "Difficulty: \(difficulty)"
            if let duration = duration {
                self.difficultyLabel.text = "Difficulty: \(difficulty) Duration: \(duration)"
            }
        }else if let duration = duration {
            self.difficultyLabel.text = "Duration: \(duration)"
        }
        }else{
            self.difficultyLabel.text = "Closed"
            self.difficultyLabel.textColor = UIColor(red: 1.0, green: 0.5, blue: 0.5, alpha: 1.0)
        }
    }
    
    private func getHeightOfDescription() -> CGFloat {
        let maxHeight:CGFloat = 180
        let height = HelperMethods.getHeightForText(self.descriptionText, font: QuestDetailCell.descriptionFont, width: self.frame.width - 8 * 2 - QuestDetailCell.lineFragmentPadding * 2, maxHeight: maxHeight)
        if (height > maxHeight){
            self.descriptionTextView.scrollEnabled = true;
        }
        return height > maxHeight ? maxHeight : height
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.initialize()
    }
    
    func getHeight() -> CGFloat {
        let buttonHeight = 8 * 2 + (saveHeight != nil ? saveHeight.constant : 43)
        return self.getHeightOfDescription() + (staticItemsHeight != nil ? staticItemsHeight.constant : 74) + 35 + buttonHeight
    
    }
}