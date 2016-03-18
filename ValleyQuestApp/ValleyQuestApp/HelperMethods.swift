//
//  helperMethods.swift
//  Valley Quest App
//
//  Created by John Kotz on 3/17/16.
//  Copyright © 2016 vitalCommunities. All rights reserved.
//

import Foundation

class HelperMethods {
    class func getHeightForText(text : String, font : UIFont, width : CGFloat, maxHeight: CGFloat) -> CGFloat {
        let label : UITextView = UITextView(frame: CGRectMake(0, 0, width, maxHeight))
        label.font = font
        label.text = text
        
        let contentSize = label.sizeThatFits(CGSize(width: width, height: maxHeight))
        return contentSize.height
    }
}