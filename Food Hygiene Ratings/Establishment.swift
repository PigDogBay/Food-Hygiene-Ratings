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
struct Address {
    
    let line1 : String
    let line2 : String
    let line3 : String
    let line4 : String
    let postcode : String
    let coordinate : Coordinate
    let address : [String]
    
    init(line1 : String, line2 : String,line3 : String, line4 : String,postcode: String, coordinate : Coordinate){
        self.line1 = line1
        self.line2 = line2
        self.line3 = line3
        self.line4 = line4
        self.postcode = postcode
        self.coordinate = coordinate
        
        //Address fields may be missing
        var address = [String]()
        if line1 != "" { address.append(line1) }
        if line2 != "" { address.append(line2) }
        if line3 != "" { address.append(line3) }
        if line4 != "" { address.append(line4) }
        if postcode != "" { address.append(postcode) }
        
        self.address = address
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
