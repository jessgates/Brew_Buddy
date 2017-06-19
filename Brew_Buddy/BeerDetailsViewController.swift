//
//  BeerDetailsViewController.swift
//  Brew_Buddy
//
//  Created by Jess Gates on 1/6/17.
//  Copyright © 2017 Jess Gates. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import Firebase

class BeerDetailsViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var beerLabelImage: UIImageView!
    @IBOutlet weak var beerName: UILabel!
    @IBOutlet weak var beerStyle: UILabel!
    @IBOutlet weak var breweryName: UILabel!
    @IBOutlet weak var breweryWebsite: UILabel!
    @IBOutlet weak var beerDescription: UILabel!
    @IBOutlet weak var addToFavoritesButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var ref: DatabaseReference!
    
    var beer: Beer!
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
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(BeerDetailsViewController.websiteLabelTapped))
        breweryWebsite.addGestureRecognizer(tap)
        
        configureDatabase()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
        setProperties()
        fetchFavoriteBeerByID()
        setAddToFavoritesButton()
    }
    
    // Prepare for segue to ModalVC
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        let destinationVC = segue.destination as! UINavigationController
        let modalController = destinationVC.topViewController as! ModalViewController
        modalController.tappedBeer = beer
    }
    
// MARK: - Helper Functions
    
    func configureDatabase() {
        ref = Database.database().reference()
    }
    
    // Set state of Favorites button based on if Beer existis as a Favorite or not
    func setAddToFavoritesButton() {
        if fetchedResultsController.fetchedObjects?.count == 0 {
            addToFavoritesButton.setTitle("Add To Favorites", for: .normal)
            addToFavoritesButton.isEnabled = true
        } else {
            addToFavoritesButton.setTitle("Beer Is Already A Favorite", for: .normal)
            addToFavoritesButton.isEnabled = false
        }
    }
    
    // Populate the datailed Beer properties from BreweryDB
    func setProperties() {
        activityIndicator.startAnimating()
        
        //If a label URL exists, download and display image, if not, display placeholder image
        if let beerLabels = beer.labels {
            BreweryDBClient.sharedInstance().downloadImage(imagePath: (beerLabels[BreweryDBClient.BreweryDBBeersResponseKeys.MediumURL])!) { (imageData, error) in
                if let image = UIImage(data: imageData! as Data) {
                    DispatchQueue.main.async {
                        self.beerLabelImage.image = image
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.isHidden = true
                    }
                }
            }
        } else {
            self.beerLabelImage.image = UIImage(named: "imagePlaceHolder")
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
        }
        
        beerName.text = beer.name
        
        if let style = beer.style?["name"] as? String {
                beerStyle.text = style
        }
        
        if let brewery = beer.brewery?.first?[BreweryDBClient.BreweryDBBreweryResponseKeys.Name] as? String {
            breweryName.text = brewery
        } else {
            breweryName.text = "No Brewery Information Available"
        }
        
        if let website = beer.brewery?.first?[BreweryDBClient.BreweryDBBreweryResponseKeys.Website] as? String {
            breweryWebsite.text = website
        } else {
            breweryWebsite.text = "No Website Available"
        }
        
        if let description = beer.description {
            beerDescription.text = description
        } else {
            beerDescription.text = "No Description Availale"
        }
    }
    
    // Check Core for a Favorite Beer with same id as the selected Beer
    func fetchFavoriteBeerByID() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        dataStack = delegate.dataStack
        fetchedResultsController.delegate = self
        fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "id == %@", beer.id)
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            displayError("Unable To Fetch Favorite Beers from Core Data!")
        }
        dataStack.save()
    }
    
    // Save a Favorite Beer
    func saveFavoriteBeer() {
        
        var favoriteBeer = [String:Any]()
        favoriteBeer["id"] = beer.id
        favoriteBeer["abv"] = beer.abv
        favoriteBeer["description"] = beer.description
        favoriteBeer["beerName"] = beer.name
        favoriteBeer["breweryName"] = breweryName.text
        favoriteBeer["breweryWebsite"] = breweryWebsite.text
        
        ref.child("favoriteBeer").childByAutoId().setValue(favoriteBeer)
        
//        if let entity = NSEntityDescription.entity(forEntityName: "FavoriteBeer", in: dataStack.context) {
//            let newFavoriteBeer = FavoriteBeer(entity: entity, insertInto: dataStack.context)
//            newFavoriteBeer.id = beer.id
//            newFavoriteBeer.abv = beer.abv
//            newFavoriteBeer.beerDescription = beer.description
//            newFavoriteBeer.beerName = beer.name
//            newFavoriteBeer.breweryName = breweryName.text
//            newFavoriteBeer.breweryWebsite = breweryWebsite.text
//            newFavoriteBeer.rating = ""
//            newFavoriteBeer.tastingNotes = ""
//            if let style = beer.style?["name"] as? String {
//                newFavoriteBeer.style = style
//            }
//            
//            newFavoriteBeer.styleID = beer.styleID!
//            
//            if beerLabelImage.image == UIImage(named: "imagePlaceHolder") {
//                newFavoriteBeer.beerLabel = nil
//            } else {
//                newFavoriteBeer.beerLabel = UIImagePNGRepresentation(beerLabelImage.image!)! as NSData?
//            }
//            
//            dataStack.save()
//        }
    }
    
    // Create an alert for any errors
    func displayError(_ errorString: String?) {
        let alertController = UIAlertController(title: nil, message: errorString, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
    }
    
    // Open browser when the webiste is tapped
    func websiteLabelTapped(_ sender: UITapGestureRecognizer) {
        if breweryWebsite.text != "No Website Available" {
            if let url = URL(string: breweryWebsite.text!) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
// MARK: - UITableViewDelegate Methods
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let headerHeight = CGFloat.leastNonzeroMagnitude
        return headerHeight
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    // Set cell height based on indexPath row. Cell height for Beer description based on text lenght
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 150
        case 5:
            return UITableViewAutomaticDimension
        case 1, 2, 3, 4, 6:
            return 44
        default:
            return 44
        }
    }
    
// MARK: - Actions
    
    @IBAction func addToFavoritesTapped() {
        saveFavoriteBeer()
    }
}
