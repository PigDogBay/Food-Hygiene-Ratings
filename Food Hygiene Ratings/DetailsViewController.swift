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

class DetailsViewController: UIViewController, MKMapViewDelegate {

    
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var adBanner: GADBannerView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func shareActionClicked(_ sender: UIBarButtonItem) {
    }
    
    static let dateFormatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    let mapRadius : CLLocationDistance = 500
    var establishment : Establishment!
    var tableDelegate : UITableViewDataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBar.title = establishment.business.name
        adBanner.adUnitID = Ads.bannerAdId
        adBanner.rootViewController = self
        adBanner.load(Ads.createRequest())

        let detailsTableDel = DetailsTableDelegate(establishment: self.establishment, viewController: self)
        self.tableDelegate = detailsTableDel
        tableView.dataSource = detailsTableDel
        tableView.delegate = detailsTableDel
        
        setUpMap()
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
