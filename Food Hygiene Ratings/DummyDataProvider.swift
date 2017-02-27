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
    let latitude = 52.984120
    let longitude = -2.204094
    
    
    func findLocalEstablishments() {
        self.model.changeState(.locating)
        model.location = Coordinate(longitude: longitude, latitude: latitude)
        self.model.changeState(.foundLocation)
        fetchEstablishments()

    }
    func fetchEstablishments() {
        self.model.changeState(.loading)
        let url = Bundle.main.url(forResource: "stoke", withExtension: "json")
        let data = try! Data(contentsOf: url!)
        let estResult = FoodHygieneAPI.establishments(fromJSON: data)
        
        switch estResult {
        case let .success(results):
            self.model.setLocalEstablishments(establishments: results)
            self.model.changeState(.loaded)
        case let .failure(error):
            self.model.error = error
            self.model.changeState(.error)
        }
    }
    func fetchEstablishments(query : Query){
        fetchEstablishments()
    }

}
