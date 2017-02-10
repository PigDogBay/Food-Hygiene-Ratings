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
}

struct Rating {
    let value : RatingValue
    let ratingString : String
    let awardedDate : Date
    let newRatingPending : Bool
    let scores : Scores
    
    init(value : RatingValue,ratingString : String, date : Date, scores : Scores, newRatingPending : Bool){
        self.value = value
        self.ratingString = ratingString
        self.awardedDate = date
        self.newRatingPending = newRatingPending
        self.scores = scores
    }
}
struct Address {
    
    let line1 : String
    let line2 : String
    let line3 : String
    let line4 : String
    let postcode : String
    let coordinate : Coordinate
    
    init(line1 : String, line2 : String,line3 : String, line4 : String,postcode: String, coordinate : Coordinate){
        self.line1 = line1
        self.line2 = line2
        self.line3 = line3
        self.line4 = line4
        self.postcode = postcode
        self.coordinate = coordinate
    }
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
    
    init(name : String, type : String, typeId : Int){
        self.name = name
        self.type = type
        self.typeId = typeId
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
    
    init(business : Business, rating : Rating, distance : Double, address : Address){
        self.business = business
        self.rating = rating
        self.distance = distance
        self.address = address
    }
    
}