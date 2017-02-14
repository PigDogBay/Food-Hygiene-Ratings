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

class DetailsViewController: UIViewController, MKMapViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var adBanner: GADBannerView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func shareActionClicked(_ sender: UIBarButtonItem) {
    }
    
    let mapRadius : CLLocationDistance = 500
    var establishment : Establishment!
    
    
    //Table structure
    fileprivate let SECTION_BUSINESS = 0
    fileprivate let SECTION_RATING = 1
    fileprivate let SECTION_ADDRESS = 2
    fileprivate let SECTION_LOCAL_AUTHORITY = 3
    fileprivate let SECTION_COUNT = 4
    
    fileprivate let ROW_BUSINESS_TITLE = 0
    fileprivate let ROW_BUSINESS_COUNT = 1
    
    fileprivate let ROW_RATING_RATING = 0
    fileprivate let ROW_RATING_DATE = 1
    fileprivate let ROW_RATING_PENDING = 2
    fileprivate let ROW_RATING_HYGIENE_SCORE = 3
    fileprivate let ROW_RATING_MANAGEMENT_SCORE = 4
    fileprivate let ROW_RATING_STRUCTURAL_SCORE = 5
    fileprivate let ROW_RATING_COUNT = 6
    
    fileprivate let ROW_ADDRESS_LINE1 = 0
    fileprivate let ROW_ADDRESS_LINE2 = 1
    fileprivate let ROW_ADDRESS_LINE3 = 2
    fileprivate let ROW_ADDRESS_LINE4 = 3
    fileprivate let ROW_ADDRESS_POSTCODE = 4
    fileprivate let ROW_ADDRESS_COUNT = 5

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
        setUpMap()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return SECTION_COUNT
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case SECTION_BUSINESS:
            return ROW_BUSINESS_COUNT
        case SECTION_RATING:
            return ROW_RATING_COUNT
        case SECTION_ADDRESS:
            return ROW_ADDRESS_COUNT
        case SECTION_LOCAL_AUTHORITY:
            return ROW_LA_COUNT
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = getCellId(indexPath: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as UITableViewCell
        
        switch indexPath.section {
        case SECTION_BUSINESS:
            switch indexPath.row {
            case ROW_BUSINESS_TITLE:
                cell.textLabel?.text = establishment.business.name
                cell.detailTextLabel?.text = establishment.business.type
                cell.imageView?.image = UIImage(named: establishment.rating.getIconName())
            default:
                break
            }
        case SECTION_RATING:
            switch indexPath.row {
            case ROW_RATING_RATING:
                cell.textLabel?.text = establishment.rating.ratingString
            case ROW_RATING_DATE:
                cell.textLabel?.text = "\(establishment.rating.awardedDate)"
            case ROW_RATING_PENDING:
                cell.textLabel?.text = "New Rating Pending \(establishment.rating.newRatingPending)"
            case ROW_RATING_HYGIENE_SCORE:
                cell.textLabel?.text = "Hygiene: \(establishment.rating.scores.hygiene)"
            case ROW_RATING_MANAGEMENT_SCORE:
                cell.textLabel?.text = "Management: \(establishment.rating.scores.confidenceInManagement)"
            case ROW_RATING_STRUCTURAL_SCORE:
                cell.textLabel?.text = "Structural: \(establishment.rating.scores.hygiene)"
            default:
                break
            }
            break
        case SECTION_ADDRESS:
            switch indexPath.row {
            case ROW_ADDRESS_LINE1:
                cell.textLabel?.text = establishment.address.line1
            case ROW_ADDRESS_LINE2:
                cell.textLabel?.text = establishment.address.line2
            case ROW_ADDRESS_LINE3:
                cell.textLabel?.text = establishment.address.line3
            case ROW_ADDRESS_LINE4:
                cell.textLabel?.text = establishment.address.line4
            case ROW_ADDRESS_POSTCODE:
                cell.textLabel?.text = establishment.address.postcode
            default:
                break
            }
        case SECTION_LOCAL_AUTHORITY:
            switch indexPath.row{
            case ROW_LA_NAME:
                cell.textLabel?.text = establishment.localAuthority.name
            case ROW_LA_EMAIL:
                cell.textLabel?.text = establishment.localAuthority.email
            case ROW_LA_WEBSITE:
                cell.textLabel?.text = establishment.localAuthority.web
            default:
                break
            }
            break
        default:
            break
        }
        
        
        return cell
    }
    fileprivate func getCellId(indexPath : IndexPath) -> String {
        switch indexPath.section {
        case SECTION_BUSINESS:
            switch indexPath.row {
            case ROW_BUSINESS_TITLE:
                return "cellTitle"
            default:
                return "cellDetails"
            }
        default:
            return "cellDetails"
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

    
}