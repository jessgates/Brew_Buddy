//
//  CustomBreweryPointAnnotation.swift
//  Brew_Buddy
//
//  Created by Jess Gates on 1/17/17.
//  Copyright © 2017 Jess Gates. All rights reserved.
//

import Foundation
import MapKit

class CustomBreweryPointAnnotation: MKPointAnnotation {
    var breweryID: String!
    var website: String?
    var imageURLs: [String:String]?
}
