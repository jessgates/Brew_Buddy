//
//  AppleDirectionsClient.swift
//  Brew_Buddy
//
//  Created by Jess Gates on 4/5/17.
//  Copyright © 2017 Jess Gates. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class AppleDirectionsClient {
    
    
    
    class func sharedInstance() -> AppleDirectionsClient {
        struct Singleton {
            static var sharedInstance = AppleDirectionsClient()
        }
        return Singleton.sharedInstance
    }
}
