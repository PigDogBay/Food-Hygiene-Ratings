//
//  NoScoresTableDelegate.swift
//  Food Hygiene Ratings
//
//  Created by Mark Bailey on 22/02/2017.
//  Copyright © 2017 MPD Bailey Technology. All rights reserved.
//

import Foundation
import UIKit

class NoScoresTableDelegate : NSObject, UITableViewDataSource, UITableViewDelegate {
    
    let establishment : Establishment
    //Strong reference cycle
    weak var viewController : UIViewController!
    
    //Table structure
    fileprivate let SECTION_RATING = 0
    fileprivate let SECTION_ADDRESS = 1
    fileprivate let SECTION_LOCAL_AUTHORITY = 2
    fileprivate let SECTION_COUNT = 3
    
    fileprivate let ROW_RATING_TITLE = 0
    fileprivate let ROW_RATING_LOGO = 1
    fileprivate let ROW_RATING_COUNT = 2
    
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
        case SECTION_ADDRESS:
            return establishment.address.address.count
        case SECTION_LOCAL_AUTHORITY:
            return ROW_LA_COUNT
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case SECTION_RATING:
            return ""
        case SECTION_ADDRESS:
            return "Business Address"
        case SECTION_LOCAL_AUTHORITY:
            return "Local Authority"
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
                if let ratingsCell = cell as? RatingsLogoCell{
                    let date = DetailsViewController.dateFormatter.string(from: establishment.rating.awardedDate)
                    //To do logic for pending/exempt - not applicable
                    if !establishment.rating.hasRating(){
                        ratingsCell.subTitle.text = ""
                        ratingsCell.titleLabel.text = ""
                    } else if establishment.rating.newRatingPending{
                        ratingsCell.subTitle.text = "\(date) - new rating pending"
                        ratingsCell.titleLabel.text = "Date Awarded"
                    } else {
                        ratingsCell.subTitle.text = "\(date)"
                        ratingsCell.titleLabel.text = "Date Awarded"
                    }
                    ratingsCell.ratingLogo.image = UIImage(named: establishment.rating.ratingsKey)
                }
            default:
                break
            }
        case SECTION_ADDRESS:
            cell.textLabel?.text = establishment.address.address[indexPath.row]
        case SECTION_LOCAL_AUTHORITY:
            switch indexPath.row{
            case ROW_LA_NAME:
                cell.textLabel?.text = establishment.localAuthority.name
                cell.imageView?.image = UIImage(named: "iconAuthority")
            case ROW_LA_EMAIL:
                cell.textLabel?.text = establishment.localAuthority.email
            case ROW_LA_WEBSITE:
                cell.textLabel?.text = establishment.localAuthority.web
                cell.imageView?.image = UIImage(named: "iconWebpage")
            default:
                break
            }
            break
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
                viewController.mpdbSendEmail(recipients: [establishment.localAuthority.email], subject: "", body: "")
            case ROW_LA_WEBSITE:
                if #available(iOS 10.0, *) {
                    if let url = URL(string: establishment.localAuthority.web) {
                        UIApplication.shared.open(url, options: [:])
                    }
                }
            default:
                return
            }
        default:
            return
        }
    }
    
    fileprivate func getCellId(indexPath : IndexPath) -> String {
        switch indexPath.section {
        case SECTION_LOCAL_AUTHORITY:
            switch indexPath.row {
            case ROW_LA_EMAIL:
                return "cellLocalAuthority"
            case ROW_LA_WEBSITE:
                return "cellLocalAuthority"
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
        default:
            return "cellBasic"
        }
    }
    
    
}
