//
//  VariableHightCell.swift
//  Valley Quest App
//
//  Created by John Kotz on 11/8/15.
//  Copyright © 2015 John Kotz. All rights reserved.
//

import Foundation
import UIKit

class VariableHeightCell: UITableViewCell {
    @IBOutlet weak var infoLabel: UITextView!
    static let font = UIFont(name: "Arial", size: 14.0)!
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        infoLabel.font = VariableHeightCell.font
    }
    
    func setInfoHidden(hidden: Bool) {
        infoLabel.hidden = hidden
    }
    
    func setInfo(info: String?) {
        // Doing the same thing as in the setting of the title
        if let infoChecked = info {
            infoLabel.text = infoChecked
            print(infoLabel.text)
            print("")
        }else{
            infoLabel.text = ""
        }
        
        
        self.setInfoHidden(infoLabel.text == "")
    }
    
    static func getHeightForText(text: String, font: UIFont, size: CGSize) -> CGFloat {
        return (text as NSString).boundingRectWithSize(size, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName : font], context: nil).size.height
    }
    
    func getHeight() -> CGFloat {
        var infoHeight = VariableHeightCell.getHeightForText(infoLabel.text, font: infoLabel.font!, size: infoLabel.bounds.size)
        if infoLabel.hidden {
            infoHeight = 0;
        }
        
        return infoHeight
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    static func getHeightOfQuest(quest: Quest, clueID: Int) -> CGFloat {
        let infoHeight = VariableHeightCell.getHeightForText(quest.clues[clueID], font: font, size: CGSize(width: UIScreen.mainScreen().bounds.size.width, height: 0))
        return infoHeight
    }
}