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
import Firebase


class FavoriteBeersTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var addFavoriteBarButton: UIBarButtonItem!
    @IBOutlet weak var favoriteBeerTable: UITableView!
    
    var userUid: String?
    var favoriteBeerID: String?
    var ref: DatabaseReference!
    var favoriteBeers = [DataSnapshot]()
    fileprivate var _refHandle: DatabaseHandle!
    
    //var dataStack: CoreDataStack!
    
    // Initiate an instance of FetchedResultsController
//    lazy var fetchedResultsController: NSFetchedResultsController<FavoriteBeer> = { () -> NSFetchedResultsController<FavoriteBeer> in
//        
//        let fetchRequest = NSFetchRequest<FavoriteBeer>(entityName: "FavoriteBeer")
//        fetchRequest.sortDescriptors = []
//        
//        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.dataStack.context, sectionNameKeyPath: nil, cacheName: nil)
//        fetchedResultsController.delegate = self
//        
//        return fetchedResultsController
//    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //fetchFavoriteBeers()
        favoriteBeerTable.emptyDataSetSource = self
        favoriteBeerTable.emptyDataSetDelegate = self
        favoriteBeerTable.tableFooterView = UIView()
        //favoriteBeerTable.reloadData()
        configureDatabase()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //fetchFavoriteBeers()
    }
    
    // Prepare for segue to FavoriteBeerDetails, sending the selected Beer
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FavoriteBeerDetails" {
            if let IndexPath = favoriteBeerTable.indexPathForSelectedRow {
                let selectedBeer = favoriteBeers[IndexPath.row]
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
//    func fetchFavoriteBeers() {
//        let delegate = UIApplication.shared.delegate as! AppDelegate
//        dataStack = delegate.dataStack
//        fetchedResultsController.delegate = self
//        
//        do {
//            try fetchedResultsController.performFetch()
//        } catch {
//            displayError("Unable To Fetch Favorite Beers from Core Data!")
//        }
//        
//        dataStack.save()
//        favoriteBeerTable.reloadData()
//    }
    
    func configureDatabase() {
        ref = Database.database().reference()
        
        userUid = Auth.auth().currentUser?.uid
        _refHandle = ref.child("users").child(userUid!).observe(.childAdded, with: { (snapshot: DataSnapshot) in
            self.favoriteBeers.append(snapshot)
            self.favoriteBeerTable.insertRows(at: [IndexPath(row: self.favoriteBeers.count - 1, section: 0)], with: .automatic)
            print(snapshot)
            self.favoriteBeerTable.reloadData()
        })
        
        _refHandle = ref.child("users").child(userUid!).observe(.childRemoved, with: { (snapshot: DataSnapshot) in
            self.favoriteBeerTable.reloadData()
        })
    }
    
    deinit {
        ref.child("users").child(userUid!).removeObserver(withHandle: _refHandle)
    }
    
    // Create an alert for any errors
    func displayError(_ errorString: String?) {
        let alertController = UIAlertController(title: nil, message: errorString, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
    }
    
// MARK: - UITableViewDataSource Methods
    
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        //return self.fetchedResultsController.sections?.count ?? 0
//    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //let sectionInfo = self.fetchedResultsController.sections![section]
        //return sectionInfo.numberOfObjects
        return favoriteBeers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteBeerCell", for: indexPath) as! CustomBeerTableCell
        
        let favoriteBeersSnapshot = favoriteBeers[indexPath.row]
        let favoriteBeer = favoriteBeersSnapshot.value as! [String:Any]
        let beerName = favoriteBeer["beerName"]
        let breweryName = favoriteBeer["breweryName"]
        if let abv = favoriteBeer["abv"] {
            cell.abv.text = "ABV: \(abv as! String)%"
        } else {
            cell.abv.text = "N/A"
        }
    
        cell.beerName.text = beerName as? String
        cell.brewery.text = breweryName as? String
        
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //let beer = fetchedResultsController.object(at: indexPath)
//            dataStack.context.delete(beer)
//            dataStack.save()
            //fetchFavoriteBeers()
            
            favoriteBeerID = favoriteBeers[indexPath.row].key
            ref.child("users").child(userUid!).child(favoriteBeerID!).removeValue()
            favoriteBeerTable.deleteRows(at: [indexPath], with: .fade)
            favoriteBeers.remove(at: indexPath.row)
//            favoriteBeerTable.reloadData()
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
