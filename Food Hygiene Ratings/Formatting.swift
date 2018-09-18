//
//  Formatting.swift
//  Food Hygiene Ratings
//
//  Created by Mark Bailey on 30/09/2017.
//  Copyright © 2017 MPD Bailey Technology. All rights reserved.
//

import Foundation


class Formatting {
    static let dateFormatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    class func format(establishment : Establishment) -> String {
        var builder = "Food Hygiene Rating\n\n"
        builder.append("\(establishment.business.name)\n")
        for line in establishment.address.address {
            builder.append(line)
            builder.append("\n")
        }
        builder.append("\nRating: \(establishment.rating.ratingString)\n")
        if establishment.rating.hasRating(){
            builder.append("Awarded: \(Formatting.dateFormatter.string(from: establishment.rating.awardedDate))\n")
            builder.append("Food Hygiene and Safety: \(establishment.rating.scores.getHygieneDescription())\n")
            builder.append("Structural Compliance: \(establishment.rating.scores.getStructuralDescription())\n")
            builder.append("Confidence in Management: \(establishment.rating.scores.getManagementDescription())\n")
        }
        builder.append("\nLocal Authority Details\n")
        builder.append("\(establishment.localAuthority.name)\nEmail: \(establishment.localAuthority.email)\nWebsite: \(establishment.localAuthority.web)\n")
        builder.append("\nFSA Website for this business\n")
        builder.append("\(FoodHygieneAPI.createBusinessUrl(fhrsId: establishment.business.fhrsId).absoluteString)\n")
        return builder
    }

    
}
