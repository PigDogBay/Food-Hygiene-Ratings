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

struct Scores {
    let hygiene : Int
    let structural : Int
    let confidenceInManagement : Int
    
    init(hygiene : Int, structural : Int, confidenceInManagement : Int){
        self.hygiene = hygiene
        self.structural = structural
        self.confidenceInManagement = confidenceInManagement
    }
    
    func getHygieneDescription() -> String {
        return getDescription(score: hygiene)
    }
    func getStructuralDescription() -> String {
        return getDescription(score: structural)
    }
    func getManagementDescription() -> String {
        return getDescription(score: confidenceInManagement)
    }
    func getHygieneIconName() -> String {
        return getIconImageName(score: hygiene)
    }
    func getStructuralIconName() -> String {
        return getIconImageName(score: structural)
    }
    func getManagementIconName() -> String {
        return getIconImageName(score: confidenceInManagement)
    }
    
    //Taken from fhrsguidance.pdf
    fileprivate func getDescription(score : Int) -> String {
        switch score {
        case 0:
            return "very good"
        case 5:
            return "good"
        case 10:
            return "generally satisfactory"
        case 15:
            return "improvement necessary"
        case 20:
            return "major improvement necessary"
        case 25:
            return "urgent improvement necessary"
        case 30:
            return "urgent improvement necessary"
        default:
            return ""
            
        }
    }
    
    fileprivate func getIconImageName(score : Int) ->String{
        switch score
        {
        case 0:
            return "iconScore5"
        case 5:
            return "iconScore5"
        case 10:
            return "iconScore10"
        case 15:
            return "iconScore15"
        case 20:
            return "iconScore20"
        case 25:
            return "iconScore20"
        case 30:
            return "iconScore20"
        default:
            return "iconScore10"
        }
    }
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


struct Business {
    static let all = -1
    static let  distributorsTransporters = 7
    static let  farmersGrowers = 7838
    static let  hospitals = 5
    static let  hotel = 7842
    static let  importersExporters = 14
    static let  manufacturers = 7839
    static let  mobileCaters = 7846
    static let  otherCaters = 7841
    static let  pubsBarsNightclubs = 7843
    static let  restaurantsCafeCanteen = 1
    static let  retailersOther = 4613
    static let  supermarkets = 7840
    static let  school = 7845
    static let  takeawaySandwichShop = 7844

    let name : String
    let type : String
    let typeId : Int
    let fhrsId : Int
    
    init(name : String, type : String, typeId : Int, fhrsId : Int){
        self.name = name
        self.type = type
        self.typeId = typeId
        self.fhrsId = fhrsId
    }
    
    func isEatingPlace()->Bool {
        return typeId == Business.takeawaySandwichShop ||
            typeId == Business.mobileCaters ||
            typeId == Business.pubsBarsNightclubs ||
            typeId == Business.restaurantsCafeCanteen ||
            typeId == Business.otherCaters
    }
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
