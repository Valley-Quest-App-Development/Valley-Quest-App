//
//  QuestDetailViewController.swift
//  ValleyQuestApp
//
//  Created by Seb Lim on 10/28/15.
//  Copyright © 2015 John Kotz. All rights reserved.
//

import Foundation
import UIKit

class QuestDetailViewController: UIViewController{
    @IBOutlet weak var distanceAndDifficulty: UILabel!
    @IBOutlet weak var questDecription: UITextView!
    
    override func viewDidLoad() {
        self.title = "Quest 1"
    }
}