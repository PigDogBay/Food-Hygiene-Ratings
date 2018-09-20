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
    var placeFetcher : IPlaceFetcher! = nil
    
    //Strong reference cycle
    weak var viewController : UIViewController!

    //Table structure
    fileprivate let SECTION_RATING = 0
    fileprivate let SECTION_PLACES = 1
    fileprivate let SECTION_SCORES = 2
    fileprivate let SECTION_ADDRESS = 3
    fileprivate let SECTION_LOCAL_AUTHORITY = 4
    fileprivate let SECTION_FSA_WEBSITE = 5
    fileprivate let SECTION_COUNT = 6
    
    fileprivate let ROW_PLACES_IMAGE = 0
    fileprivate let ROW_PLACES_PHONE = 1
    fileprivate let ROW_PLACES_WEB = 2
    fileprivate let ROW_PLACES_COUNT = 3

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
        switch (indexPath.section, indexPath.row ){
        case (SECTION_RATING, ROW_RATING_LOGO):
            return 92
        case (SECTION_PLACES, ROW_PLACES_IMAGE):
            return tableView.bounds.width
        case (SECTION_ADDRESS,_):
            return 26
        default:
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case SECTION_RATING:
            return ROW_RATING_COUNT
        case SECTION_PLACES:
            return ROW_PLACES_COUNT
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
        case SECTION_PLACES:
            return "Google Places Information"
        case SECTION_SCORES:
            return "Scores"
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
        
        switch (indexPath.section, indexPath.row) {
        case (SECTION_RATING,ROW_RATING_TITLE):
            cell.textLabel?.text = establishment.business.name
            cell.detailTextLabel?.text = establishment.business.type
        case (SECTION_RATING,ROW_RATING_LOGO):
            setupRatingsCell(cell: cell)
        case (SECTION_PLACES, ROW_PLACES_IMAGE):
            setupPictureCell(cell: cell as! PlaceImageCell, imageIndex: 0)
        case (SECTION_PLACES, ROW_PLACES_WEB):
            cell.textLabel?.text = getPlaceWeb()
        case (SECTION_PLACES, ROW_PLACES_PHONE):
            cell.textLabel?.text = getPlacePhone()
        case (SECTION_SCORES,ROW_SCORES_HYGIENE):
            cell.textLabel?.text = establishment.rating.scores.getHygieneDescription()
            cell.detailTextLabel?.text = "Food Hygiene and Safety"
            cell.imageView?.image = UIImage(named: establishment.rating.scores.getHygieneIconName())
        case (SECTION_SCORES,ROW_SCORES_STRUCTURAL):
            cell.textLabel?.text = establishment.rating.scores.getStructuralDescription()
            cell.detailTextLabel?.text = "Structural Compliance"
            cell.imageView?.image = UIImage(named: establishment.rating.scores.getStructuralIconName())
        case (SECTION_SCORES,ROW_SCORES_MANAGEMENT):
            cell.textLabel?.text = establishment.rating.scores.getManagementDescription()
            cell.detailTextLabel?.text = "Confidence in Management"
            cell.imageView?.image = UIImage(named: establishment.rating.scores.getManagementIconName())
        case (SECTION_ADDRESS, 0...3):
            cell.textLabel?.text = establishment.address.address[indexPath.row]
        case (SECTION_LOCAL_AUTHORITY,ROW_LA_NAME):
            cell.textLabel?.text = establishment.localAuthority.name
            cell.imageView?.image = UIImage(named: "iconAuthority")
        case (SECTION_LOCAL_AUTHORITY,ROW_LA_EMAIL):
            cell.textLabel?.text = establishment.localAuthority.email
            cell.imageView?.image = UIImage(named: "iconEmail")
        case (SECTION_LOCAL_AUTHORITY,ROW_LA_WEBSITE):
            cell.textLabel?.text = establishment.localAuthority.web
            cell.imageView?.image = UIImage(named: "iconWebpage")
        case (SECTION_FSA_WEBSITE,0):
            cell.textLabel?.text = "View rating on the FSA website"
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath {
        case [SECTION_LOCAL_AUTHORITY,ROW_LA_EMAIL]:
            viewController.mpdbSendEmail(recipients: [establishment.localAuthority.email], subject: "Food Hygiene Rating", body: Formatting.format(establishment: establishment))
        case [SECTION_LOCAL_AUTHORITY,ROW_LA_WEBSITE]:
            if let url = URL(string: establishment.localAuthority.web) {
                openWeb(url: url)
            }
        case [SECTION_FSA_WEBSITE,0]:
            openWeb(url: FoodHygieneAPI.createBusinessUrl(fhrsId: establishment.business.fhrsId))
        default:
            return
        }
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        switch indexPath {
        case [SECTION_SCORES,ROW_SCORES_HYGIENE]:
            showAlert(title: Scores.hygienicTitle, msg: Scores.hygienicDescription)
        case [SECTION_SCORES,ROW_SCORES_MANAGEMENT]:
            showAlert(title: Scores.managementTitle, msg: Scores.managementDescription)
        case [SECTION_SCORES,ROW_SCORES_STRUCTURAL]:
            showAlert(title: Scores.structuralTitle, msg: Scores.structuralDescription)
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
        switch (indexPath.section, indexPath.row) {
        case (SECTION_PLACES, ROW_PLACES_IMAGE):
            return "cellPlaceImage"
        case (SECTION_LOCAL_AUTHORITY,ROW_LA_EMAIL):
            return "cellSelectable"
        case (SECTION_LOCAL_AUTHORITY,ROW_LA_WEBSITE):
            return "cellSelectable"
        case (SECTION_RATING,ROW_RATING_TITLE):
            return "cellSubtitle"
        case (SECTION_RATING,ROW_RATING_LOGO):
            return "cellRatingsLogo"
        case (SECTION_SCORES, _):
            return "cellScore"
        case (SECTION_FSA_WEBSITE, 0):
            return "cellSelectable"
        default:
            return "cellBasic"
        }
    }
    
    func setupPictureCell(cell : PlaceImageCell, imageIndex : Int){
        if placeFetcher.observableStatus.value == .ready {
            if let images = placeFetcher.mbPlace?.images {
                if images.count > 0 && imageIndex <= images.count {
                    switch images[imageIndex].observableStatus.value {
                    case .uninitialized:
                        images[imageIndex].fetchBitmap()
                    case .fetching:
                        break
                    case .ready:
                        cell.picture.image = images[imageIndex].image
                        cell.attribution.text = images[imageIndex].attribution
                    case .error:
                        break
                    }
                }
            }
        }
    }

    func setupRatingsCell(cell : UITableViewCell) {
        if let ratingsCell = cell as? RatingsLogoCell{
            let date = Formatting.dateFormatter.string(from: establishment.rating.awardedDate)
            ratingsCell.subTitle2.text = ""
            ratingsCell.subTitle.text = ""
            ratingsCell.titleLabel.text = ""
            if establishment.rating.hasRating(){
                ratingsCell.subTitle.text = "Date Awarded"
                ratingsCell.titleLabel.text = "\(date)"
            }
            if establishment.rating.newRatingPending{
                ratingsCell.subTitle2.text = "New rating pending"
            }
            ratingsCell.ratingLogo.image = UIImage(named: establishment.rating.ratingsKey)
        }
    }

    private func openWeb(url : URL){
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:])
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    private func getPlaceWeb() -> String{
        switch placeFetcher.observableStatus.value {
        case .uninitialized:
            return "Loading..."
        case .fetching:
            return "Loading..."
        case .ready:
            return placeFetcher.mbPlace!.web
        case .error:
            return "Not available"
        }
    }
    private func getPlacePhone() -> String{
        switch placeFetcher.observableStatus.value {
        case .uninitialized:
            return "Loading..."
        case .fetching:
            return "Loading..."
        case .ready:
            return placeFetcher.mbPlace!.telephone
        case .error:
            return "Not available"
        }
    }
}
