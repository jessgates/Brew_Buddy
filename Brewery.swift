//
//  Brewery.swift
//  Brew_Buddy
//
//  Created by Jess Gates on 1/16/17.
//  Copyright © 2017 Jess Gates. All rights reserved.
//

import UIKit

// Create a Beer struct from json data provided by BreweryDB
struct Brewery {
    
    let id: String!
    let latitude: Double?
    let longitude: Double?
    let brewery: [String:AnyObject]?
    
    init(dictionary: [String:AnyObject]) {
        id = dictionary[BreweryDBClient.BreweryDBBreweryResponseKeys.ID] as! String
        latitude = dictionary[BreweryDBClient.BreweryDBBreweryResponseKeys.Latitude] as? Double
        longitude = dictionary[BreweryDBClient.BreweryDBBreweryResponseKeys.Longitude] as? Double
        brewery = dictionary[BreweryDBClient.BreweryDBBreweryResponseKeys.Brewery] as? [String:AnyObject]
    }
    
    // Create a dictionary of Breweries
    static func breweriesFromResults(_ results: [[String:AnyObject]]) -> [Brewery] {
        var breweries = [Brewery]()
        
        for result in results {
            breweries.append(Brewery(dictionary: result))
        }
        
        return breweries
    }
}

// MARK: - Brewery: Equatable

extension Brewery: Equatable {}

func ==(lhs: Brewery, rhs: Brewery) -> Bool {
    return lhs.id == rhs.id
}
