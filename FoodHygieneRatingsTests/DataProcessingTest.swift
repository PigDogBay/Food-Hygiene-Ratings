//
//  DataProcessingTest.swift
//  Food Hygiene Ratings
//
//  Created by Mark Bailey on 16/02/2017.
//  Copyright © 2017 MPD Bailey Technology. All rights reserved.
//

import XCTest
@testable import Food_Hygiene_Ratings


class DataProcessingTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    let establishments : [Establishment] = {
        let testBundle = Bundle(for: FoodHygieneAPITest.self)
        let url =  testBundle.url(forResource: "establishments", withExtension: "json")
        let data = try! Data(contentsOf: url!)
        let estResult = FoodHygieneAPI.establishments(fromJSON: data)
        switch estResult {
        case let .success(results):
            return results
        case let .failure(error):
            return [Establishment]()
        }
    }()
    
    func testCreateDictionary1() {
        
        let dictionary = DataProcessing.createDictionary(fromArray: establishments)
        XCTAssertEqual(dictionary.keys.count, 10)
        XCTAssertEqual(dictionary[Business.takeawaySandwichShop]?.count, 15)
        XCTAssertEqual(dictionary[Business.pubsBarsNightclubs]?.count, 13)
    }
    
    func testCreateSortedIndex() {
        let dictionary = DataProcessing.createDictionary(fromArray: establishments)
        let sortedIndex = DataProcessing.createSortedIndex(fromDictionary: dictionary)
        XCTAssertEqual(sortedIndex.count, 10)
        XCTAssertEqual(sortedIndex[0], Business.takeawaySandwichShop)
        XCTAssertEqual(sortedIndex[1], Business.restaurantsCafeCanteen)
        
    }

}
