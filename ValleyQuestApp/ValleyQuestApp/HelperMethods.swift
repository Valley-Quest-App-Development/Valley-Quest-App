//
//  helperMethods.swift
//  Valley Quest App
//
//  Created by John Kotz on 3/17/16.
//  Copyright © 2016 vitalCommunities. All rights reserved.
//

import Foundation
import MapKit

extension String {
    func sizeForWidth(width: CGFloat, font: UIFont) -> CGSize {
        let attr = [NSFontAttributeName: font]
        let height = NSString(string: self).boundingRectWithSize(CGSize(width: width, height: CGFloat.max), options:.UsesLineFragmentOrigin, attributes: attr, context: nil).height
        return CGSize(width: width, height: ceil(height))
    }
}

extension UIFont {
    func sizeOfString (string: NSString, constrainedToWidth width: Double) -> CGSize {
        return string.boundingRectWithSize(CGSize(width: width, height: DBL_MAX),
            options: NSStringDrawingOptions.UsesLineFragmentOrigin,
            attributes: [NSFontAttributeName: self],
            context: nil).size
    }
}


class HelperMethods {
    class func getHeightForText(text : String, font : UIFont, width : CGFloat, maxHeight: CGFloat) -> CGFloat {
        let height = text.sizeForWidth(width, font: font).height
        let numLines = round(height / font.lineHeight)
        return (font.lineHeight * 1.2 + 5) * numLines
    }
    
    class func openLocation(coords: CLLocationCoordinate2D, name: String) {
        let dist: CLLocationDistance = 10000
        let span = MKCoordinateRegionMakeWithDistance(coords, dist, dist)
        
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(MKCoordinate: span.center),
            MKLaunchOptionsMapSpanKey: NSValue(MKCoordinateSpan: span.span)
        ]
        
        let placemark = MKPlacemark(coordinate: coords, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "\(name)"
        mapItem.openInMapsWithLaunchOptions(options)
    }
    
    class func getWidthForText(text: String, font: UIFont) -> CGFloat {
        return font.sizeOfString(text, constrainedToWidth: Double.infinity).width
    }
}