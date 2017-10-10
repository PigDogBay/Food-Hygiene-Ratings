//
//  Ratings.swift
//  Food Hygiene Ratings
//
//  Created by Mark Bailey on 09/10/2017.
//  Copyright © 2017 MPD Bailey Technology. All rights reserved.
//

import Foundation
import UIKit
import StoreKit

class Ratings {
    
    fileprivate let countKey = "RatingsRequestCount"
    fileprivate let maxCount = 5
    fileprivate var appUrl : String
    
    
    init(appId : String){
        self.appUrl = "itms-apps://itunes.apple.com/app/\(appId)"
    }

    fileprivate var count : Int {
        get{
            let defaults = UserDefaults.standard
            let c = defaults.object(forKey: countKey) as? Int
            if c == nil
            {
                defaults.set(0, forKey: countKey)
                defaults.synchronize()
                return 0
            }
            return c!
        }
        set(value){
            let defaults = UserDefaults.standard
            defaults.set(value, forKey: countKey)
            defaults.synchronize()
        }
    }


    func viewOnAppStore() {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(URL(string: appUrl)!, options: [:])
        } else {
            UIApplication.shared.openURL(URL(string: appUrl)!)
        }
    }
    
    func requestRating() {
        if #available( iOS 10.3,*){
            count = count + 1
            if count>maxCount {
                //todo some logic to measure time and requests
                SKStoreReviewController.requestReview()
            }
        }
    }
    
    func reset(){
        //todo reset timer/counters
        count = 0
    }
}
