//
//  AdvancedSearchViewController.swift
//  Food Hygiene Ratings
//
//  Created by Mark Bailey on 23/02/2017.
//  Copyright © 2017 MPD Bailey Technology. All rights reserved.
//

import UIKit

class AdvancedSearchViewController: UITableViewController, UITextFieldDelegate {
    @IBOutlet weak var businessNameTextField: UITextField!
    @IBOutlet weak var placeNameTextField: UITextField!

    @IBOutlet weak var localAuthorityCell: UITableViewCell!
    @IBOutlet weak var comparisonCell: UITableViewCell!
    @IBOutlet weak var ratingsCell: UITableViewCell!
    @IBOutlet weak var businessTypeCell: UITableViewCell!
    @IBOutlet weak var scottishRatingCell: UITableViewCell!

    @IBAction func unwindWithSelectedListItem(segue:UIStoryboardSegue) {
        if let vc = segue.source as? ListViewController {
            if let selected = vc.selectedItem {
                switch vc.id {
                case ratingValueListId:
                    ratingValue = selected
                case ratingOperatorListId:
                    ratingOperator = selected
                case localAuthorityListId:
                    localAuthority = selected
                case businessTypeListId:
                    businessType = selected
                case scottishRatingListId:
                    scottishRating = selected
                default:
                    break
                }
            }
        }
    }
    
    var ratingValue : String? {
        didSet {
            ratingsCell.detailTextLabel?.text = ratingValue
        }
    }
    var ratingOperator : String? {
        didSet {
            comparisonCell.detailTextLabel?.text = ratingOperator
        }
    }
    var localAuthority : String? {
        didSet {
            localAuthorityCell.detailTextLabel?.text = localAuthority
        }
    }
    var businessType : String? {
        didSet{
            businessTypeCell.detailTextLabel?.text = businessType
        }
    }
    var scottishRating : String? {
        didSet{
            scottishRatingCell.detailTextLabel?.text = scottishRating
        }
    }
    
    let segueSearchId = "segueAdvancedSearch"
    let segueSelectRating = "segueRatingsValue"
    let segueSelectOperator = "segueRatingsOperator"
    let segueLocalAuthority = "segueLocalAuthority"
    let segueBusinessType = "segueBusinessType"
    let segueScottishRating = "segueScottishRating"
    let ratingValueListId = 0
    let ratingOperatorListId = 1
    let localAuthorityListId = 2
    let businessTypeListId = 3
    let scottishRatingListId = 4
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        businessNameTextField.delegate = self
        placeNameTextField.delegate = self
    }
//    override func viewDidAppear(_ animated: Bool) {
//        businessNameTextField.becomeFirstResponder()
//    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === businessNameTextField {
            businessNameTextField.resignFirstResponder()
            placeNameTextField.becomeFirstResponder()
        } else if textField === placeNameTextField {
            placeNameTextField.resignFirstResponder()
            performSegue(withIdentifier: segueSearchId, sender: self)
        }
        return true
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case segueSearchId:
            let query = createQuery()
            MainModel.sharedInstance.findEstablishments(query: query)
        case segueSelectRating:
            if let vc = segue.destination as? ListViewController {
                vc.listItems = FoodHygieneAPI.ratingsValues
                let selected = ratingValue ?? FoodHygieneAPI.ratingsValues[0]
                vc.selectedItem = selected
                vc.id = ratingValueListId
                vc.title = "Rating"
            }
        case segueSelectOperator:
            if let vc = segue.destination as? ListViewController {
                vc.listItems = FoodHygieneAPI.ratingsOperators
                let selected = ratingValue ?? FoodHygieneAPI.ratingsOperators[0]
                vc.selectedItem = selected
                vc.id = ratingOperatorListId
                vc.title = "Rating Comparison"
            }
        case segueLocalAuthority:
            if let vc = segue.destination as? ListViewController {
                vc.listItems = MainModel.sharedInstance.localAuthorities.map(){$0.name}
                vc.listItems.insert("All", at: 0)
                let selected = localAuthority ?? "All"
                vc.selectedItem = selected
                vc.id = localAuthorityListId
                vc.title = "Local Authority"
            }
        case segueBusinessType:
            if let vc = segue.destination as? ListViewController {
                vc.listItems = Business.businessNames
                let selected = localAuthority ?? vc.listItems[0]
                vc.selectedItem = selected
                vc.id = businessTypeListId
                vc.title = "Business Type"
            }
        case segueScottishRating:
            if let vc = segue.destination as? ListViewController {
                vc.listItems = Rating.scottishRatingNames
                let selected = localAuthority ?? vc.listItems[0]
                vc.selectedItem = selected
                vc.id = scottishRatingListId
                vc.title = "Rating Status"
            }
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
        if let rating = ratingValue {
            query.ratingValue = rating
        }
        if let operatorKey = ratingOperator {
            query.ratingOperator = operatorKey
        }
        if let laName = localAuthority {
            if laName != "All" {
                let la = MainModel.sharedInstance.localAuthorities.first(){
                    $0.name == laName
                }
                query.localAuthorityId = la?.searchCode
            }
        }
        if let busType = businessType {
            if busType != "All"
            {
                let busTypeIndex = Business.businessNames.index(of: busType)
                if let index = busTypeIndex {
                    query.businessType = Business.businessTypes[index]
                }
            }
        }
        if let rating = scottishRating {
            let ratingKey = rating.replacingOccurrences(of: " ", with: "")
            query.ratingValue = ratingKey
        }
        return query
    
    }

}
