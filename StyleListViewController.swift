//
//  StyleListViewController.swift
//  Brew_Buddy
//
//  Created by Jess Gates on 4/17/17.
//  Copyright © 2017 Jess Gates. All rights reserved.
//

import Foundation
import UIKit

class StyleListViewController: UIViewController {
    
    @IBOutlet weak var beersByStyleTable: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var refreshControl: UIRefreshControl!
    var beers: [Beer] = [Beer]()
    var styleID: Double!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSuggestedBeers()
        
        refreshControl = UIRefreshControl()
        refreshControl!.attributedTitle = NSAttributedString(string: "Pull to find new beers")
        refreshControl!.addTarget(self, action: #selector(refreshBeerList), for: UIControlEvents.allEvents)
        beersByStyleTable.addSubview(refreshControl!)
        beersByStyleTable.tableFooterView = UIView()
        
    }
    
    // Segue to BeerDetailsVC on tapped Cell
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "BeerDetails" {
            var selectedBeer: Beer!
            
            let backButtonItem = UIBarButtonItem()
            
            if let IndexPath = beersByStyleTable.indexPathForSelectedRow {
                let beerDetailsVC = segue.destination as! BeerDetailsViewController
                selectedBeer = beers[IndexPath.row]
                beerDetailsVC.beer = selectedBeer
            }
            
            backButtonItem.title = "Beer List"
            navigationItem.backBarButtonItem = backButtonItem
        }
    }
    
    func refreshBeerList() {
        loadSuggestedBeers()
    }
    
    func loadSuggestedBeers() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        BreweryDBClient.sharedInstance().getBeerStyleFromSearch(styleID: styleID) { (success, data, error) in
            if success {
                DispatchQueue.main.async {
                    self.beers = Beer.beersFromResults(data!)
                    self.beersByStyleTable.reloadData()
                    self.refreshControl?.endRefreshing()
                    self.activityIndicator.isHidden = true
                    self.activityIndicator.stopAnimating()
                }
            } else {
                DispatchQueue.main.async {
                    self.displayError("No data returned. Please check internet connection")
                    self.activityIndicator.isHidden = true
                    self.activityIndicator.stopAnimating()
                }
            }
        }
    }

    
    func displayError(_ errorString: String?) {
        let alertController = UIAlertController(title: nil, message: errorString, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
    }
}
    
extension StyleListViewController: UITableViewDataSource {
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return beers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BeerTableCell", for: indexPath) as! CustomBeerTableCell
        
        let beersToShow = beers[indexPath.row]
        
        cell.beerName.text = beersToShow.name
        cell.brewery.text = beersToShow.brewery?.first?[BreweryDBClient.BreweryDBBreweryResponseKeys.Name] as! String?
        if beersToShow.abv == nil {
            cell.abv.text = "N/A"
        } else {
            cell.abv.text = "ABV: \(beersToShow.abv! as String)%"
        }
        
        return cell
    }
}
