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
