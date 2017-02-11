//
//  Beer.swift
//  Brew_Buddy
//
//  Created by Jess Gates on 1/6/17.
//  Copyright © 2017 Jess Gates. All rights reserved.
//

import UIKit

// Create a Beer struct from json data provided by BreweryDB
struct Beer {
    
    let name: String
    let id: String
    let abv: String?
    let description: String?
    let style: [String:AnyObject]?
    let labels: [String:String]?
    let brewery: [[String:AnyObject]]?
    
    init(dictionary: [String:AnyObject]) {
        name = dictionary[BreweryDBClient.BreweryDBBeersResponseKeys.Name] as! String
        id = dictionary[BreweryDBClient.BreweryDBBeersResponseKeys.ID] as! String
        abv = dictionary[BreweryDBClient.BreweryDBBeersResponseKeys.ABV] as? String
        description = dictionary[BreweryDBClient.BreweryDBBeersResponseKeys.Description] as? String
        style = dictionary[BreweryDBClient.BreweryDBBeersResponseKeys.Style] as? [String:AnyObject]
        labels = dictionary[BreweryDBClient.BreweryDBBeersResponseKeys.Labels] as? [String:String]
        brewery = dictionary[BreweryDBClient.BreweryDBBeersResponseKeys.Breweries] as? [[String:AnyObject]]
    }
    
    // Create a dictionary of Breweries
    static func beersFromResults(_ results: [[String:AnyObject]]) -> [Beer] {
        var beers = [Beer]()
        
        for result in results {
            beers.append(Beer(dictionary: result))
        }
        
        return beers
    }
}

// MARK: - Beer: Equatable

extension Beer: Equatable {}

func ==(lhs: Beer, rhs: Beer) -> Bool {
    return lhs.id == rhs.id
}
