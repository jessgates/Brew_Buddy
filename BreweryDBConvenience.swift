//
//  BreweryDBConvenience.swift
//  Brew_Buddy
//
//  Created by Jess Gates on 1/6/17.
//  Copyright © 2017 Jess Gates. All rights reserved.
//

import UIKit

extension BreweryDBClient {
    
    // Get the paginated beer list from BreweryDB
    func getBeerList( _ completionHandlerForGetBeers: @escaping (_ success: Bool, _ data: [[String: AnyObject]]?, _ error: NSError?) -> Void) {
        
        let apiPath = BreweryDBClient.BreweryDB.APIPathBeers
        
        let paramaters: [String: Any?] = [BreweryDBClient.BreweryDBParameterKeys.APIKey: BreweryDBClient.BreweryDBParameterValues.APIKey, BreweryDBClient.BreweryDBParameterKeys.ResponseFormat: BreweryDBClient.BreweryDBParameterValues.ResponseFormat, BreweryDBClient.BreweryDBBeersParameterKeys.AvailableID: BreweryDBClient.BreweryDBBeersParameterValues.AvailableID, BreweryDBClient.BreweryDBBeersParameterKeys.WithBreweries: BreweryDBClient.BreweryDBBeersParameterValues.WithBreweries, BreweryDBClient.BreweryDBBeersParameterKeys.Page: pageNumber]
        
        taskForGETMethod(paramaters as [String : AnyObject], apiPath: apiPath) { (result, error) -> Void in
            
            if let error = error {
                completionHandlerForGetBeers(false, nil, error)
            } else {
                
                guard let numberOfPages = result?["numberOfPages"] as? Int else {
                    completionHandlerForGetBeers(false, nil, error)
                    return
                }
                
                guard let pageNumber = result?["currentPage"] as? Int else {
                    completionHandlerForGetBeers(false, nil, error)
                    return
                }
                
                guard let beerDictionary = result?[BreweryDBClient.BreweryDBResponseKeys.Data] as? [[String: AnyObject]] else {
                    completionHandlerForGetBeers(false, nil, error)
                    return
                }
                
                self.numberOfPages = numberOfPages
                self.pageNumber = pageNumber
                
                completionHandlerForGetBeers(true, beerDictionary, nil)

            }
        }
    }
    
    // Get brewery list from BreweryDB
    func getNearbyBreweries(lat: Double, lon: Double, _ completionHandlerForGetBreweries: @escaping (_ success: Bool, _ data: [Brewery]?, _ error: NSError?) -> Void) {
        
        let apiPath = BreweryDBClient.BreweryDB.APIPathSearchBreweries
        
        let paramaters: [String: Any?] = [BreweryDBClient.BreweryDBParameterKeys.APIKey: BreweryDBClient.BreweryDBParameterValues.APIKey, BreweryDBBreweryParameterKeys.Latitude: lat, BreweryDBBreweryParameterKeys.Longitude: lon, BreweryDBBreweryParameterKeys.Radius: BreweryDBBreweryParameterValues.Radius, BreweryDBBreweryParameterKeys.Unit: BreweryDBBreweryParameterValues.Unit, BreweryDBClient.BreweryDBParameterKeys.ResponseFormat: BreweryDBClient.BreweryDBParameterValues.ResponseFormat]
        
        taskForGETMethod(paramaters as [String : AnyObject], apiPath: apiPath) { (result, error) -> Void in
            
            if let error = error {
                completionHandlerForGetBreweries(false, nil, error)
            } else {
                
                guard let breweryDictionary = result?[BreweryDBClient.BreweryDBResponseKeys.Data] as? [[String: AnyObject]] else {
                    completionHandlerForGetBreweries(false, nil, error)
                    return
                }
                
                let breweries = Brewery.breweriesFromResults(breweryDictionary)
                BreweryAnnotation.sharedInstance().breweries = breweries
                let annotations = BreweryAnnotation.sharedInstance().getBreweryAnnotations(breweries)
                BreweryAnnotation.sharedInstance().annotations = annotations
                
                completionHandlerForGetBreweries(true, breweries, nil)
                
            }
        }
    }
    
    // Search the breweryDB for beer based search text
    func getBeerFromSearch(queryString: String, _ completionHandlerForGetBeers: @escaping (_ success: Bool, _ data: [[String: AnyObject]]?, _ error: NSError?) -> Void) {
        
        let apiPath = BreweryDBClient.BreweryDB.APIPathSearch
        
        let paramaters: [String: Any?] = [BreweryDBClient.BreweryDBParameterKeys.APIKey: BreweryDBClient.BreweryDBParameterValues.APIKey, BreweryDBClient.BreweryDBParameterKeys.ResponseFormat: BreweryDBClient.BreweryDBParameterValues.ResponseFormat, BreweryDBClient.BreweryDBBeersParameterKeys.WithBreweries: BreweryDBClient.BreweryDBBeersParameterValues.WithBreweries, BreweryDBBeersParameterKeys.QueryString: queryString, BreweryDBBeersParameterKeys.SearchType: BreweryDBBeersParameterValues.SearchType]
        
        taskForGETMethod(paramaters as [String : AnyObject], apiPath: apiPath) { (result, error) -> Void in
            
            if let error = error {
                completionHandlerForGetBeers(false, nil, error)
            } else {
                
                guard let beerDictionary = result?[BreweryDBClient.BreweryDBResponseKeys.Data] as? [[String: AnyObject]] else {
                    completionHandlerForGetBeers(false, nil, error)
                    return
                }

                completionHandlerForGetBeers(true, beerDictionary, nil)
            }
        }
    }
    
    // Get list of beers for a brewery based on the brewery ID
    func getBreweryBeersFromSearch(_ completionHandlerForGetBreweryBeers: @escaping (_ success: Bool, _ data: [[String: AnyObject]]?, _ error: NSError?) -> Void) {
        
        let apiPath = BreweryDB.APIPathBreweryID.replacingOccurrences(of: "<breweryId>", with: breweryID)
        
        let paramaters: [String: Any?] = [BreweryDBClient.BreweryDBParameterKeys.APIKey: BreweryDBClient.BreweryDBParameterValues.APIKey, BreweryDBClient.BreweryDBParameterKeys.ResponseFormat: BreweryDBClient.BreweryDBParameterValues.ResponseFormat]
        
        taskForGETMethod(paramaters as [String : AnyObject], apiPath: apiPath) { (result, error) -> Void in
            
            if let error = error {
                completionHandlerForGetBreweryBeers(false, nil, error)
            } else {
                
                guard let beerDictionary = result?[BreweryDBClient.BreweryDBResponseKeys.Data] as? [[String: AnyObject]] else {
                    completionHandlerForGetBreweryBeers(false, nil, error)
                    return
                }
                
                completionHandlerForGetBreweryBeers(true, beerDictionary, nil)
            }
        }
    }
    
    // Download images asynchronously
    func downloadImage( imagePath:String, completionHandler: @escaping (_ imageData: NSData?, _ errorString: String?) -> Void){
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            let session = URLSession.shared
            let imgURL = NSURL(string: imagePath)
            let request: NSURLRequest = NSURLRequest(url: imgURL! as URL)
            
            let task = session.dataTask(with: request as URLRequest) {data, response, downloadError in
                
                if downloadError != nil {
                    completionHandler(nil, "Could not download image \(imagePath)")
                } else {
                    
                    completionHandler(data as NSData?, nil)
                }
            }
            
            task.resume()
        }
    }
}
