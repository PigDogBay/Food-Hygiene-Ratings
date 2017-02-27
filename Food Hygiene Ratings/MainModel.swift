//
//  MainModel.swift
//  Food Hygiene Ratings
//
//  Created by Mark Bailey on 10/02/2017.
//  Copyright © 2017 MPD Bailey Technology. All rights reserved.
//

import Foundation

enum AppState {
    case ready
    case requestingLocationAuthorization
    case locating
    case foundLocation
    case notAuthorizedForLocating
    case errorLocating
    case loading
    case loaded
    case error
}

protocol AppStateChangeObserver
{
    func stateChanged(_ newState : AppState)
}
class MainModel {

    //Use the singleton within the application
    static let sharedInstance = MainModel()

    var state : AppState = .ready
    var localEstablishments = [Establishment]()
    var location : Coordinate = Coordinate(longitude: -2.204094, latitude: 52.984120)
    var searchRadius : Int = 1
    var observersDictionary : [String : AppStateChangeObserver] = [:]
    
    var dataProvider : IDataProvider!
    var error : Error?

    func addObserver(_ name: String, observer : AppStateChangeObserver)
    {
        observersDictionary[name]=observer
    }
    
    func removeObserver(_ name: String)
    {
        observersDictionary.removeValue(forKey: name)
    }
    func changeState(_ newState: AppState)
    {
        self.state = newState
        for (_,observer) in observersDictionary
        {
            observer.stateChanged(state)
        }
    }
    
    func canFindLocalEstablishments() -> Bool {
        switch self.state {
        case .ready:
            return true
        case .requestingLocationAuthorization:
            return false
        case .locating:
            return false
        case .foundLocation:
            return false
        case .notAuthorizedForLocating:
            return true
        case .errorLocating:
            return true
        case .loading:
            return false
        case .loaded:
            return true
        case .error:
            return true
        }
    }
    func canFindEstablishments() -> Bool {
        switch self.state {
        case .ready:
            return true
        case .requestingLocationAuthorization:
            return false
        case .locating:
            return false
        case .foundLocation:
            return false
        case .notAuthorizedForLocating:
            return true
        case .errorLocating:
            return true
        case .loading:
            return false
        case .loaded:
            return true
        case .error:
            return true
        }
    }
    
    func setLocalEstablishments(establishments : [Establishment]) {
        let sorted = establishments.sorted(by: {$0.distance < $1.distance})
        self.localEstablishments.removeAll()
        self.localEstablishments.append(contentsOf: sorted)
    }
    
    func findLocalEstablishments(){
        if canFindLocalEstablishments(){
            dataProvider.findLocalEstablishments()
        }
    }
    
    func findEstablishments(longitude: Double, latitude: Double){
        if canFindEstablishments(){
            self.location = Coordinate(longitude: longitude, latitude: latitude)
            let query = Query(longitude: longitude, latitude: latitude, radiusInMiles: searchRadius)
            dataProvider.fetchEstablishments(query: query)
        }
    }
    func findEstablishments(query : Query){
        if canFindEstablishments(){
            dataProvider.fetchEstablishments(query: query)
        }
        
    }
    
}
