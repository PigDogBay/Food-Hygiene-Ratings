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
    fileprivate let installDateKey = "RatingsInstallDate"
    //ask after 32 requests
    fileprivate let maxCount = 32
    //Ask after a week, time interval is in seconds
    fileprivate let maxTimeInterval = TimeInterval(7*24*60*60)
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
    fileprivate var installDate : Date {
        get{
            let defaults = UserDefaults.standard
            let c = defaults.object(forKey: installDateKey) as? Date
            if c == nil
            {
                let date = Date()
                defaults.set(date, forKey: installDateKey)
                defaults.synchronize()
                return date
            }
            return c!
        }
        set(value){
            let defaults = UserDefaults.standard
            defaults.set(value, forKey: installDateKey)
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
            let askDate = installDate.addingTimeInterval(maxTimeInterval)
            let today = Date()
            count = count + 1
            if count>maxCount  && today > askDate{
                //try again next week, requestReview will take care of showing or not
                reset()
                //requestReview() will only show 3 times per year and not again if the user has left a review
                SKStoreReviewController.requestReview()
            }
        }
    }
    
    func reset(){
        count = 0
        installDate = Date()
    }
}
