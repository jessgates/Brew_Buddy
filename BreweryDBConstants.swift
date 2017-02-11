//
//  BreweryDBConstants.swift
//  Brew_Buddy
//
//  Created by Jess Gates on 1/6/17.
//  Copyright © 2017 Jess Gates. All rights reserved.
//

import Foundation
import UIKit

extension BreweryDBClient {
    
    // MARK: BreweryDB
    struct BreweryDB {
        static let APIScheme = "https"
        static let APIHost = "api.brewerydb.com"
        static let APIPathBeers = "/v2/beers"
        static let APIPathSearch = "/v2/search"
        static let APIPathBreweryID = "/v2/brewery/<breweryId>/beers"
        static let APIPathSearchBreweries = "/v2/search/geo/point"
    }
    
    // MARK: BreweryDB Parameter Keys
    struct BreweryDBParameterKeys {
        static let APIKey = "key"
        static let ResponseFormat = "format"
    }
    
    // MARK: BreweryDB Parameter Values
    struct BreweryDBParameterValues {
        static let APIKey = "ce0becc5c0627717916c6865c4371985"
        static let ResponseFormat = "json"
    }
    
    // MARK: BreweryBeersDB Parameter Keys
    struct BreweryDBBeersParameterKeys {
        static let PageNumber = "p"
        static let BeerID = "id"
        static let Name = "name"
        static let AvailableID = "availableId"
        static let WithBreweries = "withBreweries"
        static let Page = "p"
        static let QueryString = "q"
        static let SearchType = "type"
    }
    
    // MARK: BreweryDB Brewery Parameter Keys
    struct BreweryDBBreweryParameterKeys {
        static let Latitude = "lat"
        static let Longitude = "lng"
        static let Radius = "radius"
        static let Unit = "unit"
        static let SearchType = "type"
    }
    
    // MARK: BreweryDB Beer Parameter Values
    struct BreweryDBBeersParameterValues {
        static let AvailableID = "1"
        static let WithBreweries = "Y"
        static let Page = 2
        static let SearchType = "beer"
    }
    
    // MARK: BreweryDB Brewery Parameter Values
    struct BreweryDBBreweryParameterValues {
        static let Radius = "100"
        static let Unit = "mi"
        static let SearchType = "brewery"
    }
    
    // MARK: BreweryDB Response Keys
    struct BreweryDBResponseKeys {
        static let Data = "data"
        static let NumberOfPages = "numberOfPages"
        static let PageNumber = "currentPage"
    }
    
    // MARK: BreweryDB Beer Response Keys
    struct BreweryDBBeersResponseKeys {
        static let Name = "name"
        static let ID = "id"
        static let ABV = "abv"
        static let Description = "description"
        static let Labels = "labels"
        static let MediumURL = "medium"
        static let IconURL = "icon"
        static let Style = "style"
        static let Breweries = "breweries"
        static let CurrentPage = "currentPage"
    }
    
    // MARK: BreweryDB Brewery Response Keys
    struct BreweryDBBreweryResponseKeys {
        static let Brewery = "brewery"
        static let Name = "name"
        static let IsClosed = "isClosed"
        static let ShortName = "nameShortDisplay"
        static let ID = "id"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let Description = "description"
        static let Images = "images"
        static let SquareMediumURL = "squareMedium"
        static let Locations = "locations"
        static let Website = "website"
    }
}
