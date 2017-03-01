//
//  Establishment.swift
//  FSAChecker
//
//  Created by Mark Bailey on 07/02/2017.
//  Copyright © 2017 Pig Dog Bay. All rights reserved.
//

import Foundation

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
