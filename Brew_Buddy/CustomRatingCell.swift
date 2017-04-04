//
//  CustomRatingRow.swift
//  Brew_Buddy
//
//  Created by Jess Gates on 4/3/17.
//  Copyright © 2017 Jess Gates. All rights reserved.
//

import UIKit
import Eureka

public class CustomRatingCell: Cell<String>, CellType {
    
    @IBOutlet weak var beerRatingLabel: BeerRatingLabel!
    
    

    public override func setup() {
        super.setup()
    }

    public override func update() {
        super.update()
    }
}

public final class CustomRatingRow: Row<CustomRatingCell>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<CustomRatingCell>(nibName: "CustomRatingCell")
    }
}

