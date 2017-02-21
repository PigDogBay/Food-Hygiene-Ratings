//
//  DetailsViewController.swift
//  Food Hygiene Ratings
//
//  Created by Mark Bailey on 13/02/2017.
//  Copyright © 2017 MPD Bailey Technology. All rights reserved.
//

import UIKit
import MapKit
import GoogleMobileAds
import CoreLocation

class DetailsViewController: UIViewController, MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate {

    
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var adBanner: GADBannerView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func shareActionClicked(_ sender: UIBarButtonItem) {
    }
    
    private static let dateFormatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    let mapRadius : CLLocationDistance = 500
    var establishment : Establishment!
    
    
    //Table structure
    fileprivate let SECTION_RATING = 0
    fileprivate let SECTION_SCORES = 1
    fileprivate let SECTION_ADDRESS = 2
    fileprivate let SECTION_LOCAL_AUTHORITY = 3
    fileprivate let SECTION_COUNT = 4
    
    fileprivate let ROW_RATING_TITLE = 0
    fileprivate let ROW_RATING_LOGO = 1
    fileprivate let ROW_RATING_COUNT = 2
    
    fileprivate let ROW_SCORES_HYGIENE = 0
    fileprivate let ROW_SCORES_MANAGEMENT = 1
    fileprivate let ROW_SCORES_STRUCTURAL = 2
    fileprivate let ROW_SCORES_COUNT = 3
    
