//
//  AddressTests.swift
//  Food Hygiene Ratings
//
//  Created by Mark Bailey on 27/02/2017.
//  Copyright © 2017 MPD Bailey Technology. All rights reserved.
//

import XCTest
@testable import Food_Hygiene_Ratings

class AddressTests: XCTestCase {
        
    
    func testFlatten1() {
        let coordinate = Coordinate(longitude: 0, latitude: 0)
        let address = Address(line1: "39 Culver Lane", line2: "", line3: "Reading", line4: "", postcode: "RG6 1DX", coordinate: coordinate)
        XCTAssertEqual(address.flatten(), "39 Culver Lane, Reading, RG6 1DX")
    }
    
}
