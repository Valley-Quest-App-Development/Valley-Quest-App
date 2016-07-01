//
//  QuestCell.swift
//  ValleyQuestApp
//
//  Created by John Kotz on 10/24/15.
//  Copyright © 2015 Valley Quest App Dev. All rights reserved.
//

import Foundation
import UIKit

class QuestCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(false, animated: animated)
    }
    
    func otherSetSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setTitle(title: String) {
        self.titleLabel.text = title
    }
    
    func setSubTitle(subTitle: String) {
        self.subTitleLabel.text = subTitle
    }
}