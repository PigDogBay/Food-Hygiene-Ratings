//
//  ObservableProperty.swift
//  Food Hygiene Ratings
//
//  Created by Mark Bailey on 20/09/2018.
//  Copyright © 2018 MPD Bailey Technology. All rights reserved.
//

import Foundation

class ObservableProperty<T> {
    typealias Observer = (T) -> Void
    
    private var observers = [String : Observer]()
    
    var value : T {
        didSet {
            for (_, ob) in observers {
                ob(value)
            }
        }
    }
    init (_ v : T){
        value = v
    }
    
    //Need to use @escaping as the closure Observer will be called after this function returns
    func addObserver(named : String, observer : @escaping Observer){
        observers[named] =  observer
    }
    func removeObserver(named : String){
        observers.removeValue(forKey: named)
    }
    func removeAllObservers(){
        observers.removeAll()
    }
}
