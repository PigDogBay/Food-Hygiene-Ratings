//
//  Establishment.swift
//  FSAChecker
//
//  Created by Mark Bailey on 07/02/2017.
//  Copyright © 2017 Pig Dog Bay. All rights reserved.
//

import Foundation

struct Coordinate {
    let longitude : Double
    let latitude : Double
}

enum RatingValue {
    case rating(Int)
    case exempt
    case pass
    case passEatSafe
    case awaitingInspection
    case improvementRequired
    case awaitingPublication
    case other
}

struct Rating {
    let value : RatingValue
    let ratingString : String
    let awardedDate : Date
    let newRatingPending : Bool
    let scores : Scores
    let ratingsKey : String
    
    func hasRating() -> Bool {
        switch self.value {
        case .rating(_):
            return true
        case .pass:
            return true
        case .passEatSafe:
            return true
        case .improvementRequired:
            return true
        default:
            return false
        
        }
    }
    
    func getIconName() -> String {
        
        switch self.value {
        case let .rating(value):
            switch value {
            case 5:
                return "icon5Filled"
            case 4:
                return "icon4Filled"
            case 3:
                return "icon3Filled"
            case 2:
                return "icon2Filled"
            case 1:
                return "icon1Filled"
            case 0:
                return "icon0Filled"
            default:
                return "iconUnknown"
            }
        case .exempt:
            return "iconExempt"
        case .awaitingInspection:
            return "iconPending"
        case .awaitingPublication:
            return "iconPending"
        default:
            return "iconUnknown"
        }
    }
    
}

struct LocalAuthority {
    let email : String
    let web : String
    let name : String
    let code : String
}

class Establishment {
    
    let business : Business
    let rating : Rating
    let distance : Double
    let address : Address
    let localAuthority : LocalAuthority
    
    init(business : Business, rating : Rating, distance : Double, address : Address, localAuthority : LocalAuthority){
        self.business = business
        self.rating = rating
        self.distance = distance
        self.address = address
        self.localAuthority = localAuthority
    }
    
}
