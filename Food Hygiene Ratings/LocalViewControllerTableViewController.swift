//
//  LocalViewControllerTableViewController.swift
//  Food Hygiene Ratings
//
//  Created by Mark Bailey on 09/02/2017.
//  Copyright © 2017 MPD Bailey Technology. All rights reserved.
//

import UIKit

class LocalViewControllerTableViewController: UITableViewController, AppStateChangeObserver {

    private let cellId = "establishmentCell"
    private var model : MainModel {
        get { return MainModel.sharedInstance}
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let model = MainModel.sharedInstance
        stateChanged(model.state)
        model.addObserver("localView", observer: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let model = MainModel.sharedInstance
        model.removeObserver("localView")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (model.state == .loaded){
            return model.localEstablishments.count
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        let est = model.localEstablishments[indexPath.row]
        cell.textLabel?.text = est.business.name
        cell.detailTextLabel?.text = est.business.type
        cell.imageView?.image = UIImage(named: est.rating.getIconName())
        cell.tag = est.business.fhrsId
        return cell
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "segueWeb" {
            if let webVC = segue.destination as? WebViewController {
                if let indexPath = tableView.indexPathForSelectedRow {
                    let est = model.localEstablishments[indexPath.row]
                    webVC.navTitle = "FSA Web Page"
                    webVC.url = FoodHygieneAPI.createBusinessUrl(fhrsId: est.business.fhrsId)
                }
            }
        }
        
    }

    // MARK: - AppStateChangeObserver

    internal func stateChanged(_ newState: AppState) {
        let model = MainModel.sharedInstance
        switch newState {
        case .ready:
            print("state: Ready")
        case .requestingLocationAuthorization:
            print("state: requesting location authorization")
        case .locating:
            print("state: locating")
        case .foundLocation:
            print("state: found location \(model.location.latitude) \(model.location.longitude)")
        case .notAuthorizedForLocating:
            print("state: not authorized for locating")
        case .errorLocating:
            print("state: error locating")
        case .loading:
            print("state: loading")
        case .loaded:
            print("state: loaded")
            OperationQueue.main.addOperation {
                self.tableView.reloadData()
            }
        case .error:
            print("state: error")
        }
    }
    
}
