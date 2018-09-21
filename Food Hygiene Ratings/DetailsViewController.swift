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
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func shareActionClicked(_ sender: UIBarButtonItem) {
        let firstActivityItem = Formatting.format(establishment: establishment)
        let activityViewController : UIActivityViewController = UIActivityViewController(activityItems: [firstActivityItem], applicationActivities: nil)
        //For iPads need to anchor the popover to the right bar button, crashes if not set
        if let ppc = activityViewController.popoverPresentationController {
            ppc.barButtonItem = navBar.rightBarButtonItem
        }
        
        self.present(activityViewController, animated: true, completion: nil)
    }
   
    let mapRadius : CLLocationDistance = 500
    var establishment : Establishment!
    var tableDelegate : UITableViewDataSource!
    var placeFetcher : IPlaceFetcher = GooglePlaceFetcher()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBar.title = establishment.business.name

        let detailsTableDel = DetailsTableDelegate(establishment: self.establishment, viewController: self)
        self.tableDelegate = detailsTableDel
        tableView.dataSource = detailsTableDel
        tableView.delegate = detailsTableDel
        detailsTableDel.placeFetcher = self.placeFetcher

        bannerView.adSize = kGADAdSizeBanner
        bannerView.adUnitID = Ads.bannerAdId
        bannerView.rootViewController = self
        bannerView.load(Ads.createRequest())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        placeFetcher.observableStatus.addObserver(named: "detailsVC", observer: fetchStatusUpdate)
        placeFetcher.fetch(establishment: establishment)
    }
    override func viewWillDisappear(_ animated: Bool) {
        placeFetcher.observableStatus.removeObserver(named: "detailsVC")
        if let images = placeFetcher.mbPlace?.images {
            for im in images{
                im.observableStatus.removeObserver(named: "detailsVC")
            }
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
                if coords.isWithinUK(){
                    let coordinates = CLLocationCoordinate2D(latitude: coords.latitude, longitude: coords.longitude)
                    self.setMapCoordinates(coordinates: coordinates)
                }
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
    
    func fetchStatusUpdate(status : FetchStatus){
        switch status {
        case .uninitialized:
            break
        case .fetching:
            break
        case .ready:
            if let images = placeFetcher.mbPlace?.images {
                for im in images{
                    im.observableStatus.addObserver(named: "detailsVC", observer: fetchImageStatusUpdate)
                }
            }
            break
        case .error:
            break
        }
        tableView.reloadData()
    }
    func fetchImageStatusUpdate(status : FetchStatus){
        print("Image update \(status)")
        tableView.reloadData()
    }
}
