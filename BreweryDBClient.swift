//
//  BreweryDBClient.swift
//  Brew_Buddy
//
//  Created by Jess Gates on 1/6/17.
//  Copyright © 2017 Jess Gates. All rights reserved.
//

import Foundation
import UIKit

class BreweryDBClient: NSObject {
    
    var numberOfPages: Int = 0
    var pageNumber: Int = 0
    var breweryID: String! = nil
    
    // Asynchronous Get request
    func taskForGETMethod(_ parameters: [String:AnyObject], apiPath: String, completionHandlerForGET: @escaping ( _ result: AnyObject?, _ error: NSError?) -> Void) {
        
        DispatchQueue.global(qos: .userInitiated).async{
            
            let request = NSMutableURLRequest(url: self.breweryDBURLFromParameters(parameters: parameters as [String : AnyObject], apiPath: apiPath) as URL)
            let session = URLSession.shared
            let task = session.dataTask(with: request as URLRequest) { data, response, error in
                
                func sendError(_ error: String) {
                    print(error)
                    let userInfo = [NSLocalizedDescriptionKey : error]
                    completionHandlerForGET(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
                }
                
                guard (error == nil) else {
                    sendError("There was an error with your request: \(error)")
                    return
                }
                
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode >= 200 && statusCode <= 299 else {
                    sendError("Your request returned a status code other than 2xx!")
                    return
                }
                
                guard let data = data else {
                    sendError("No data was returned by the request!")
                    return
                }
                
                self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForGET)
                
            }
            
            task.resume()
        }
        
    }
    
    // Create URL based on input parameters
    fileprivate func breweryDBURLFromParameters(parameters: [String:AnyObject], apiPath: String, withPathExtension: String? = nil) -> NSURL {
        
        let components = NSURLComponents()
        components.scheme = BreweryDBClient.BreweryDB.APIScheme
        components.host = BreweryDBClient.BreweryDB.APIHost
        components.path = apiPath + (withPathExtension ?? "")
        components.queryItems = [NSURLQueryItem]() as [URLQueryItem]?
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem as URLQueryItem)
        }
        
        return components.url! as NSURL
    }
    
    // Parse the JSON file
    fileprivate func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: AnyObject!
        
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:AnyObject?] as AnyObject!
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(parsedResult, nil)
    }
    
    class func sharedInstance() -> BreweryDBClient {
        struct Singleton {
            static var sharedInstance = BreweryDBClient()
        }
        return Singleton.sharedInstance
    }
    
}
