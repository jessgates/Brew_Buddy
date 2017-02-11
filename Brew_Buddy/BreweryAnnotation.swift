//
//  BreweryAnnotation.swift
//  Brew_Buddy
//
//  Created by Jess Gates on 1/16/17.
//  Copyright © 2017 Jess Gates. All rights reserved.
//

import MapKit
import UIKit

// Create an array of custom annotations based on the Brewery struct information
class BreweryAnnotation {
    
    var breweries: [Brewery]?
    var annotations: [CustomBreweryPointAnnotation]?
    
    func getBreweryAnnotations(_ breweries: [Brewery]) ->[CustomBreweryPointAnnotation] {
        var annotations = [CustomBreweryPointAnnotation]()
        
        for brewery in breweries {
            
            if let lat = brewery.latitude,
                let long = brewery.longitude,
                let name = brewery.brewery?[BreweryDBClient.BreweryDBBreweryResponseKeys.Name],
                let breweryID = brewery.brewery?[BreweryDBClient.BreweryDBBreweryResponseKeys.ID],
                let website = brewery.brewery?[BreweryDBClient.BreweryDBBreweryResponseKeys.Website],
                let imageURLs = brewery.brewery?[BreweryDBClient.BreweryDBBreweryResponseKeys.Images]
                {
                let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(long))
                
                let annotation = CustomBreweryPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = "\(name)"
                annotation.breweryID = breweryID as? String
                annotation.website = website as? String
                annotation.imageURLs = imageURLs as? [String : String]
                
                annotations.append(annotation)
            }
        }
        
        return annotations
    }
    
    class func sharedInstance() -> BreweryAnnotation {
        struct Singleton {
            static var sharedInstance = BreweryAnnotation()
        }
        return Singleton.sharedInstance
    }
}
