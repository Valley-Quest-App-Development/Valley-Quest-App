//
//  QuestDetailCell.swift
//  Valley Quest App
//
//  Created by John Kotz on 3/28/16.
//  Copyright © 2016 vitalCommunities. All rights reserved.
//

import Foundation

class QuestDetailCell: UITableViewCell {
    @IBOutlet weak var nameOfQuestLabel: UILabel!
    @IBOutlet weak var difficultyLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var staticItemsHeight: NSLayoutConstraint!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var saveHeight: NSLayoutConstraint!
    
    private static let descriptionFont = UIFont.systemFontOfSize(15)
    private static let lineFragmentPadding: CGFloat = 10
    private var descriptionText: String = ""
    private var difficulty: String?
    private var duration: String?
    var delegate: QuestDetailViewController?
    
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
            delegate.saveQuest()
        }
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
        if let difficulty = difficulty {
            self.difficultyLabel.text = "Difficulty: \(difficulty)"
            if let duration = duration {
                self.difficultyLabel.text = "Difficulty: \(difficulty) Duration: \(duration)"
            }
        }else if let duration = duration {
            self.difficultyLabel.text = "Duration: \(duration)"
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
    
    func getHeight() -> CGFloat {
        let buttonHeight = 8 * 2 + (saveHeight != nil ? saveHeight.constant : 43)
        return self.getHeightOfDescription() + (staticItemsHeight != nil ? staticItemsHeight.constant : 74) + 35 + buttonHeight
    }
}