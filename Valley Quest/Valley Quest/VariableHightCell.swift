//
//  VariableHightCell.swift
//  Valley Quest App
//
//  Created by John Kotz on 11/8/15.
//  Copyright © 2015 John Kotz. All rights reserved.
//

import Foundation
import UIKit
import BEMCheckBox

class VariableHeightCell: UITableViewCell, BEMCheckBoxDelegate {
    @IBOutlet weak var infoLabel: UITextView!
    static let font = UIFont.systemFontOfSize(15)
    @IBOutlet weak var checkBox: BEMCheckBox!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        infoLabel.font = VariableHeightCell.font
        
        checkBox.delegate = self
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
        
        checkBox.delegate = self
        checkBox.onCheckColor = UIColor.darkGrayColor()
        checkBox.onTintColor = UIColor.grayColor()
        checkBox.tintColor = UIColor.lightGrayColor()
        self.infoLabel.font = VariableHeightCell.font
        self.setInfoHidden(infoLabel.text == "")
    }
    
    func didTapCheckBox(checkBox: BEMCheckBox) {
        if checkBox.on {
            self.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
            self.infoLabel.textColor = UIColor.grayColor()
            self.infoLabel.backgroundColor = UIColor.clearColor()
        }else{
            self.backgroundColor = UIColor.whiteColor()
            self.infoLabel.textColor = UIColor.blackColor()
            self.infoLabel.backgroundColor = UIColor.clearColor()
        }
    }
    
    
    static func getHeightForText(text: String, font: UIFont, width: CGFloat) -> CGFloat {
        let height = HelperMethods.getHeightForText(text, font: font, width: width, maxHeight: CGFloat.max)
        
        return height + 25
    }
    
    func getHeight() -> CGFloat {
        let height = VariableHeightCell.getHeightForText(self.infoLabel.text, font: self.infoLabel.font!, width: self.infoLabel.frame.width)
        
        return self.infoLabel.hidden ? 0 : height
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}