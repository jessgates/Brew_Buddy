//
//  FavoriteBeersViewController.swift
//  Brew_Buddy
//
//  Created by Jess Gates on 1/6/17.
//  Copyright © 2017 Jess Gates. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import DZNEmptyDataSet


class FavoriteBeersTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var addFavoriteBarButton: UIBarButtonItem!
    @IBOutlet weak var favoriteBeerTable: UITableView!

    var favoriteBeerID: String?
    var dataStack: CoreDataStack!
    
    // Initiate an instance of FetchedResultsController
    lazy var fetchedResultsController: NSFetchedResultsController<FavoriteBeer> = { () -> NSFetchedResultsController<FavoriteBeer> in
        
        let fetchRequest = NSFetchRequest<FavoriteBeer>(entityName: "FavoriteBeer")
        fetchRequest.sortDescriptors = []
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.dataStack.context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchFavoriteBeers()
        favoriteBeerTable.emptyDataSetSource = self
        favoriteBeerTable.emptyDataSetDelegate = self
        favoriteBeerTable.tableFooterView = UIView()
        favoriteBeerTable.reloadData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchFavoriteBeers()
    }
    
    // Prepare for segue to FavoriteBeerDetails, sending the selected Beer
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FavoriteBeerDetails" {
            if let IndexPath = favoriteBeerTable.indexPathForSelectedRow {
                let selectedBeer = fetchedResultsController.object(at: IndexPath)
                let beerDetailsVC = segue.destination as! FavoriteBeerDetailsTableViewController
                beerDetailsVC.favoriteBeer = selectedBeer
            }
        } else if segue.identifier == "AddFavorite" {
            let destinationVC = segue.destination as! UINavigationController
            let modalController = destinationVC.topViewController as! NewFavoriteFormViewController
            presentingViewController?.present(modalController, animated: true, completion: nil)
        }
    }
    
// MARK: - Helper Functions
    
    // Fetch all Favorite Beers from Core Data
    func fetchFavoriteBeers() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        dataStack = delegate.dataStack
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            displayError("Unable To Fetch Favorite Beers from Core Data!")
        }
        
        dataStack.save()
        favoriteBeerTable.reloadData()
    }
    
    // Create an alert for any errors
    func displayError(_ errorString: String?) {
        let alertController = UIAlertController(title: nil, message: errorString, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
    }
    
// MARK: - UITableViewDataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteBeerCell", for: indexPath) as! CustomBeerTableCell
        
        let beer = fetchedResultsController.object(at: indexPath)
        
        if let abv = beer.abv {
            cell.abv.text = "ABV: \(abv)%"
        } else {
            cell.abv.text = "N/A"
        }
    
        cell.beerName.text = beer.beerName
        cell.brewery.text = beer.breweryName
        cell.rating.text = beer.rating
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let beer = fetchedResultsController.object(at: indexPath)
            dataStack.context.delete(beer)
            dataStack.save()
            fetchFavoriteBeers()
        }
    }
}

// MARK: - DZNEmptyDataSet Data Source Methods

extension FavoriteBeersTableViewController: DZNEmptyDataSetSource {
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return UIImage(named: "beerMug.png")
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "Favorite Beer List!"
        let attrs = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "This is where your favorite beers will be stored when you add them."
        let attrs = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)]
        return NSAttributedString(string: str, attributes: attrs)
    }
}

// MARK: - DZNEmptyDataSet Delegate Methods

extension FavoriteBeersTableViewController: DZNEmptyDataSetDelegate {
    
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
}
