//
//  Scores.swift
//  Food Hygiene Ratings
//
//  Created by Mark Bailey on 21/02/2017.
//  Copyright © 2017 MPD Bailey Technology. All rights reserved.
//

import Foundation
struct Scores {
    let hygiene : Int
    let structural : Int
    let confidenceInManagement : Int

    static let hygienicTitle = "Hygienic food handling"
    static let hygienicDescription = "Hygienic handling of food including preparation, cooking, re-heating, cooling and storage. The best score is 0, the worst is 30"
    
    static let structuralTitle = "Cleanliness and condition of facilities and building"
    static let structuralDescription = "Cleanliness and condition of facilities and building (including having appropriate layout, ventilation, hand washing facilities and pest control) to enable good food hygiene. The best score is 0, the worst is 30"

    static let managementTitle = "Management of food safety"
    static let managementDescription = "System or checks in place to ensure that food sold or served is safe to eat, evidence that staff know about food safety, and the food safety officer has confidence that standards will be maintained in the future. The best score is 0, the worst is 30"
    
    
    init(hygiene : Int, structural : Int, confidenceInManagement : Int){
        self.hygiene = hygiene
        self.structural = structural
        self.confidenceInManagement = confidenceInManagement
    }
    
    func getHygieneDescription() -> String {
        return getDescription(score: hygiene)
    }
    func getStructuralDescription() -> String {
        return getDescription(score: structural)
    }
    func getManagementDescription() -> String {
        return getDescription(score: confidenceInManagement)
    }
    func getHygieneIconName() -> String {
        return getIconImageName(score: hygiene)
    }
    func getStructuralIconName() -> String {
        return getIconImageName(score: structural)
    }
    func getManagementIconName() -> String {
        return getIconImageName(score: confidenceInManagement)
    }
    
    //Taken from fhrsguidance.pdf
    fileprivate func getDescription(score : Int) -> String {
        switch score {
        case 0:
            return "very good"
        case 5:
            return "good"
        case 10:
            return "generally satisfactory"
        case 15:
            return "improvement necessary"
        case 20:
            return "major improvement necessary"
        case 25:
            return "urgent improvement necessary"
        case 30:
            return "urgent improvement necessary"
        default:
            return ""
            
        }
    }
    
    fileprivate func getIconImageName(score : Int) ->String{
        switch score
        {
        case 0:
            return "iconScore5"
        case 5:
            return "iconScore5"
        case 10:
            return "iconScore10"
        case 15:
            return "iconScore15"
        case 20:
            return "iconScore20"
        case 25:
            return "iconScore20"
        case 30:
            return "iconScore20"
        default:
            return "iconScore10"
        }
    }
}
