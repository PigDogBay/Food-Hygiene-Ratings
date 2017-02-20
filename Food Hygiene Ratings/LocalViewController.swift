//
//  LocalViewController.swift
//  Food Hygiene Ratings
//
//  Created by Mark Bailey on 20/02/2017.
//  Copyright © 2017 MPD Bailey Technology. All rights reserved.
//

import UIKit
import GoogleMobileAds

class LocalViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AppStateChangeObserver {

    
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var tableView: UITableView!
    

    private let cellId = "establishmentCell"
    private var model : MainModel {
        get { return MainModel.sharedInstance}
    }
    private var groupedEstablishments : [Int : [Establishment]]!
    private var sortedBusinessTypes : [Int]!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bannerView.adUnitID = Ads.localBannerAdId
        bannerView.rootViewController = self
        bannerView.load(Ads.createRequest())
        tableView.dataSource = self
        tableView.delegate = self
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

    func numberOfSections(in tableView: UITableView) -> Int {
        if (model.state == .loaded){
            return groupedEstablishments.keys.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (model.state == .loaded){
            let businessTypeId = sortedBusinessTypes[section]
            return groupedEstablishments[businessTypeId]!.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (model.state == .loaded){
            let businessTypeId = sortedBusinessTypes[section]
            let group = groupedEstablishments[businessTypeId]!
            return group[0].business.type
        }
        return ""
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        let businessTypeId = sortedBusinessTypes[indexPath.section]
        let est = groupedEstablishments[businessTypeId]![indexPath.row]
        cell.textLabel?.text = est.business.name
        cell.detailTextLabel?.text = String(format: "%.1f miles", est.distance)
        cell.imageView?.image = UIImage(named: est.rating.getIconName())
        cell.tag = est.business.fhrsId
        return cell
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        
        if (model.state == .loaded && sortedBusinessTypes != nil){
            return (1 ... sortedBusinessTypes.count).map(){"\($0)"}
        }
        return nil
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "segueDetails" {
            if let detailsVC = segue.destination as? DetailsViewController {
                if let indexPath = tableView.indexPathForSelectedRow {
                    let businessTypeId = sortedBusinessTypes[indexPath.section]
                    let est = groupedEstablishments[businessTypeId]![indexPath.row]
                    detailsVC.establishment = est
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
            self.groupedEstablishments = DataProcessing.createDictionary(fromArray: model.localEstablishments)
            self.sortedBusinessTypes = DataProcessing.createSortedIndex(fromDictionary: self.groupedEstablishments)
            OperationQueue.main.addOperation {
                self.tableView.reloadData()
            }
        case .error:
            print("state: error")
        }
    }
}
