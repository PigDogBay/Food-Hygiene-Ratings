//
//  CoordinateTest.swift
//  FoodHygieneRatingsTests
//
//  Created by Mark Bailey on 30/09/2017.
//  Copyright © 2017 MPD Bailey Technology. All rights reserved.
//

import XCTest
@testable import Food_Hygiene_Ratings

class CoordinateTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testIsWithinUk1() {
        let stokeCoord = Coordinate(longitude: -2.204094, latitude: 52.984120)
        XCTAssert(stokeCoord.isWithinUK())
        let nullCoord = Coordinate(longitude: 0.0, latitude: 0.0)
        XCTAssertFalse(nullCoord.isWithinUK())
        let appleCoord = Coordinate(longitude: -122.0312, latitude: 37.3318)
        XCTAssertFalse(appleCoord.isWithinUK())

    }
    
    
}
