//
//  MBPlace.swift
//  Food Hygiene Ratings
//
//  Created by Mark Bailey on 20/09/2018.
//  Copyright © 2018 MPD Bailey Technology. All rights reserved.
//

import Foundation
import GooglePlaces

protocol IPlaceImage {
    var attribution : String {get}
    var index : Int {get}
    func fetchBitmap()
}

struct MBPlace {
    let id : String
    let telephone : String
    let web : String
    let images : [IPlaceImage]
}
