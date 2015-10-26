//
//  QuestCell.swift
//  ValleyQuestApp
//
//  Created by John Kotz on 10/24/15.
//  Copyright © 2015 John Kotz. All rights reserved.
//

import Foundation
import UIKit

class QuestCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    func setTitle(title: String) {
        self.titleLabel.text = title
    }
    
    func setSubTitle(subTitle: String) {
        self.subTitleLabel.text = subTitle
    }
}