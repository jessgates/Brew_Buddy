//
//  FavoriteBeerDetailsTableViewController.swift
//  Brew_Buddy
//
//  Created by Jess Gates on 1/31/17.
//  Copyright © 2017 Jess Gates. All rights reserved.
//

import UIKit
import CoreData

class FavoriteBeerDetailsTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var favoriteBeerLabel: UIImageView!
    @IBOutlet weak var favoriteBeerName: UILabel!
    @IBOutlet weak var favoriteBrewery: UILabel!
    @IBOutlet weak var favoriteWebsite: UILabel!
    @IBOutlet weak var favoriteRating: BeerRatingLabel!
    @IBOutlet weak var tastingNotes: UITextView!
    
    var favoriteBeer: FavoriteBeer!
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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share(_:)))
        
        tableView.keyboardDismissMode = .onDrag
        
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(BeerDetailsViewController.websiteLabelTapped))
        favoriteWebsite.addGestureRecognizer(tap)

        fetchFavoriteBeerByID()
        setProperties()
        
    }
    
    // Save the rating and notes before the view disapears
    override func viewWillDisappear(_ animated: Bool) {
        fetchedResultsController.fetchedObjects?.first?.rating = favoriteRating.text
        fetchedResultsController.fetchedObjects?.first?.tastingNotes = tastingNotes.text
        dataStack.save()
    }
    
    // Set the properties of the selected favorite beer
    func setProperties() {
        favoriteBeerLabel.image = UIImage(data: favoriteBeer.beerLabel as! Data)
        favoriteBeerName.text = favoriteBeer.beerName
        favoriteBrewery.text = favoriteBeer.breweryName
        favoriteWebsite.text = favoriteBeer.breweryWebsite
        favoriteRating.text = favoriteBeer.rating
        tastingNotes.text = favoriteBeer.tastingNotes
    }
    
    func websiteLabelTapped(_ sender: UITapGestureRecognizer) {
        if favoriteWebsite.text != "No Website Available" {
            if let url = URL(string: favoriteWebsite.text!) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    // Check Core for a Favorite Beer with same id as the selected Beer
    func fetchFavoriteBeerByID() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        dataStack = delegate.dataStack
        fetchedResultsController.delegate = self
        fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "id == %@", favoriteBeer.id!)
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            displayError("Unable To Fetch Favorite Beers from Core Data!")
        }
        
        dataStack.save()
    }
    
    func share(_ sender: UIBarButtonItem) {
        let nameToShare = favoriteBeer.beerName
        let urlToShare = favoriteBeer.breweryWebsite
        let labelToShare = favoriteBeer.beerLabel
        let activityViewController = UIActivityViewController(activityItems: [nameToShare!, urlToShare!, labelToShare!], applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }
    
    // Create an alert for any errors
    func displayError(_ errorString: String?) {
        
        let alertController = UIAlertController(title: nil, message: errorString, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
    }
    
// MARK: - UITableViewDelegate Methods
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let headerHeight = CGFloat.leastNonzeroMagnitude
        return headerHeight
    }
    
    // Set cell height based on indexPath row. Cell height for notes based on text lenght
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                return 150
            case 1, 2, 3:
                return 44
            default:
                return UITableViewAutomaticDimension
            }
        case 1:
            switch indexPath.row {
            case 0:
                if tastingNotes.text == "" {
                    return 44
                } else {
                    return UITableViewAutomaticDimension
                }
            default:
                return 44
            }
        default:
            return UITableViewAutomaticDimension
        }
    }
}

// MARK: - UITextViewDelegate Methods

extension FavoriteBeerDetailsTableViewController: UITextViewDelegate {
    
    func configureTextView() {
        tastingNotes!.layer.borderWidth = 0.5
        tastingNotes!.layer.borderColor = UIColor(red:0.24, green:0.48, blue:0.54, alpha:1.0).cgColor
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        tastingNotes.becomeFirstResponder()
        if tastingNotes.text == "Tap to add notes..." {
            tastingNotes.text = ""
        }
    }
    
    // Allow text view and table view to grow as the user types
    func textViewDidChange(_ textView: UITextView) {
        let currentOffset = tableView.contentOffset
        UIView.setAnimationsEnabled(false)
        tableView.beginUpdates()
        tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
        tableView.setContentOffset(currentOffset, animated: false)
    }
    
    // Dismis keyboard on return
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            view.endEditing(true)
            return false
        } else {
            return true
        }
    }
}
