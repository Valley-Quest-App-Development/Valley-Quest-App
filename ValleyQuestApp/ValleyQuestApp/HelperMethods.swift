//
//  helperMethods.swift
//  Valley Quest App
//
//  Created by John Kotz on 3/17/16.
//  Copyright © 2016 vitalCommunities. All rights reserved.
//

import Foundation
import MapKit
import Parse

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
        return (font.lineHeight) * numLines
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

class ParseSaver {
    private var objectsToDo = [PFObject]()
    private var filesToDo = [PFFile]()
    private var done: (() -> Void)?
    
    func saveAllInBackground(objects: [PFObject], done: () -> Void) {
        self.done = done
        objectsToDo = objects
        for object in objects {
            object.saveInBackgroundWithBlock({ (success, error) in
                if success {
                    self.doneSavingObject(object)
                }
            })
        }
    }
    
    func saveAllFilesInBackground(files: [PFFile], done: () -> Void) {
        filesToDo = files
        self.done = done
        for file in files {
            file.saveInBackgroundWithBlock({ (success, error) in
                if success {
                    self.doneSavingFile(file)
                }
            })
        }
    }
    
    private func doneSavingFile(file: PFFile) {
        if let index = filesToDo.indexOf(file) {
            filesToDo.removeAtIndex(index)
            
            if filesToDo.count == 0 {
                if let done = done {
                    done()
                }
            }
        }
    }
    
    private func doneSavingObject(object: PFObject) {
        if let index = objectsToDo.indexOf(object) {
            objectsToDo.removeAtIndex(index)
            
            if objectsToDo.count == 0 {
                if let done = done {
                    done()
                }
            }
        }
    }
}