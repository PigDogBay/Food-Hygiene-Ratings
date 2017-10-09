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

struct Ratings {
    
    private static func getAppUrl(_ itunesId : String)->String
    {
        return "itms-apps://itunes.apple.com/app/\(itunesId)"
    }

    static func viewOnAppStore(itunesId : String) {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(URL(string: getAppUrl(itunesId))!, options: [:])
        } else {
            UIApplication.shared.openURL(URL(string: getAppUrl(itunesId))!)
        }
    }
    
    static func requestRating() {
        if #available( iOS 10.3,*){
            //todo some logic to measure time and requests
            SKStoreReviewController.requestReview()
        }
    }
    
    static func reset(){
        //todo reset timer/counters
    }
}
