//
//  Logging.swift
//  Food Hygiene Ratings
//
//  Created by Mark Bailey on 30/09/2017.
//  Copyright © 2017 MPD Bailey Technology. All rights reserved.
//

import Foundation


class Logging {
    
    static var enabled : Bool {
        get {
            return UserDefaults.standard.bool(forKey: "loggingEnabled")
        }
    }
    static var log = ""
    
    class func append(msg : String){
        if (enabled) {
            log.append(msg)
            log.append("\n")
        }
    }
    
    class func clear(){
        log = ""
    }
    
    
}
