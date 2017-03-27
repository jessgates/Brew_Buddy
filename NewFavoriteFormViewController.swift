//
//  NewFavoriteFormViewController.swift
//  Brew_Buddy
//
//  Created by Jess Gates on 3/23/17.
//  Copyright © 2017 Jess Gates. All rights reserved.
//

import Foundation
import Eureka

class NewFavoriteFormViewController: FormViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavItems()
        createBeerForm()
    }
    
    func createBeerForm() {
        form +++ Section("Enter Beer Information")
            <<< TextRow(){ row in
                row.tag = "beerName"
                row.title = "Beer Name"
                row.placeholder = "Add beer name here"
        }
            <<< PickerInputRow<String>("Picker Input Row") {
                $0.tag = "style"
                $0.title = "Beer Style"
                $0.options = ["Select Style", "Pale Ale", "IPA", "Lager", "Belgian Ale", "Stout", "Porter", "Pilsener", "Wheat", "Saison", "ESB", "Gose", "Sour"]
                $0.value = $0.options.first
        }
            <<< DecimalRow() {
                $0.tag = "abv"
                $0.title = "ABV"
                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                $0.formatter = formatter
                $0.value = 0
                $0.useFormatterDuringInput = true
            //}.cellSetup { cell, _ in
                //cell.textField.keyboardType = .numberPad
        }
            <<< TextRow(){ row in
                row.tag = "breweryName"
                row.title = "Brewery"
                row.placeholder = "Add brewery name here"
        }
            <<< URLRow() {
                $0.tag = "breweryWebsite"
                $0.title = "Brewery Website"
                $0.placeholder = "Add brewery website here"
        }
            <<< TextAreaRow() {
                $0.tag = "tastingNotes"
                $0.title = "Tasting Notes"
                $0.placeholder = "Enter tasting notes..."
                $0.textAreaHeight = .dynamic(initialTextViewHeight: 44)
        }
    }
    
    func configureNavItems() {
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(NewFavoriteFormViewController.save))
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(NewFavoriteFormViewController.cancel))
        
        let topViewController = self.navigationController!.topViewController
        topViewController!.navigationItem.rightBarButtonItem = saveButton
        topViewController!.navigationItem.leftBarButtonItem = cancelButton
    }
    
    func save() {
        let dict = form.values(includeHidden: true)
        print(dict)
        //dismiss(animated: true, completion: nil)
    }
    
    // Delete the favorite beer from Core Data
    func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
}
