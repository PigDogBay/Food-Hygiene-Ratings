//
//  MapMarker.swift
//  FSAChecker
//
//  Created by Mark Bailey on 08/02/2017.
//  Copyright © 2017 Pig Dog Bay. All rights reserved.
//

import Foundation
import MapKit

class MapMarker : NSObject, MKAnnotation {
    
    static let fiveStarColor = UIColor(colorLiteralRed: 0.0, green: 1.0, blue: 0, alpha: 1.0)
    static let fourStarColor = UIColor(colorLiteralRed: 0.75, green: 1.0, blue: 0, alpha: 1.0)
    static let threeStarColor = UIColor(colorLiteralRed: 1.0, green: 1.0, blue: 0.0, alpha: 1.0)

    static let twoStarColor = UIColor(colorLiteralRed: 1.0, green: 0.5, blue: 0.25, alpha: 1.0)
    static let oneStarColor = UIColor(colorLiteralRed: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
    static let zeroStarColor = UIColor(colorLiteralRed: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
    
    let coordinate: CLLocationCoordinate2D
    let title : String?
    let subtitle: String?
    let color : UIColor
    
    init(establishment : Establishment){
        self.coordinate = CLLocationCoordinate2DMake(establishment.address.latitude, establishment.address.longitude)
        self.title = establishment.business.name
        self.subtitle = "\(establishment.rating.ratingString): \(establishment.business.type)"
        
        switch establishment.rating.value {
        case let .rating(stars):
            switch stars {
            case 0:
                color = MapMarker.zeroStarColor
            case 1:
                color = MapMarker.oneStarColor
            case 2:
                color = MapMarker.twoStarColor
            case 3:
                color = MapMarker.threeStarColor
            case 4:
                color = MapMarker.fourStarColor
            default:
                color = MapMarker.fiveStarColor
                
            }
        default:
            color = UIColor.blue
        }
    }
    
    
}
