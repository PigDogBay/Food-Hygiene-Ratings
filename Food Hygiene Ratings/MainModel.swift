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

enum SearchType {
    case local
    case advanced
    case map
}

struct Coordinate {
    let ukEast = 1.46
    let ukWest = -8.638
    let ukNorth = 60.51
    let ukSouth = 49.53
    
    let longitude : Double
    let latitude : Double

    func isWithinUK()->Bool {
       return latitude>=ukSouth && latitude<=ukNorth && longitude>=ukWest && longitude<=ukEast
    }
}

protocol AppStateChangeObserver
{
    func stateChanged(_ newState : AppState)
}
class MainModel {

    //Use the singleton within the application
    static let sharedInstance = MainModel()

    static let appId = "id1213783338"

    class func getAppWebUrl()->String
    {
        return "https://itunes.apple.com/app/id1213783338"
    }
    class func getUserGuideUrl()->String
    {
        return "https://pigdogbay.blogspot.co.uk/2017/10/food-hygiene-ratings-ios-guide.html"
    }
    class func getPrivacyPolicyUrl()->String
    {
        return "https://pigdogbay.blogspot.com/2018/06/privacy-policy-food-hygiene-ratings.html"
    }

    let ratings = Ratings(appId: appId)
    
    var state : AppState = .ready
    var results = [Establishment]()
    var location : Coordinate = Coordinate(longitude: -2.204094, latitude: 52.984120)
    var searchRadius : Int {
        get {return Settings.searchRadius}
    }
    var searchType = SearchType.local
    
    var observersDictionary : [String : AppStateChangeObserver] = [:]
    
    var dataProvider : IDataProvider!
    var error : Error?
    
    lazy var localAuthorities : [LocalAuthority] = {
        let url = Bundle.main.url(forResource: "authorities", withExtension: "json")
        let data = try! Data(contentsOf: url!)
        let estResult = FoodHygieneAPI.authorities(fromJSON: data)
        switch estResult {
            case let .success(results):
                return results
        default:
            return [LocalAuthority]()
        }
    }()

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
    
    func setResults(establishments : [Establishment]) {
        self.results.removeAll()
        if searchType == .local || searchType == .map{
            let sorted = establishments.sorted(by: {$0.distance < $1.distance})
            self.results.append(contentsOf: sorted)
        } else {
            self.results.append(contentsOf: establishments)
        }
    }
    
    func findLocalEstablishments(){
        if canFindLocalEstablishments(){
            self.searchType = .local
            dataProvider.findLocalEstablishments()
        }
    }
    
    func findEstablishments(longitude: Double, latitude: Double){
        if canFindEstablishments(){
            self.searchType = .map
            self.location = Coordinate(longitude: longitude, latitude: latitude)
            let query = Query(longitude: longitude, latitude: latitude, radiusInMiles: searchRadius)
            dataProvider.fetchEstablishments(query: query)
        }
    }
    func findEstablishments(query : Query){
        if canFindEstablishments(){
            self.searchType = .advanced
            dataProvider.fetchEstablishments(query: query)
        }
    }
    
    func stop(){
        dataProvider.stop()
        changeState(.ready)
    }
    
}
