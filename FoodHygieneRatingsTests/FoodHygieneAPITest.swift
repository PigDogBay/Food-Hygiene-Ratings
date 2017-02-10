//
//  FoodHygieneAPITest.swift
//  Food Hygiene Ratings
//
//  Created by Mark Bailey on 10/02/2017.
//  Copyright © 2017 MPD Bailey Technology. All rights reserved.
//

import XCTest
@testable import Food_Hygiene_Ratings

class FoodHygieneAPITest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    let data : Data = {
        let testBundle = Bundle(for: FoodHygieneAPITest.self)
        let url =  testBundle.url(forResource: "establishments", withExtension: "json")
        return try! Data(contentsOf: url!)
    }()
    
    func testEstablishments1() {
        let estResult = FoodHygieneAPI.establishments(fromJSON: data)
        
        switch estResult {
        case let .success(results):
            XCTAssertEqual(99, results.count)
            let bakeNButty = results[4]
            XCTAssertEqual("Bake'n Butty", bakeNButty.business.name)
        case let .failure(error):
            XCTFail(error.localizedDescription)
        }
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
