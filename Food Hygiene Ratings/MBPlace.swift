//
//  MBPlace.swift
//  Food Hygiene Ratings
//
//  Created by Mark Bailey on 20/09/2018.
//  Copyright © 2018 MPD Bailey Technology. All rights reserved.
//

import Foundation
import UIKit

enum FetchStatus {
    case uninitialized, fetching, ready, error
}
protocol IPlaceImage {
    var attribution : String {get}
    var observableStatus : ObservableProperty<FetchStatus> {get}
    var image : UIImage? {get}
    var index : Int {get}
    func fetchBitmap()
}

protocol IPlaceFetcher {
    var observableStatus : ObservableProperty<FetchStatus> {get}
    var mbPlace : MBPlace? {get}
    func fetch(establishment : Establishment)
}

struct MBPlace {
    let id : String
    let telephone : String
    let web : String
    let images : [IPlaceImage]
}


