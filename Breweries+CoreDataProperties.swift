//
//  Breweries+CoreDataProperties.swift
//  Brew_Buddy
//
//  Created by Jess Gates on 3/20/17.
//  Copyright © 2017 Jess Gates. All rights reserved.
//

import Foundation
import CoreData


extension Breweries {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Breweries> {
        return NSFetchRequest<Breweries>(entityName: "Breweries");
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var distanceFromUser: Double

}
