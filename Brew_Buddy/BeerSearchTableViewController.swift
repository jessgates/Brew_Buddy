//
//  ViewController.swift
//  Brew_Buddy
//
//  Created by Jess Gates on 1/6/17.
//  Copyright © 2017 Jess Gates. All rights reserved.
//

import UIKit

class BeerSearchTableViewController: UIViewController {
    
    @IBOutlet weak var beerTable: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var isLoadingBeers = false
    var showSearchResults = false
    var beers: [Beer] = [Beer]()
    var beersSearchResults: [Beer] = [Beer]()
    var searchController: UISearchController!
    var footerActivityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        definesPresentationContext = true
        loadFirstPageOfBeers()
        configureSearchController()
        configureFooterActivityIndicator()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if beers.count == 0 {
            loadFirstPageOfBeers()
        }
    }
    
    // Segue to BeerDetailsVC on tapped Cell
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "BeerDetails" {
            var selectedBeer: Beer!
            
            let backButtonItem = UIBarButtonItem()
            
            if let IndexPath = beerTable.indexPathForSelectedRow {
                let beerDetailsVC = segue.destination as! BeerDetailsViewController
                if showSearchResults {
                    selectedBeer = beersSearchResults[IndexPath.row]
                } else {
                    selectedBeer = beers[IndexPath.row]
                }
                beerDetailsVC.beer = selectedBeer
            }
            
            backButtonItem.title = "Beer List"
            navigationItem.backBarButtonItem = backButtonItem
        }
    }
    
// MARK: - Helper Functions
    
    // Configure serach controller and style search bar.
    func configureSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search List of Beers..."
        searchController.searchBar.sizeToFit()
        searchController.searchBar.tintColor = UIColor(red:0.31, green:0.14, blue:0.07, alpha:1.0)
        navigationItem.titleView = searchController.searchBar
    }
    
    // Load first first page (50) of beers from the BreweryDB
    func loadFirstPageOfBeers() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        isLoadingBeers = true
        BreweryDBClient.sharedInstance().getBeerList { (success, data, error) in
            if success {
                DispatchQueue.main.async {
                    self.isLoadingBeers = false
                    BreweryDBClient.sharedInstance().pageNumber += 1
                    self.beers = Beer.beersFromResults(data!)
                    self.beerTable.reloadData()
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                }
            } else {
                DispatchQueue.main.async {
                    self.displayError("No data returned. Please check internet connection")
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                }
            }
        }
    }
    
    // Load next page (50) beers from the BreweryDB until the last page is reached
    func loadMoreBeers() {
        footerActivityIndicator.isHidden = false
        footerActivityIndicator.startAnimating()
        isLoadingBeers = true
        if BreweryDBClient.sharedInstance().pageNumber < BreweryDBClient.sharedInstance().numberOfPages {
            BreweryDBClient.sharedInstance().getBeerList { (success, data, error) in
                if success {
                    DispatchQueue.main.async {
                        self.isLoadingBeers = false
                        BreweryDBClient.sharedInstance().pageNumber += 1
                        let moreBeers = Beer.beersFromResults(data!)
                        self.beers += moreBeers
                        self.beerTable.reloadData()
                        self.footerActivityIndicator.stopAnimating()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.footerActivityIndicator.stopAnimating()
                        self.displayError("No data returned. Please check internet connection")
                    }
                }
            }
        }
    }
    
    // Execute search, show Alert if no data is returned from server
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        isLoadingBeers = true
        if beersSearchResults.isEmpty {
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            BreweryDBClient.sharedInstance().getBeerFromSearch(queryString: searchBar.text!, { (success, data, error) in
                if success {
                    DispatchQueue.main.async {
                        self.showSearchResults = true
                        self.isLoadingBeers = false
                        if data == nil {
                            self.alertForBeerSearch()
                        } else {
                            self.beersSearchResults = Beer.beersFromResults(data!)
                        }
                        self.beerTable.reloadData()
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.isHidden = true
                        self.beerTable.tableFooterView = nil
                    }
                } else {
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.isHidden = true
                        self.beerTable.tableFooterView = nil
                        self.displayError("No data returned. Please check internet connection")
                    }
                }
            })
            
        } else {
            showSearchResults = true
            beerTable.reloadData()
        }
        
        searchController.searchBar.resignFirstResponder()
    }
    
    // Programmatically creat activity indicator for the table footer
    func configureFooterActivityIndicator() {
        footerActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        footerActivityIndicator.isHidden = true
        footerActivityIndicator.hidesWhenStopped = true
        beerTable.tableFooterView = footerActivityIndicator
    }
    
    // Alert to let the user know the search text returned no results
    func alertForBeerSearch() {
        let alertController = UIAlertController(title: "No Beer Found", message: "Your search did not find any related beers. Please try again.", preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (UIAlertAction) in
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    // Create an alert for any errors
    func displayError(_ errorString: String?) {
        let alertController = UIAlertController(title: nil, message: errorString, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource Methods

extension BeerSearchTableViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if showSearchResults {
            return beersSearchResults.count
        } else {
            return beers.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Show either full list of beers, or filtered based on search text
        var beersToShow: Beer
        
        let rowsToLoadFromBottom = 20
        let rowsLoaded = beers.count
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BeerTableCell", for: indexPath) as! CustomBeerTableCell
        
        if showSearchResults {
            beersToShow = beersSearchResults[indexPath.row]
        } else {
            beersToShow = beers[indexPath.row]
        }
        
        cell.beerName.text = beersToShow.name
        cell.brewery.text = beersToShow.brewery?.first?[BreweryDBClient.BreweryDBBreweryResponseKeys.Name] as! String?
        if beersToShow.abv == nil {
            cell.abv.text = "N/A"
        } else {
            cell.abv.text = "ABV: \(beersToShow.abv! as String)%"
        }
        
        // Load more beers as table reaches bottom when not searching
        if (!self.isLoadingBeers && (indexPath.row >= (rowsLoaded - rowsToLoadFromBottom))) {
            self.loadMoreBeers()
        }
        
        return cell
    }

}

// MARK: - UISearchBar Delegate Methods

extension BeerSearchTableViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        showSearchResults = true
        beerTable.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        showSearchResults = false
        beerTable.reloadData()
    }
}

// MARK: - UISearchResultsUpdating Protocol

extension BeerSearchTableViewController: UISearchResultsUpdating {
    
    // Filter the data array and get only those beers that match the search text.
    func updateSearchResults(for searchController: UISearchController) {
        let searchString = searchController.searchBar.text
        
        beersSearchResults = beers.filter({ (beer) -> Bool in
            let beerText: NSString = beer.name as NSString
            
            return (beerText.range(of: searchString!, options: NSString.CompareOptions.caseInsensitive).location) != NSNotFound
        })
        
        beerTable.reloadData()
    }
}

