//
//  PlaceFetcherUtils.swift
//  Food Hygiene Ratings
//
//  Created by Mark Bailey on 23/09/2018.
//  Copyright © 2018 MPD Bailey Technology. All rights reserved.
//

import Foundation

class PlaceFetcherUtils {
    let placeFetcher : IPlaceFetcher
    
    init(placeFetcher : IPlaceFetcher){
        self.placeFetcher = placeFetcher
    }
    
    var web : String {
        get {return placeFetcher.mbPlace?.web ?? ""}
    }
    var phone : String {
        get {return placeFetcher.mbPlace?.telephone ?? ""}
    }
    var phoneUrl : URL? {
        get {
            let removedSpaces = phone.replacingOccurrences(of: " ", with: "")
            return URL(string: "tel://\(removedSpaces)")
        }
    }

    func isLoading() -> Bool {
        switch placeFetcher.observableStatus.value {
        case .uninitialized:
            return true
        case .fetching:
            return true
        case .ready:
            return false
        case .error:
            return false
        }
    }
    func isPhoneAvailable() -> Bool {
        switch placeFetcher.observableStatus.value {
        case .uninitialized:
            return false
        case .fetching:
            return false
        case .ready:
            if let place = placeFetcher.mbPlace{
                return !place.telephone.isEmpty
            }
            return false
        case .error:
            return false
        }
    }
    func isWebAvailable() -> Bool {
        switch placeFetcher.observableStatus.value {
        case .uninitialized:
            return false
        case .fetching:
            return false
        case .ready:
            if let place = placeFetcher.mbPlace{
                return !place.web.isEmpty
            }
            return false
        case .error:
            return false
        }
    }

}
