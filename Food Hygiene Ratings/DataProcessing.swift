//
//  DataProcessing.swift
//  Food Hygiene Ratings
//
//  Created by Mark Bailey on 16/02/2017.
//  Copyright © 2017 MPD Bailey Technology. All rights reserved.
//

import Foundation

struct DataProcessing {
    
    static func filter(establishments : [Establishment], containing : String) -> [Establishment] {

        if "" == containing {
            //nothing to do
            return establishments
        }
        let subString = containing.lowercased()
        return establishments.filter(){
            $0.business.name.lowercased().contains(subString)
        }
    }
    
    static func createDictionary(fromArray array : [Establishment]) -> [Int : [Establishment]] {
        var dictionary = [Int : NSMutableArray]()
        
        for est in array {
            if dictionary[est.business.typeId] == nil {
                dictionary[est.business.typeId] = NSMutableArray()
            }
            
            dictionary[est.business.typeId]?.add(est)
        }
        
        return dictionary as [Int : NSArray] as! [Int : [Establishment]]
    }
    
    static func createSortedIndex(fromDictionary dictionary : [Int : [Establishment]]) -> [Int] {
        let sortOrder = Business.sortOrder
        return dictionary.keys.sorted(by: {sortOrder[$0] ?? 1000 < sortOrder[$1] ?? 1000} )
    }
    
}
