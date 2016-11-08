//
//  MapBuildings.swift
//  Parse Modifier
//
//  Created by John Kotz on 8/27/16.
//  Copyright © 2016 John Kotz. All rights reserved.
//

import Foundation
import Parse

class MapBuildings: PFObject, PFSubclassing {
    @NSManaged var name: String
    @NSManaged var HCommunity: String
    @NSManaged var coordinates: [String]
    
    static func parseClassName() -> String {
        return "MapBuildings"
    }
    
    static func getNamesString(_ array: [MapBuildings], separator: String) -> String {
        var output = ""
        
        for building in array {
            output += "\(building.name)\(separator)"
        }
        
        return output
    }
}
