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
import MessageUI

class DetailsViewController: UIViewController, MKMapViewDelegate, MFMailComposeViewControllerDelegate {

    
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var adBanner: GADBannerView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func shareActionClicked(_ sender: UIBarButtonItem) {
        let firstActivityItem = shareText()
        print(firstActivityItem)
        let activityViewController : UIActivityViewController = UIActivityViewController(activityItems: [firstActivityItem], applicationActivities: nil)
        //For iPads need to anchor the popover to the right bar button, crashes if not set
        if let ppc = activityViewController.popoverPresentationController {
            ppc.barButtonItem = navBar.rightBarButtonItem
        }
        
        self.present(activityViewController, animated: true, completion: nil)
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

        if (establishment.rating.hasRating()){
            let detailsTableDel = DetailsTableDelegate(establishment: self.establishment, viewController: self)
            self.tableDelegate = detailsTableDel
            tableView.dataSource = detailsTableDel
            tableView.delegate = detailsTableDel
        } else {
            let detailsTableDel = NoScoresTableDelegate(establishment: self.establishment, viewController: self)
            self.tableDelegate = detailsTableDel
            tableView.dataSource = detailsTableDel
            tableView.delegate = detailsTableDel
        }
        
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
    // MARK:- MFMailComposeViewControllerDelegate
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?)
    {
        //dismiss on send
        controller.dismiss(animated: true, completion: nil)
    }
    
    
    func shareText() -> String {
        var builder = "Food Hygiene Rating\n\n"
        builder.append("\(establishment.business.name)\n")
        for line in establishment.address.address {
            builder.append(line)
            builder.append("\n")
        }
        builder.append("\nRating: \(establishment.rating.ratingString)\n")
        if establishment.rating.hasRating(){
            builder.append("Awarded: \(DetailsViewController.dateFormatter.string(from: establishment.rating.awardedDate))\n")
            builder.append("Hygiene Points: \(establishment.rating.scores.hygiene)\n")
            builder.append("Management Points: \(establishment.rating.scores.confidenceInManagement)\n")
            builder.append("Structural Points: \(establishment.rating.scores.structural)\n")
        }
        builder.append("\nLocal Authority Details\n")
        builder.append("\(establishment.localAuthority.name)\nEmail: \(establishment.localAuthority.email)\nWebsite: \(establishment.localAuthority.web)\n")
        builder.append("\nFSA Website for this business\n")
        builder.append("\(FoodHygieneAPI.createBusinessUrl(fhrsId: establishment.business.fhrsId).absoluteString)\n")
        return builder
    }
    
    
}
