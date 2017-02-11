//
//  FavoriteBeer+CoreDataProperties.swift
//  Brew_Buddy
//
//  Created by Jess Gates on 1/23/17.
//  Copyright © 2017 Jess Gates. All rights reserved.
//

import Foundation
import CoreData


extension FavoriteBeer {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoriteBeer> {
        return NSFetchRequest<FavoriteBeer>(entityName: "FavoriteBeer");
    }
    
    @NSManaged public var id: String?
    @NSManaged public var abv: String?
    @NSManaged public var beerDescription: String?
    @NSManaged public var beerLabel: NSData?
    @NSManaged public var beerName: String?
    @NSManaged public var breweryName: String?
    @NSManaged public var breweryWebsite: String?
    @NSManaged public var tastingNotes: String?
    @NSManaged public var rating: String?

}
