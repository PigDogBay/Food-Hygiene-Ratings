//
//  LocalViewController.swift
//  Food Hygiene Ratings
//
//  Created by Mark Bailey on 20/02/2017.
//  Copyright © 2017 MPD Bailey Technology. All rights reserved.
//

import UIKit
import GoogleMobileAds

class LocalViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating, UISearchBarDelegate, AppStateChangeObserver {

    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingLabel: UILabel!

    var searchController : UISearchController!
    

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
        tableView.keyboardDismissMode = .onDrag
        
        loadingIndicator.startAnimating()
        loadingLabel.isHidden=false
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.scopeButtonTitles = ["All","5", "4", "3", "2", "1", "0"]
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
    }
    
    deinit {
        //Will get a warning if searchController is not removed
        //http://stackoverflow.com/questions/32282401/attempting-to-load-the-view-of-a-view-controller-while-it-is-deallocating-uis
        if let superView = searchController.view.superview
        {
            superView.removeFromSuperview()
        }
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
    
    fileprivate func loadTableData() {
        if (model.state == .loaded) {
            if searchController.isActive {
                let establishments = model.results
                let searchText = searchController.searchBar.text!
                let scopeFiltered = DataProcessing.filter(establishments: establishments, filter: getSearchFilter())
                let filtered = DataProcessing.filter(establishments: scopeFiltered, containing: searchText	)
                self.groupedEstablishments = DataProcessing.createDictionary(fromArray: filtered)
                self.sortedBusinessTypes = DataProcessing.createSortedIndex(fromDictionary: self.groupedEstablishments)
                
            } else {
                self.groupedEstablishments = DataProcessing.createDictionary(fromArray: model.results)
                self.sortedBusinessTypes = DataProcessing.createSortedIndex(fromDictionary: self.groupedEstablishments)
            }
            tableView.reloadData()
        }
    }
    func getSearchFilter() -> SearchFilter {
        switch searchController.searchBar.selectedScopeButtonIndex {
        case 1:
            return .star5
        case 2:
            return .star4
        case 3:
            return .star3
        case 4:
            return .star2
        case 5:
            return .star1
        case 6:
            return .star0
        default:
            return .all
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        loadTableData()
    }

    func updateSearchResults(for searchController: UISearchController) {
        loadTableData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if (model.state == .loaded && groupedEstablishments != nil){
            return groupedEstablishments.keys.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (model.state == .loaded && sortedBusinessTypes != nil){
            let businessTypeId = sortedBusinessTypes[section]
            return groupedEstablishments[businessTypeId]!.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (model.state == .loaded && sortedBusinessTypes != nil){
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
        cell.detailTextLabel?.text = getDetailsText(establishment: est)
        cell.imageView?.image = UIImage(named: est.rating.getIconName())
        cell.tag = est.business.fhrsId
        return cell
    }
    
    func getDetailsText(establishment : Establishment) -> String {
        switch MainModel.sharedInstance.searchType {
        case .local:
            return String(format: "%.1f miles", establishment.distance)
        default:
            return establishment.address.flatten()
        }
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        
        if (model.state == .loaded && sortedBusinessTypes != nil && sortedBusinessTypes.count>0){
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
            OperationQueue.main.addOperation {
                self.loadingIndicator.stopAnimating()
                self.loadingLabel.isHidden=true
                self.showErrorAlert(title: "Authorisation Required", msg: "Please go to Settings, privacy, location and select While Using the App")
            }
        case .errorLocating:
            print("state: error locating")
        case .loading:
            print("state: loading")
        case .loaded:
            print("state: loaded")
            OperationQueue.main.addOperation {
                self.loadingIndicator.stopAnimating()
                self.loadingLabel.isHidden=true
                if model.results.count>0 {
                    self.loadTableData()
                } else {
                    self.showErrorAlert(title: "No Results", msg: "No matches were found")
                }
            }
        case .error:
            print("state: error")
            OperationQueue.main.addOperation {
                self.loadingIndicator.stopAnimating()
                self.loadingLabel.isHidden=true
                let msg = self.model.error?.localizedDescription ?? "An error occurred, check your internet connection"
                self.showErrorAlert(title: "Error", msg: msg)
            }
        }
    }
    
    fileprivate func showErrorAlert(title: String, msg : String)
    {
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {_ in
            self.navigationController!.popViewController(animated: true)
        })
        let controller = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        controller.addAction(action)
        self.present(controller, animated: true, completion: nil)
    }
    
}
