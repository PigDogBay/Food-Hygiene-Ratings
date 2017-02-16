//
//  Business.swift
//  Food Hygiene Ratings
//
//  Created by Mark Bailey on 16/02/2017.
//  Copyright © 2017 MPD Bailey Technology. All rights reserved.
//

import Foundation

struct Business {
    static let all = -1

    static let  takeawaySandwichShop = 7844
    static let  restaurantsCafeCanteen = 1
    static let  pubsBarsNightclubs = 7843
    static let  mobileCaters = 7846
    static let  otherCaters = 7841
    static let  hotel = 7842
    static let  supermarkets = 7840
    static let  retailersOther = 4613
    static let  hospitals = 5
    static let  school = 7845
    static let  importersExporters = 14
    static let  farmersGrowers = 7838
    static let  distributorsTransporters = 7
    static let  manufacturers = 7839
    
    static let sortOrder : [Int : Int] = [
        Business.takeawaySandwichShop : 0,
        Business.restaurantsCafeCanteen : 1,
        Business.pubsBarsNightclubs: 2,
        Business.mobileCaters: 3,
        Business.otherCaters: 4,
        Business.hotel: 5,
        Business.supermarkets: 6,
        Business.retailersOther: 7,
        Business.hospitals: 8,
        Business.school: 9,
        Business.importersExporters: 10,
        Business.farmersGrowers: 11,
        Business.distributorsTransporters: 12,
        Business.manufacturers: 13]
    
    
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
