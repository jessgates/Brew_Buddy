//
//  Breweries+CoreDataClass.swift
//  Brew_Buddy
//
//  Created by Jess Gates on 3/20/17.
//  Copyright © 2017 Jess Gates. All rights reserved.
//

import Foundation
import CoreData

//@objc(Breweries)
public class Breweries: NSManagedObject {
    convenience init(name: String, id: String, latitude: Double, longitude: Double, distanceFromUser: Double, context: NSManagedObjectContext) {
        
        if let entity = NSEntityDescription.entity(forEntityName: "Breweries", in: context) {
            self.init(entity: entity, insertInto: context)
            self.name = name
            self.id = id
            self.latitude = latitude
            self.longitude = longitude
            self.distanceFromUser = distanceFromUser
        } else  {
            fatalError("Unable to find Entity name!")
        }
    }
}
