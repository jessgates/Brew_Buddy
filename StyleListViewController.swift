//
//  StyleListViewController.swift
//  Brew_Buddy
//
//  Created by Jess Gates on 4/17/17.
//  Copyright © 2017 Jess Gates. All rights reserved.
//

import UIKit

class StyleListViewController: UITableViewController {
    
    var beers: [Beer] = [Beer]()
    var styleID: Double!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSuggestedBeers()
        
        let refreshBeerListButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshBeerListButtonPressed))
        navigationItem.setLeftBarButton(refreshBeerListButton, animated: true)
    }
    
    // Segue to BeerDetailsVC on tapped Cell
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "BeerDetails" {
            var selectedBeer: Beer!
            
            let backButtonItem = UIBarButtonItem()
            
            if let IndexPath = tableView.indexPathForSelectedRow {
                let beerDetailsVC = segue.destination as! BeerDetailsViewController
                selectedBeer = beers[IndexPath.row]
                beerDetailsVC.beer = selectedBeer
            }
            
            backButtonItem.title = "Beer List"
            navigationItem.backBarButtonItem = backButtonItem
        }
    }
    
    func refreshBeerListButtonPressed() {
        loadSuggestedBeers()
    }
    
    func loadSuggestedBeers() {
        BreweryDBClient.sharedInstance().getBeerStyleFromSearch(styleID: styleID) { (success, data, error) in
            if success {
                DispatchQueue.main.async {
                    self.beers = Beer.beersFromResults(data!)
                    self.tableView.reloadData()
                }
            } else {
                DispatchQueue.main.async {
                    self.displayError("No data returned. Please check internet connection")
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return beers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
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
