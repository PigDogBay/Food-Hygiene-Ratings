//
//  Settings.swift
//  Food Hygiene Ratings
//
//  Created by Mark Bailey on 18/09/2018.
//  Copyright © 2018 MPD Bailey Technology. All rights reserved.
//

import Foundation

class Settings {

    fileprivate static let searchRadiusKey = "searchRadius"
    fileprivate static let connectionTimeOutKey = "connectionTimeout"

    static var searchRadius : Int {
        get {
            return UserDefaults.standard.integer(forKey: Settings.searchRadiusKey)
        }
    }

    static var connectionTimeOut : Int {
        get {
            return UserDefaults.standard.integer(forKey: Settings.connectionTimeOutKey)
        }
    }
    class func registerDefaultSettings() {
        let defaultSettings : [ String : Any] = [searchRadiusKey : 1,
                                                 connectionTimeOutKey : 60]
        UserDefaults.standard.register(defaults: defaultSettings)
    }

}
