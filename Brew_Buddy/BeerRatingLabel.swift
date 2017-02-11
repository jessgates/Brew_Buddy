//
//  BeerRatingLabel.swift
//  Brew_Buddy
//
//  Created by Jess Gates on 1/26/17.
//  Copyright © 2017 Jess Gates. All rights reserved.
//

import UIKit

// Custom label for rating beers
class BeerRatingLabel: UILabel {
    
    let totalStars = 5
    var unit: CGFloat = 0
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let width = frame.width
        unit = width / CGFloat(totalStars)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self)
        showBeerRatingFor(location: location)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self)
        showBeerRatingFor(location: location)
    }
    
    // Show the correct star emoji based on where the user is touching
    func showBeerRatingFor(location: CGPoint) {
        let rating = Int(floor(location.x / unit))
        var stars = ""
        for i in 0 ... 4 {
            if i > rating {
                stars += "☆"
            } else {
                stars += "★"
            }
        }
        
        text = stars
    }
    
}
