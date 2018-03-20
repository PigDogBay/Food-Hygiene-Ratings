//
//  DetailsTableDelegate.swift
//  Food Hygiene Ratings
//
//  Created by Mark Bailey on 22/02/2017.
//  Copyright © 2017 MPD Bailey Technology. All rights reserved.
//

import Foundation
import UIKit

class DetailsTableDelegate : NSObject, UITableViewDataSource, UITableViewDelegate {

    let establishment : Establishment
    //Strong reference cycle
    weak var viewController : UIViewController!

    //Table structure
    fileprivate let SECTION_RATING = 0
    fileprivate let SECTION_SCORES = 1
    fileprivate let SECTION_ADDRESS = 2
    fileprivate let SECTION_LOCAL_AUTHORITY = 3
    fileprivate let SECTION_FSA_WEBSITE = 4
    fileprivate let SECTION_COUNT = 5
    
    fileprivate let ROW_RATING_TITLE = 0
    fileprivate let ROW_RATING_LOGO = 1
    fileprivate let ROW_RATING_COUNT = 2
    
    fileprivate let ROW_SCORES_HYGIENE = 0
    fileprivate let ROW_SCORES_STRUCTURAL = 1
    fileprivate let ROW_SCORES_MANAGEMENT = 2
    fileprivate let ROW_SCORES_COUNT = 3
    
    fileprivate let ROW_LA_NAME = 0
    fileprivate let ROW_LA_EMAIL = 1
    fileprivate let ROW_LA_WEBSITE = 2
    fileprivate let ROW_LA_COUNT = 3

    
    init(establishment : Establishment, viewController : UIViewController){
        self.establishment = establishment
        self.viewController = viewController
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return SECTION_COUNT
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case SECTION_RATING:
            switch indexPath.row {
            case ROW_RATING_LOGO:
                return 92
            default:
                return 44
            }
        case SECTION_ADDRESS:
            return 26
        default:
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case SECTION_RATING:
            return ROW_RATING_COUNT
        case SECTION_SCORES:
            return ROW_SCORES_COUNT
        case SECTION_ADDRESS:
            return establishment.address.address.count
        case SECTION_LOCAL_AUTHORITY:
            return ROW_LA_COUNT
        case SECTION_FSA_WEBSITE:
            return 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case SECTION_RATING:
            return ""
        case SECTION_SCORES:
            return "Hazard Points"
        case SECTION_ADDRESS:
            return "Business Address"
        case SECTION_LOCAL_AUTHORITY:
            return "Local Authority"
        case SECTION_FSA_WEBSITE:
            return "FSA Website"
        default:
            return ""
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = getCellId(indexPath: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as UITableViewCell
        
        switch indexPath.section {
        case SECTION_RATING:
            switch indexPath.row {
            case ROW_RATING_TITLE:
                cell.textLabel?.text = establishment.business.name
                cell.detailTextLabel?.text = establishment.business.type
            case ROW_RATING_LOGO:
                DetailsViewController.setupRatingsCell(cell: cell, establishment: establishment)
            default:
                break
            }
        case SECTION_SCORES:
            switch indexPath.row {
            case ROW_SCORES_HYGIENE:
                cell.textLabel?.text = "Hygiene: \(establishment.rating.scores.hygiene)"
                cell.detailTextLabel?.text = establishment.rating.scores.getHygieneDescription()
                cell.imageView?.image = UIImage(named: establishment.rating.scores.getHygieneIconName())
            case ROW_SCORES_STRUCTURAL:
                cell.textLabel?.text = "Structural: \(establishment.rating.scores.structural)"
                cell.detailTextLabel?.text = establishment.rating.scores.getStructuralDescription()
                cell.imageView?.image = UIImage(named: establishment.rating.scores.getStructuralIconName())
            case ROW_SCORES_MANAGEMENT:
                cell.textLabel?.text = "Management: \(establishment.rating.scores.confidenceInManagement)"
                cell.detailTextLabel?.text = establishment.rating.scores.getManagementDescription()
                cell.imageView?.image = UIImage(named: establishment.rating.scores.getManagementIconName())
            default:
                break
            }
            break
        case SECTION_ADDRESS:
            cell.textLabel?.text = establishment.address.address[indexPath.row]
        case SECTION_LOCAL_AUTHORITY:
            switch indexPath.row{
            case ROW_LA_NAME:
                cell.textLabel?.text = establishment.localAuthority.name
                cell.imageView?.image = UIImage(named: "iconAuthority")
            case ROW_LA_EMAIL:
                cell.textLabel?.text = establishment.localAuthority.email
                cell.imageView?.image = UIImage(named: "iconEmail")
            case ROW_LA_WEBSITE:
                cell.textLabel?.text = establishment.localAuthority.web
                cell.imageView?.image = UIImage(named: "iconWebpage")
            default:
                break
            }
            break
        case SECTION_FSA_WEBSITE:
            cell.textLabel?.text = "View rating on the FSA website"
        default:
            break
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case SECTION_LOCAL_AUTHORITY:
            switch indexPath.row
            {
            case ROW_LA_EMAIL:
                viewController.mpdbSendEmail(recipients: [establishment.localAuthority.email], subject: "Food Hygiene Rating", body: Formatting.format(establishment: establishment))
            case ROW_LA_WEBSITE:
                if let url = URL(string: establishment.localAuthority.web) {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(url, options: [:])
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                }
            default:
                return
            }
        case SECTION_FSA_WEBSITE:
            viewController.performSegue(withIdentifier: "segueFSA", sender: viewController)
        default:
            return
        }
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        switch indexPath.section {
        case SECTION_SCORES:
            switch indexPath.row
            {
            case ROW_SCORES_HYGIENE:
                showAlert(title: Scores.hygienicTitle, msg: Scores.hygienicDescription)
            case ROW_SCORES_MANAGEMENT:
                showAlert(title: Scores.managementTitle, msg: Scores.managementDescription)
            case ROW_SCORES_STRUCTURAL:
                showAlert(title: Scores.structuralTitle, msg: Scores.structuralDescription)
            default:
                return
            }
        default:
            return
        }
    }
    fileprivate func showAlert(title: String, msg : String)
    {
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        let controller = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        controller.addAction(action)
        self.viewController.present(controller, animated: true, completion: nil)
    }
    
    fileprivate func getCellId(indexPath : IndexPath) -> String {
        switch indexPath.section {
        case SECTION_LOCAL_AUTHORITY:
            switch indexPath.row {
            case ROW_LA_EMAIL:
                return "cellSelectable"
            case ROW_LA_WEBSITE:
                return "cellSelectable"
            default:
                return "cellBasic"
            }
        case SECTION_RATING:
            switch indexPath.row {
            case ROW_RATING_TITLE:
                return "cellSubtitle"
            case ROW_RATING_LOGO:
                return "cellRatingsLogo"
            default:
                return "cellBasic"
            }
        case SECTION_SCORES:
            return "cellScore"
        case SECTION_FSA_WEBSITE:
            return "cellSelectable"
        default:
            return "cellBasic"
        }
    }
    

}
