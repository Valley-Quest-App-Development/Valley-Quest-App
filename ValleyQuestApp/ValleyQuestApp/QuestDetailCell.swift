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
    
    private static let descriptionFont = UIFont.systemFontOfSize(15)
    private static let lineFragmentPadding: CGFloat = 10
    private var descriptionText: String = ""
    private var difficulty: String?
    private var duration: String?
    
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
        return height
    }
    
    func getHeight() -> CGFloat {
        return self.getHeightOfDescription() + (staticItemsHeight != nil ? staticItemsHeight.constant : 74) + 35
    }
}