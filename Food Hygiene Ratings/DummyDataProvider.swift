//
//  DummyDataProvider.swift
//  Food Hygiene Ratings
//
//  Created by Mark Bailey on 21/02/2017.
//  Copyright © 2017 MPD Bailey Technology. All rights reserved.
//

import Foundation

class DummyDataProvider : IDataProvider {
    
    var model : MainModel!
    
    //Stoke
//    let latitude = 52.984120
//    let longitude = -2.204094
    
    //Glasgow
    let latitude = 55.857455
    let longitude = -4.248
    
    
    func findLocalEstablishments() {
        self.model.changeState(.locating)
        model.location = Coordinate(longitude: longitude, latitude: latitude)
        self.model.changeState(.foundLocation)
        fetchEstablishments(query : Query(longitude: longitude, latitude: latitude, radiusInMiles: 1))

    }
    func fetchEstablishments(query : Query){
        self.model.changeState(.loading)
        let url = Bundle.main.url(forResource: "glasgow", withExtension: "json")
        let data = try! Data(contentsOf: url!)
        let estResult = FoodHygieneAPI.establishments(fromJSON: data)
        
        switch estResult {
        case let .success(results):
            self.model.setResults(establishments: results)
            self.model.changeState(.loaded)
        case let .failure(error):
            self.model.error = error
            self.model.changeState(.error)
        }
    }
    
    func stop(){
    }

}
