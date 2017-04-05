//
//  ModalViewController.swift
//  Brew_Buddy
//
//  Created by Jess Gates on 1/27/17.
//  Copyright © 2017 Jess Gates. All rights reserved.
//

import UIKit
import CoreData

class ModalViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var beerRating: UILabel!
    @IBOutlet weak var tastingNotes: UITextView!
    
    var tappedBeer: Beer!
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
        tastingNotes.delegate = self
        
        configureNavItems()
        configureTextView()
        fetchFavoriteBeerByID()
    }
    
    // Dismiss the keybord when touches occur on the screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        tastingNotes.resignFirstResponder()
    }
    
    // Create the Save and Cancel buttons for the navigation bar
    func configureNavItems() {
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(ModalViewController.save))

        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(ModalViewController.cancel))

        let topViewController = self.navigationController!.topViewController
        topViewController!.navigationItem.rightBarButtonItem = saveButton
        topViewController!.navigationItem.leftBarButtonItem = cancelButton
    }
    
    // Check Core for a Favorite Beer with same id as the selected Beer
    func fetchFavoriteBeerByID() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        dataStack = delegate.dataStack
        fetchedResultsController.delegate = self
        fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "id == %@", tappedBeer.id)
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            displayError("Unable To Fetch Favorite Beers from Core Data!")
        }
        
        dataStack.save()
    }
    
    // Save the rating and notes upon tap
    func save() {
        fetchedResultsController.fetchedObjects?.first?.rating = beerRating.text
        fetchedResultsController.fetchedObjects?.first?.tastingNotes = tastingNotes.text
        dataStack.save()
        dismiss(animated: true, completion: nil)
    }
    
    // Delete the favorite beer from Core Data
    func cancel() {
        let beerToDelete = fetchedResultsController.fetchedObjects?.first
        dataStack.context.delete(beerToDelete!)
        dataStack.save()
        dismiss(animated: true, completion: nil)
    }
    
    // Create an alert for any errors
    func displayError(_ errorString: String?) {
        
        let alertController = UIAlertController(title: nil, message: errorString, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - UITextViewDelegate Methods

extension ModalViewController: UITextViewDelegate {
    
    func configureTextView() {
        tastingNotes!.layer.borderWidth = 1
        tastingNotes!.layer.borderColor = UIColor.black.cgColor
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        tastingNotes.becomeFirstResponder()
            if tastingNotes.text == "Tap to add notes..." {
            tastingNotes.text = ""
          }
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
