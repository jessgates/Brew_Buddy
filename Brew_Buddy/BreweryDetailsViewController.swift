//
//  BreweryDetailsViewController.swift
//  Brew_Buddy
//
//  Created by Jess Gates on 1/6/17.
//  Copyright © 2017 Jess Gates. All rights reserved.
//

import UIKit
import CoreData

class BreweryDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var breweryImage: UIImageView!
    @IBOutlet weak var breweryName: UILabel!
    @IBOutlet weak var breweryWebsite: UILabel!
    @IBOutlet weak var beerLabel: UILabel!
    @IBOutlet weak var beerTable: UITableView!
    @IBOutlet weak var tableHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageActivityIdicator: UIActivityIndicatorView!
    
    var beers: [Beer] = [Beer]()
    var name: String!
    var website: String?
    var imageURLs = [String:String]()
    var noBeersLabel: UILabel!
    var tableActivityIndicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureActivityIndicator()
        downloadBreweryImage()
        loadBeersForBrewery()
        setTextProperties()
        
        beerTable.layer.cornerRadius = 10
        beerTable.layer.masksToBounds = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(BreweryDetailsViewController.websiteLabelTapped))
        breweryWebsite.addGestureRecognizer(tap)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        // Display the label as the table background view if there are no beers
        if tableView(beerTable, numberOfRowsInSection: 1) == 0 {
            configureNoBeersLabel()
        } else {
            beerTable.backgroundView = nil
        }
        
        adjustHeightOfTable()
    }
    
// MARK: - Helper Functions
    
    func setTextProperties() {
        breweryName.text = name
        breweryWebsite.text = website
        beerLabel.text = "Beers"
    }
    
    // Download brewery image
    func downloadBreweryImage() {
        imageActivityIdicator.startAnimating()
        BreweryDBClient.sharedInstance().downloadImage(imagePath: imageURLs[BreweryDBClient.BreweryDBBreweryResponseKeys.SquareMediumURL]!, completionHandler: { (imageData, error) in
            if let image = UIImage(data: imageData as! Data) {
                DispatchQueue.main.async {
                    self.breweryImage.image = image
                    self.imageActivityIdicator.stopAnimating()
                    self.imageActivityIdicator.isHidden = true
                }
            }
        })
    }
    
    // Adjust the height based on the number of beers returned
    func adjustHeightOfTable() {
        if beers.count > 0 {
            var height = beerTable.contentSize.height as CGFloat
            let maxHeight = (beerTable.superview?.frame.size.height)! - beerTable.frame.origin.y
        
            if height > maxHeight {
                height = maxHeight
            }
        
            tableHeightConstraint.constant = height
            view.setNeedsUpdateConstraints()
        }
    }
    
    // Create the label for no Beers and set as table view background
    func configureNoBeersLabel() {
        noBeersLabel = UILabel(frame: CGRect(x: 0, y: 50, width: beerTable.bounds.size.width, height: beerTable.bounds.size.height))
        noBeersLabel.isHidden = false
        noBeersLabel.text = "No Beer List Available"
        noBeersLabel.font = UIFont(name: "OpenSans-SemiboldItalic", size: 20)
        noBeersLabel.textColor = UIColor(red:0.31, green:0.14, blue:0.07, alpha:1.0)
        noBeersLabel.textAlignment = .center
        beerTable.backgroundView = noBeersLabel
        beerTable.separatorStyle = .none
    }
    
    // Request Beers for tapped brewery
    func loadBeersForBrewery() {
        tableActivityIndicator.startAnimating()
        BreweryDBClient.sharedInstance().getBreweryBeersFromSearch { (success, data, error) in
            if success {
                DispatchQueue.main.async {
                    self.beers = Beer.beersFromResults(data!)
                    self.tableActivityIndicator.stopAnimating()
                    self.beerTable.reloadData()
                }
            }
        }
    }
    
    // Open browser when the webiste is tapped
    func websiteLabelTapped(_ sender: UITapGestureRecognizer) {
        if breweryWebsite.text != "No Website Available" {
            if let url = URL(string: breweryWebsite.text!) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    // Create the activity indicator for loading beers and set as table view background
    func configureActivityIndicator() {
        tableActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        tableActivityIndicator.isHidden = false
        tableActivityIndicator.hidesWhenStopped = true
        tableActivityIndicator.center = beerTable.center
        beerTable.separatorStyle = .none
        beerTable.backgroundView = tableActivityIndicator
    }
    
// MARK: - UITableViewDataSource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return beers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BeerTableCell", for: indexPath) as! CustomBeerTableCell
        
        let beersToShow = beers[indexPath.row]
        cell.beerName.text = beersToShow.name
        if beersToShow.abv == nil {
            cell.abv.text = "N/A"
        } else {
            cell.abv.text = "ABV: \(beersToShow.abv! as String)%"
        }
        
        return cell
    }
    
}
