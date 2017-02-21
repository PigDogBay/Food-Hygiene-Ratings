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
            self.model.changeState(.requestingLocationAuthorization)
            self.locationManager.requestWhenInUseAuthorization()
        } else if authStatus == .denied {
            self.model.changeState(.notAuthorizedForLocating)
            return
        } else {
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
                fetchEstablishments()
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
    
    func fetchEstablishments(){
        self.model.changeState(.loading)
        self.webSerice.fetchEstablishments(longitude: model.location.longitude, latitude: model.location.latitude, radiusInMiles: model.searchRadius){
            (result) in
            switch result {
            case let .failure(error):
                self.model.error = error
                self.model.changeState(.error)
            case let .success(establishments):
                self.model.setLocalEstablishments(establishments: establishments)
                self.model.changeState(.loaded)
            }
        }
    }
}
