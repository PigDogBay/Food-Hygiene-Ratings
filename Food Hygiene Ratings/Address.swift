//
//  Address.swift
//  Food Hygiene Ratings
//
//  Created by Mark Bailey on 27/02/2017.
//  Copyright © 2017 MPD Bailey Technology. All rights reserved.
//

import Foundation

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
    
    func flatten()->String {
        var flat = address[0]
        for i in 1..<address.count {
            flat = flat + ", " + address[i]
        }
        return flat
    }
}
