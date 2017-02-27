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
    let segueSearchId = "segueAdvancedSearch"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        
        businessNameTextField.delegate = self
        placeNameTextField.delegate = self
    }
    override func viewDidAppear(_ animated: Bool) {
        businessNameTextField.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

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
    
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueSearchId {
            let query = createQuery()
            MainModel.sharedInstance.findEstablishments(query: query)
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
