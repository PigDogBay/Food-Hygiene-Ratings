//
//  MainViewController.swift
//  Food Hygiene Ratings
//
//  Created by Mark Bailey on 12/02/2017.
//  Copyright © 2017 MPD Bailey Technology. All rights reserved.
//

import UIKit

class RootViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet weak var businessNameTextField: UITextField!
    @IBOutlet weak var placeNameTextField: UITextField!

    let segueIdNearMe = "segueNearMe"
    let segueIdQuickSearch = "segueQuickSearch"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        businessNameTextField.delegate = self
        placeNameTextField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === businessNameTextField {
            businessNameTextField.resignFirstResponder()
            placeNameTextField.becomeFirstResponder()
        } else if textField === placeNameTextField {
            placeNameTextField.resignFirstResponder()
            performSegue(withIdentifier: segueIdQuickSearch, sender: self)
        }
        return true
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        switch identifier {
        case segueIdQuickSearch:
            let query = createQuery()
            if query.isEmpty() {
                mpdbShowAlert("No Name or Place", msg: "Enter a name and place to search for")
                return false
            }
        default:
            break
            
        }
        return true
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        switch segue.identifier ?? "" {
        case segueIdNearMe:
            MainModel.sharedInstance.findLocalEstablishments()
        case segueIdQuickSearch:
            let query = createQuery()
            MainModel.sharedInstance.findEstablishments(query: query)
        default:
            break
            
        }
     
    }

    fileprivate func createQuery() -> Query {
        var query = Query()
        if let name  = businessNameTextField.text {
            if name != "" {
                query.businessName = name
            }
        }
        if let place = placeNameTextField.text {
            if place != "" {
                query.placeName = place
            }
        }
        return query
    }
    
}
