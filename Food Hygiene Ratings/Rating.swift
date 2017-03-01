//
//  Rating.swift
//  Food Hygiene Ratings
//
//  Created by Mark Bailey on 28/02/2017.
//  Copyright © 2017 MPD Bailey Technology. All rights reserved.
//

import Foundation


enum RatingValue {
    case rating(Int)
    case exempt
    case pass
    case passEatSafe
    case awaitingInspection
    case improvementRequired
    case awaitingPublication
    case other
}


struct Rating {
    let value : RatingValue
    let ratingString : String
    let awardedDate : Date
    let newRatingPending : Bool
    let scores : Scores
    let ratingsKey : String
    
    func hasScores()->Bool {
        switch self.value {
        case .rating(_):
            return true
        default:
            return false
        }
    }
    
    func hasRating() -> Bool {
        switch self.value {
        case .rating(_):
            return true
        case .pass:
            return true
        case .passEatSafe:
            return true
        case .improvementRequired:
            return true
        default:
            return false
            
        }
    }
    
    func getIconName() -> String {
        
        switch self.value {
        case let .rating(value):
            switch value {
            case 5:
                return "icon5Filled"
            case 4:
                return "icon4Filled"
            case 3:
                return "icon3Filled"
            case 2:
                return "icon2Filled"
            case 1:
                return "icon1Filled"
            case 0:
                return "icon0Filled"
            default:
                return "iconUnknown"
            }
        case .exempt:
            return "iconExempt"
        case .awaitingInspection:
            return "iconPending"
        case .awaitingPublication:
            return "iconPending"
        case .pass:
            return "iconPass"
        case .passEatSafe:
            return "iconPassEatSafe"
        case .improvementRequired:
            return "iconImprovementRequired"
        default:
            return "iconUnknown"
        }
    }
    
}