    fileprivate let ROW_LA_NAME = 0
    fileprivate let ROW_LA_EMAIL = 1
    fileprivate let ROW_LA_WEBSITE = 2
    fileprivate let ROW_LA_COUNT = 3

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBar.title = establishment.business.name
        adBanner.adUnitID = Ads.bannerAdId
        adBanner.rootViewController = self
        adBanner.load(Ads.createRequest())
        tableView.dataSource = self
        tableView.delegate = self
        setUpMap()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        //only show scores if there is a rating (TO DO do scotland have scores?)
//        return establishment.rating.hasRating() ?  SECTION_COUNT : SECTION_COUNT - 1
        return SECTION_COUNT
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case SECTION_RATING:
            switch indexPath.row {
            case ROW_RATING_LOGO:
                return 55
            default:
                return 44
            }
        case SECTION_ADDRESS:
            return 26
        default:
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case SECTION_RATING:
            return ROW_RATING_COUNT
        case SECTION_SCORES:
            return ROW_SCORES_COUNT
        case SECTION_ADDRESS:
            return establishment.address.address.count
        case SECTION_LOCAL_AUTHORITY:
            return ROW_LA_COUNT
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case SECTION_RATING:
            return ""
        case SECTION_SCORES:
            return "Hazard Points"
        case SECTION_ADDRESS:
            return "Business Address"
        case SECTION_LOCAL_AUTHORITY:
            return "Local Authority"
        default:
            return ""
        }
    }
    


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = getCellId(indexPath: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as UITableViewCell
        
        switch indexPath.section {
        case SECTION_RATING:
            switch indexPath.row {
            case ROW_RATING_TITLE:
                cell.textLabel?.text = establishment.business.name
                cell.detailTextLabel?.text = establishment.business.type
            case ROW_RATING_LOGO:
                if let ratingsCell = cell as? RatingsLogoCell{
                    let date = DetailsViewController.dateFormatter.string(from: establishment.rating.awardedDate)
                    //To do logic for pending/exempt - not applicable
                    if !establishment.rating.hasRating(){
                        ratingsCell.subTitle.text = ""
                        ratingsCell.titleLabel.text = ""
                    } else if establishment.rating.newRatingPending{
                        ratingsCell.subTitle.text = "\(date) - new rating pending"
                        ratingsCell.titleLabel.text = "Date Awarded"
                    } else {
                        ratingsCell.subTitle.text = "\(date)"
                        ratingsCell.titleLabel.text = "Date Awarded"
                    }
                    ratingsCell.ratingLogo.image = UIImage(named: establishment.rating.ratingsKey)
                }
            default:
                break
            }
        case SECTION_SCORES:
            switch indexPath.row {
            case ROW_SCORES_HYGIENE:
                cell.textLabel?.text = "Hygiene: \(establishment.rating.scores.hygiene)"
                cell.detailTextLabel?.text = establishment.rating.scores.getHygieneDescription()
                cell.imageView?.image = UIImage(named: establishment.rating.scores.getHygieneIconName())
            case ROW_SCORES_MANAGEMENT:
                cell.textLabel?.text = "Management: \(establishment.rating.scores.confidenceInManagement)"
                cell.detailTextLabel?.text = establishment.rating.scores.getManagementDescription()
                cell.imageView?.image = UIImage(named: establishment.rating.scores.getManagementIconName())
            case ROW_SCORES_STRUCTURAL:
                cell.textLabel?.text = "Structural: \(establishment.rating.scores.structural)"
                cell.detailTextLabel?.text = establishment.rating.scores.getStructuralDescription()
                cell.imageView?.image = UIImage(named: establishment.rating.scores.getStructuralIconName())
            default:
                break
            }
            break
        case SECTION_ADDRESS:
            cell.textLabel?.text = establishment.address.address[indexPath.row]
        case SECTION_LOCAL_AUTHORITY:
            switch indexPath.row{
            case ROW_LA_NAME:
                cell.textLabel?.text = establishment.localAuthority.name
                cell.imageView?.image = UIImage(named: "iconAuthority")
            case ROW_LA_EMAIL:
                cell.textLabel?.text = establishment.localAuthority.email
                cell.imageView?.image = UIImage(named: "iconEmail")
            case ROW_LA_WEBSITE:
                cell.textLabel?.text = establishment.localAuthority.web
                cell.imageView?.image = UIImage(named: "iconWebpage")
            default:
                break
            }
            break
        default:
            break
        }
        
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case SECTION_SCORES:
            switch indexPath.row
            {
            case ROW_SCORES_HYGIENE:
                showAlert(title: Scores.hygienicTitle, msg: Scores.hygienicDescription)
            case ROW_SCORES_STRUCTURAL:
                showAlert(title: Scores.structuralTitle, msg: Scores.structuralDescription)
            case ROW_SCORES_MANAGEMENT:
                showAlert(title: Scores.managementTitle, msg: Scores.managementDescription)
            default:
                return
            }
        default:
            return
        }
    }
    
    fileprivate func getCellId(indexPath : IndexPath) -> String {
        switch indexPath.section {
        case SECTION_RATING:
            switch indexPath.row {
            case ROW_RATING_TITLE:
                return "cellSubtitle"
            case ROW_RATING_LOGO:
                return "cellRatingsLogo"
            default:
                return "cellBasic"
            }
        case SECTION_SCORES:
            return "cellScore"
        default:
            return "cellBasic"
        }
    }
    
    
    func setUpMap(){
        mapView.delegate = self
        
        //Find more accurate co-ordinates for the business
        let address = "\(establishment.address.line1),\(establishment.address.line2),\(establishment.address.line3),\(establishment.address.line4),\(establishment.address.postcode)"
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) {
            (placemarks, error) -> Void in
            if error != nil {
                //use FSA co-ordinates
                let coords = self.establishment.address.coordinate
                let coordinates = CLLocationCoordinate2D(latitude: coords.latitude, longitude: coords.longitude)
                self.setMapCoordinates(coordinates: coordinates)
            } else if let placemark = placemarks?.first {
                self.setMapCoordinates(coordinates: (placemark.location?.coordinate)!)
            }
        }
    }
    
    func setMapCoordinates(coordinates : CLLocationCoordinate2D){
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinates ,mapRadius * 2.0, mapRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
        let mapMarker = MapMarker(establishment: establishment, coordinates : coordinates)
        mapView.addAnnotation(mapMarker)
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? MapMarker {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
                as? MKPinAnnotationView { // 2
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = false
                view.calloutOffset = CGPoint(x: -5, y: 5)
            }
            view.pinTintColor = annotation.color
            return view
        }
        return nil
    }
    fileprivate func showAlert(title: String, msg : String)
    {
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        let controller = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        controller.addAction(action)
        self.present(controller, animated: true, completion: nil)
    }
    
}
