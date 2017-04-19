//
//  CustomBeerTableCell.swift
//  Brew_Buddy
//
//  Created by Jess Gates on 1/10/17.
//  Copyright © 2017 Jess Gates. All rights reserved.
//

import UIKit

class CustomBeerTableCell: UITableViewCell {
    @IBOutlet weak var beerName: UILabel!
    @IBOutlet weak var brewery: UILabel!
    @IBOutlet weak var abv: UILabel!
    @IBOutlet weak var rating: BeerRatingLabel!
    @IBOutlet weak var labelImage: UIImageView!
}
