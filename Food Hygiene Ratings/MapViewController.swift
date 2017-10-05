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

    @IBOutlet weak var bannerContainer: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBAction func refreshClicked(_ sender: UIBarButtonItem) {
        let model = MainModel.sharedInstance
        if model.canFindEstablishments(){
            let mapCentre = mapView.region.center
            model.findEstablishments(longitude: mapCentre.longitude, latitude: mapCentre.latitude)
        }
    }

    //Just over a mile radius
    let mapRadius : CLLocationDistance = 1000
    
    //UK region, co-ordinates found by trial and error
    private let ukregion : MKCoordinateRegion = {
        let coords = CLLocationCoordinate2D(latitude: 55.0, longitude: -3.1)
        let span = MKCoordinateSpan(latitudeDelta: 12, longitudeDelta: 6)
        return MKCoordinateRegionMake(coords, span)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        activityIndicator.startAnimating()
        loadingLabel.isHidden=false
        
        // Do any additional setup after loading the view.
        mapView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let model = MainModel.sharedInstance
        modelToView(state: model.state)
        model.addObserver("mapView", observer: self)
        RootViewController.addAdView(container: bannerContainer)
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
            showEstablishment(establishment: annotation.establishment)
        }
    }
    fileprivate func showEstablishment(establishment : Establishment){
        if let navCtrl = self.navigationController
        {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let detailsVC = storyboard.instantiateViewController(withIdentifier: "establishmentDetailsScene") as? DetailsViewController{
                detailsVC.establishment = establishment
                navCtrl.pushViewController(detailsVC, animated: true)
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
            showActivityIndicator()
        case .requestingLocationAuthorization:
            break
        case .locating:
            break
        case .foundLocation:
            break
        case .notAuthorizedForLocating:
            break
        case .errorLocating:
            hideActivityIndicator()
        case .loading:
            showActivityIndicator()
        case .loaded:
            hideActivityIndicator()
            self.loadedState()
        case .error:
            hideActivityIndicator()
        }
    }
    
    func showActivityIndicator(){
        activityIndicator.startAnimating()
        loadingLabel.isHidden=false
    }
    func hideActivityIndicator(){
        activityIndicator.stopAnimating()
        loadingLabel.isHidden=true
    }
    
   
    func loadedState(){
        let model = MainModel.sharedInstance

        //remove old annotations
        self.mapView.removeAnnotations(self.mapView.annotations)
        
        let markers = model.results
            .filter(){$0.address.coordinate.isWithinUK()}
            .map(){MapMarker(establishment: $0)}
        
        if markers.count==0 {
            mapView.setRegion(ukregion, animated: true)
            return
        }

        switch model.searchType {
        case .advanced:
            self.mapView.showAnnotations(markers, animated: true)
        case .map:
            self.mapView.showAnnotations(markers, animated: true)
        case .local:
            self.mapView.addAnnotations(markers)
            //show map centred on location in the model
            let coords2d = CLLocationCoordinate2D(latitude: model.location.latitude, longitude: model.location.longitude)
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(coords2d,mapRadius * 2.0, mapRadius * 2.0)
            mapView.setRegion(coordinateRegion, animated: true)
        }
        
    }
    
}
