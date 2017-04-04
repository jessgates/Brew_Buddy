//
//  NewFavoriteFormViewController.swift
//  Brew_Buddy
//
//  Created by Jess Gates on 3/23/17.
//  Copyright © 2017 Jess Gates. All rights reserved.
//

import Foundation
import Eureka
import CoreData

class NewFavoriteFormViewController: FormViewController {
    
    var dataStack: CoreDataStack!
    var validation: AnyObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        dataStack = delegate.dataStack
        
        ImageRow.defaultCellUpdate = { cell, row in
            cell.accessoryView?.layer.cornerRadius = 17
            cell.accessoryView?.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        }
        
        configureNavItems()
        //navigationItem.rightBarButtonItem?.isEnabled = false
        createBeerForm()
    }
    
    func createBeerForm() {
        form +++ Section("Enter Beer Information")
            <<< ImageRow(){
                $0.tag = "beerLabel"
                $0.title = "Tap here to add a Beer Label Picture"
            }
            
            <<< TextRow() { row in
                row.tag = "beerName"
                row.title = "Beer Name"
                row.placeholder = "Add beer name here"
                row.add(rule: RuleRequired(msg: "required"))
                row.validationOptions = .validatesOnDemand
            }
            
            <<< PickerInputRow<String>("Picker Input Row") {
                $0.tag = "style"
                $0.title = "Beer Style"
                $0.options = ["Select Style", "Pale Ale", "IPA", "Lager", "Belgian Ale", "Stout", "Porter", "Pilsener", "Wheat", "Saison", "ESB", "Gose", "Sour", "Other"]
                $0.value = $0.options.first
                $0.add(rule: RuleRequired(msg: "required"))
                $0.validationOptions = .validatesOnDemand
            }
            
            <<< CustomRatingRow("CustomRatingCell") { row in
                row.tag = "beerRating"
                row.title = "Rating"
            }
            
            <<< TextRow() { row in
                row.tag = "abv"
                row.title = "ABV"
                row.placeholder = "Enter ABV here"
                }
                .cellSetup { cell, _ in
                    cell.textField.autocorrectionType = .default
                    cell.textField.autocapitalizationType = .sentences
                    cell.textField.keyboardType = .decimalPad
            }
            <<< TextRow(){ row in
                row.tag = "breweryName"
                row.title = "Brewery"
                row.placeholder = "Add brewery name here"
                row.add(rule: RuleRequired(msg: "required"))
                row.validationOptions = .validatesOnDemand
            }
            <<< TextRow() { row in
                row.tag = "breweryWebsite"
                row.title = "Brewery Website"
                row.placeholder = "Add brewery website here"
            }
            <<< TextAreaRow() {
                $0.tag = "tastingNotes"
                $0.title = "Tasting Notes"
                $0.placeholder = "Enter tasting notes..."
                $0.textAreaHeight = .dynamic(initialTextViewHeight: 44)
            }
        
        validation = form.validate() as AnyObject?
        displayError("Please enter a value in all fields before saving.")
    }
    
    func configureNavItems() {
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(NewFavoriteFormViewController.save))
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(NewFavoriteFormViewController.cancel))
        
        let topViewController = self.navigationController!.topViewController
        topViewController!.navigationItem.rightBarButtonItem = saveButton
        topViewController!.navigationItem.leftBarButtonItem = cancelButton
    }
    
    func save() {
        
        var dict = form.values(includeHidden: true)
        
        for (_, value) in dict {
            if value == nil {
                displayError("Please fill in all fields before saving.")
            } else {
                if let entity = NSEntityDescription.entity(forEntityName: "FavoriteBeer", in: dataStack.context) {
                    let newFavoriteBeer = FavoriteBeer(entity: entity, insertInto: dataStack.context)
                    newFavoriteBeer.id = UUID().uuidString
                    newFavoriteBeer.abv = dict["abv"] as! String?
                    newFavoriteBeer.beerDescription = ""
                    newFavoriteBeer.breweryWebsite = dict["breweryWebsite"] as! String?
                    newFavoriteBeer.rating = "☆☆☆☆☆"
                    newFavoriteBeer.tastingNotes = dict["tastingNotes"] as! String?
                    
                    if let labelImage = dict["beerLabel"] {
                        if labelImage == nil {
                            newFavoriteBeer.beerLabel = labelImage as! NSData?
                        } else {
                            newFavoriteBeer.beerLabel = UIImagePNGRepresentation(dict["beerLabel"] as! UIImage)! as NSData?
                        }
                    }
                    
                    if let beerName = dict["beerName"] {
                        if beerName == nil {
                            newFavoriteBeer.beerName = "N/A"
                        } else {
                            newFavoriteBeer.beerName = dict["beerName"] as! String?
                        }
                    }
                    
                    if let breweryName = dict["breweryName"] {
                        if breweryName == nil {
                            newFavoriteBeer.breweryName = "N/A"
                        } else {
                            newFavoriteBeer.breweryName = dict["breweryName"] as! String?
                        }
                    }
                    dataStack.save()
                }
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    func displayError(_ errorString: String?) {
        
        let alertController = UIAlertController(title: nil, message: errorString, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
    }
    
}
