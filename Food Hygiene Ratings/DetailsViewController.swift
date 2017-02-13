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

class DetailsViewController: UIViewController,MKMapViewDelegate {

    
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var adBanner: GADBannerView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func shareActionClicked(_ sender: UIBarButtonItem) {
    }
    
    let mapRadius : CLLocationDistance = 500
    var establishment : Establishment!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        navBar.title = establishment.business.name
        adBanner.adUnitID = Ads.bannerAdId
        adBanner.rootViewController = self
        adBanner.load(Ads.createRequest())
        setUpMap()
    }
    
    func setUpMap(){
        let coordinates = CLLocationCoordinate2D(latitude: establishment.address.coordinate.latitude, longitude: establishment.address.coordinate.longitude)
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinates,mapRadius * 2.0, mapRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
        let mapMarker = MapMarker(establishment: establishment)
        mapView.addAnnotation(mapMarker)
        mapView.delegate = self
        
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
