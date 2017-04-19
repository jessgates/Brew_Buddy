//
//  FavoriteBeerDetailsTableViewController.swift
//  Brew_Buddy
//
//  Created by Jess Gates on 1/31/17.
//  Copyright © 2017 Jess Gates. All rights reserved.
//

import UIKit
import CoreData

class FavoriteBeerDetailsTableViewController: UITableViewController, UINavigationControllerDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var favoriteBeerLabel: UIImageView?
    @IBOutlet weak var favoriteBeerName: UILabel!
    @IBOutlet weak var favoriteBrewery: UILabel!
    @IBOutlet weak var favoriteWebsite: UILabel!
    @IBOutlet weak var favoriteRating: BeerRatingLabel!
    @IBOutlet weak var tastingNotes: UITextView!
    
    let imagePicker = UIImagePickerController()
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
        
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableViewAutomaticDimension
        
        let tapWebsite = UITapGestureRecognizer(target: self, action: #selector(FavoriteBeerDetailsTableViewController.websiteLabelTapped))
        favoriteWebsite.addGestureRecognizer(tapWebsite)
        
        let tapImage = UITapGestureRecognizer(target: self, action: #selector(FavoriteBeerDetailsTableViewController.imageLabelTapped))
        favoriteBeerLabel?.isUserInteractionEnabled = true
        favoriteBeerLabel?.addGestureRecognizer(tapImage)

        fetchFavoriteBeerByID()
        setProperties()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "styleSearch" {
            //let destinationNavigationVC = segue.destination as! UINavigationController
            let destinationVC = segue.destination as! StyleListViewController
            destinationVC.styleID = favoriteBeer.styleID
        }
    }
    
    // Save the rating and notes before the view disapears
    override func viewWillDisappear(_ animated: Bool) {
        fetchedResultsController.fetchedObjects?.first?.rating = favoriteRating.text
        fetchedResultsController.fetchedObjects?.first?.tastingNotes = tastingNotes.text
        dataStack.save()
    }
    
    // Set the properties of the selected favorite beer
    func setProperties() {
        if favoriteBeer.beerLabel == nil {
            favoriteBeerLabel?.image = nil
            //favoriteBeerLabel?.image = UIImage(named: "addPhoto")
        } else {
            favoriteBeerLabel?.isUserInteractionEnabled = false
            favoriteBeerLabel?.image = UIImage(data: favoriteBeer.beerLabel! as Data)
        }
        
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
    
    func imageLabelTapped(_sender: UITapGestureRecognizer) {
        newImage()
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
    
    // Select a new image or take a photo to represent the favorite beer label
    func newImage() {
        imagePicker.delegate = self
        
        let alertController = UIAlertController(title: "Add a New Label Photo!", message: "Chose a photo from your library or take a picture with the Camera", preferredStyle: .alert)
        
        let openPhotoLibrary = UIAlertAction(title: "Photo Library", style: .default) { (action) in
            self.imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            self.imagePicker.allowsEditing = false
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        alertController.addAction(openPhotoLibrary)
        
        let openCamera = UIAlertAction(title: "Camera", style: .default) { (action) in
            self.imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            self.imagePicker.allowsEditing = false
            self.imagePicker.cameraCaptureMode = .photo
            self.imagePicker.modalPresentationStyle = .fullScreen
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        alertController.addAction(openCamera)
        
        let cancel = UIAlertAction(title: "Cancel", style: .default) { (action) in
        }
        
        alertController.addAction(cancel)
        present(alertController, animated: true, completion: nil)
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

// MARK: - UIImagePickerControllerDelegate Methods

extension FavoriteBeerDetailsTableViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true, completion: nil)
        
        let selectedimage = info[UIImagePickerControllerOriginalImage] as! UIImage
        let image = UIImage(cgImage: selectedimage.cgImage!, scale: 1, orientation: selectedimage.imageOrientation)
        let finalImage = UIImageJPEGRepresentation(image, 1.0)
        favoriteBeerLabel?.image = UIImage(data: finalImage!)
        fetchedResultsController.fetchedObjects?.first?.beerLabel = finalImage! as Data as NSData?
        dataStack.save()
        
    }
}
