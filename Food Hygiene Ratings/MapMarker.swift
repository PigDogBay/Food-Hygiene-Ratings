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
    
    static let fiveStarColor = UIColor(red: 0.0, green: 0.8, blue: 0, alpha: 1.0)
    static let fourStarColor = UIColor(red: 0.4, green: 0.8, blue: 0, alpha: 1.0)
    static let threeStarColor = UIColor(red: 0.8, green: 0.8, blue: 0.0, alpha: 1.0)

    static let twoStarColor = UIColor(red: 0.8, green: 0.4, blue: 0.0, alpha: 1.0)
    static let oneStarColor = UIColor(red: 0.8, green: 0.0, blue: 0.0, alpha: 1.0)
    static let zeroStarColor = UIColor(red: 0.4, green: 0.0, blue: 0.0, alpha: 1.0)

    let coordinate: CLLocationCoordinate2D
    let title : String?
    let subtitle: String?
    let color : UIColor
    let establishment : Establishment
    
    convenience init(establishment : Establishment){
        let coordinates = CLLocationCoordinate2DMake(establishment.address.coordinate.latitude, establishment.address.coordinate.longitude)
        self.init(establishment: establishment, coordinates : coordinates)
    }
    init(establishment : Establishment, coordinates : CLLocationCoordinate2D){
        self.coordinate = coordinates
        self.title = establishment.business.name
        self.subtitle = "\(establishment.rating.ratingString): \(establishment.business.type)"
        self.establishment = establishment
        
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
        case .improvementRequired:
            color = MapMarker.oneStarColor
        case .pass:
            color = MapMarker.fourStarColor
        case .passEatSafe:
            color = MapMarker.fiveStarColor
        default:
            color = UIColor.blue
        }
    }
}
