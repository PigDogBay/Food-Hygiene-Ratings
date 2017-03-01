//
//  Query.swift
//  Food Hygiene Ratings
//
//  Created by Mark Bailey on 25/02/2017.
//  Copyright © 2017 MPD Bailey Technology. All rights reserved.
//

import Foundation

struct Query {
    
    var businessName : String?
    var placeName : String?
    var longitude : Double?
    var latitude : Double?
    var radiusInMiles : Int?
    var ratingValue : String?
    var ratingOperator : String?
    
    init(longitude : Double, latitude: Double, radiusInMiles : Int){
        self.longitude = longitude
        self.latitude = latitude
        self.radiusInMiles = radiusInMiles
    }
    
    init(){
        
    }
    
}
