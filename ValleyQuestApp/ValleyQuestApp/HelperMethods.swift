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
}