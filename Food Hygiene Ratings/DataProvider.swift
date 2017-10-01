//
//  DataProvider.swift
//  Food Hygiene Ratings
//
//  Created by Mark Bailey on 10/02/2017.
//  Copyright © 2017 MPD Bailey Technology. All rights reserved.
//

import Foundation
import CoreLocation


class DataProvider : NSObject, IDataProvider, CLLocationManagerDelegate{

    var model: MainModel!
    
    var locationManager = CLLocationManager()
    var webSerice = WebServiceClient()
    
    
    override init() {
        super.init()
        locationManager.delegate = self
    }

    func findLocalEstablishments() {
        let authStatus = CLLocationManager.authorizationStatus()
        if authStatus == .notDetermined {
            Logging.append(msg: "Location authority is not determined")
            self.model.changeState(.requestingLocationAuthorization)
            self.locationManager.requestWhenInUseAuthorization()
        } else if authStatus == .denied {
            Logging.append(msg: "Location authority is denied")
            self.model.changeState(.notAuthorizedForLocating)
            return
        } else {
            Logging.append(msg: "Locating...")
            self.model.changeState(.locating)
            locationManager.distanceFilter = kCLDistanceFilterNone
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if model.state == .requestingLocationAuthorization{
            let authStatus = CLLocationManager.authorizationStatus()
            if authStatus == .authorizedWhenInUse || authStatus == .authorizedAlways {
                self.model.changeState(.locating)
                locationManager.distanceFilter = kCLDistanceFilterNone
                locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
                locationManager.startUpdatingLocation()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.count>0 {
            manager.stopUpdatingLocation()
            if model.state == .locating {
                self.model.changeState(.foundLocation)
                self.model.location = Coordinate(longitude: locations[0].coordinate.longitude, latitude: locations[0].coordinate.latitude)
                let query = Query(longitude: model.location.longitude, latitude: model.location.latitude, radiusInMiles: model.searchRadius)
                fetchEstablishments(query: query)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if CLLocationManager.authorizationStatus() == .denied {
            self.model.changeState(.notAuthorizedForLocating)
        } else {
            self.model.changeState(.errorLocating)
        }
    }
    
    func fetchEstablishments(query : Query) {
        self.model.changeState(.loading)
        let url = FoodHygieneAPI.createEstablishmentsUrl(query: query)
        Logging.append(msg: "Query url: \(url)")
        self.webSerice.fetchEstablishments(url: url){
            (result) in
            switch result {
            case let .failure(error):
                Logging.append(msg: "fetch failed \(error)")
                self.model.error = error
                self.model.changeState(.error)
            case let .success(establishments):
                Logging.append(msg: "fetch success found \(establishments.count) establishments")
                self.model.setResults(establishments: establishments)
                self.model.changeState(.loaded)
            }
        }
        
    }

}
