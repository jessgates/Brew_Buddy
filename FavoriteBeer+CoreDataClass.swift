//
//  FavoriteBeer+CoreDataClass.swift
//  Brew_Buddy
//
//  Created by Jess Gates on 1/23/17.
//  Copyright © 2017 Jess Gates. All rights reserved.
//

import Foundation
import CoreData

@objc(FavoriteBeer)
public class FavoriteBeer: NSManagedObject {
    convenience init(abv: String, id: String, beerDescription: String, beerLabel: NSData, beerName: String, breweryName: String, breweryWebsite: String, tastingNotes: String, rating: String, style: String, styleID: Double, context: NSManagedObjectContext) {
        
        // An EntityDescription is an object that has access to all
        // the information you provided in the Entity part of the model
        // you need it to create an instance of this class.
        if let entity = NSEntityDescription.entity(forEntityName: "FavoriteBeer", in: context) {
            self.init(entity: entity, insertInto: context)
            self.id = id
            self.abv = abv
            self.beerDescription = beerDescription
            self.beerLabel = beerLabel
            self.beerName = beerName
            self.breweryName = breweryName
            self.breweryWebsite = breweryWebsite
            self.tastingNotes = tastingNotes
            self.rating = rating
            self.style = style
            self.styleID = styleID
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
}
