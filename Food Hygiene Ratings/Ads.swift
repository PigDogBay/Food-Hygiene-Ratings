//
//  Ads.swift
//  Food Hygiene Ratings
//
//  Created by Mark Bailey on 13/02/2017.
//  Copyright © 2017 MPD Bailey Technology. All rights reserved.
//

import UIKit
import GoogleMobileAds

struct Ads
{
    static let bannerAdId = "ca-app-pub-3582986480189311/1490068786"
    static let localBannerAdId = "ca-app-pub-3582986480189311/8489481588"

    static var bannerView : GADBannerView?
    
    static func createRequest() -> GADRequest
    {
        let request = GADRequest()
        request.testDevices = [
            "Simulator",
            "4ccb6d94e22bce9a7212f16cc927c429",//iPad
            "cc0b7644c90c4ab95e0150938951def3" //iPhone
        ]
        return request
    }
}
