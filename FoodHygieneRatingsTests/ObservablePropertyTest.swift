//
//  ObservablePropertyTest.swift
//  FoodHygieneRatingsTests
//
//  Created by Mark Bailey on 20/09/2018.
//  Copyright © 2018 MPD Bailey Technology. All rights reserved.
//

import XCTest
@testable import Food_Hygiene_Ratings

class ObservablePropertyTest: XCTestCase {
    enum Fruit {
        case apple, pear, banana, orange, blueberry
    }
    var intNewValue : Int?
    var fruitNewValue : Fruit?

    private func intChanged(newValue : Int){
        intNewValue = newValue
    }
    private func fruitChanged(newValue : Fruit){
        fruitNewValue = newValue
    }

    func testInt1() {
        let target = ObservableProperty<Int>(42)
        target.addObserver(named: "int", observer: intChanged)
        target.value = 6
        target.removeObserver(named: "int")
        XCTAssertEqual(6, intNewValue)
    }
    
    func testEnum1(){
        let target = ObservableProperty<Fruit>(.apple)
        target.addObserver(named: "fruit", observer: fruitChanged)
        target.value = .blueberry
        target.removeObserver(named: "fruit")
        XCTAssertEqual(.blueberry, fruitNewValue)
    }
    
}
