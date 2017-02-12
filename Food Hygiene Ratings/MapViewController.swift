//
//  MapViewController.swift
//  Food Hygiene Ratings
//
//  Created by Mark Bailey on 09/02/2017.
//  Copyright © 2017 MPD Bailey Technology. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, AppStateChangeObserver {

    @IBOutlet weak var mapView: MKMapView!
    @IBAction func refreshClicked(_ sender: UIBarButtonItem) {
        let model = MainModel.sharedInstance
        if model.canFindEstablishments(){
            let mapCentre = mapView.region.center
            model.location = Coordinate(longitude: mapCentre.longitude, latitude: mapCentre.latitude)
            model.findEstablishments()
        }
    }

    //Just over a mile radius
    let mapRadius : CLLocationDistance = 1000

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        mapView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let model = MainModel.sharedInstance
        modelToView(state: model.state)
        model.addObserver("mapView", observer: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let model = MainModel.sharedInstance
        model.removeObserver("mapView")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? MapMarker {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
                as? MKPinAnnotationView { // 2
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                // 3
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            }
            view.pinTintColor = annotation.color
            return view
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let annotation = view.annotation as? MapMarker {
            showDetails(fhrsId: annotation.fhrsId!)
        }
    }
    func showDetails(fhrsId : Int) {
        if let navCtrl = self.navigationController
        {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let webVC = storyboard.instantiateViewController(withIdentifier: "webScene") as? WebViewController {
                webVC.navTitle = "Web"
                webVC.url = FoodHygieneAPI.createBusinessUrl(fhrsId: fhrsId)
                navCtrl.pushViewController(webVC, animated: true)
            }
        }
    }
    
    
    internal func stateChanged(_ newState: AppState) {
        OperationQueue.main.addOperation {
            self.modelToView(state: newState)
        }
    }
    
    func modelToView(state : AppState){
        switch state {
        case .ready:
            break
        case .requestingLocationAuthorization:
            break
        case .locating:
            break
        case .foundLocation:
            centreMap()
        case .notAuthorizedForLocating:
            break
        case .errorLocating:
            break
        case .loading:
            break
        case .loaded:
            self.loadedState()
        case .error:
            break
        }
        
    }
    
    func centreMap(){
        let model = MainModel.sharedInstance
        let coordinates = CLLocationCoordinate2D(latitude: model.location.latitude, longitude: model.location.longitude)
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinates,mapRadius * 2.0, mapRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func loadedState(){
        centreMap()
        let markers = MainModel.sharedInstance.localEstablishments.map(){
            return MapMarker(establishment: $0)
        }
        self.mapView.addAnnotations(markers)
        
    }
    
}
