//
//  ObservableProperty.swift
//  Food Hygiene Ratings
//
//  Created by Mark Bailey on 20/09/2018.
//  Copyright © 2018 MPD Bailey Technology. All rights reserved.
//

import Foundation

class ObservableProperty<T : Equatable> {
    typealias Observer = (Any?,T) -> Void
    
    private var observers = [String : Observer]()
    //To synchronize functions, see
    //https://stackoverflow.com/questions/24045895/what-is-the-swift-equivalent-to-objective-cs-synchronized
    private var internalValue : T
    private let internalQueue : DispatchQueue = DispatchQueue(label: "lockingQueue")
    var owner : Any? = nil

    var value : T {
        get {
            return internalQueue.sync{internalValue}
        }
        set (newValue){
            internalQueue.sync {
                if newValue != internalValue {
                    internalValue = newValue
                    for (_, ob) in observers {
                        ob(owner, internalValue)
                    }
                }
            }
        }
    }
    init (_ v : T){
        internalValue = v
    }
    
    //Need to use @escaping as the closure Observer will be called after this function returns
    func addObserver(named : String, observer : @escaping Observer){
        internalQueue.sync{
            observers[named] =  observer
        }
    }
    func removeObserver(named : String){
        _ = internalQueue.sync {
            _ = observers.removeValue(forKey: named)
        }
    }
    func removeAllObservers(){
        internalQueue.sync {
            observers.removeAll()
        }
    }
}
