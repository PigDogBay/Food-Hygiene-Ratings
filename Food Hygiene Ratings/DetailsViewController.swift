//
//  DetailsViewController.swift
//  Food Hygiene Ratings
//
//  Created by Mark Bailey on 13/02/2017.
//  Copyright © 2017 MPD Bailey Technology. All rights reserved.
//

import UIKit
import MapKit
import GoogleMobileAds
import CoreLocation
import MessageUI

class DetailsViewController: UIViewController, MFMailComposeViewControllerDelegate,
                            UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func shareActionClicked(_ sender: UIBarButtonItem) {
        let firstActivityItem = Formatting.format(establishment: establishment)
        let activityViewController : UIActivityViewController = UIActivityViewController(activityItems: [firstActivityItem], applicationActivities: nil)
        //For iPads need to anchor the popover to the right bar button, crashes if not set
        if let ppc = activityViewController.popoverPresentationController {
            ppc.barButtonItem = navBar.rightBarButtonItem
        }
        self.present(activityViewController, animated: true, completion: nil)
    }
   
    var establishment : Establishment!
    let mapRadius : CLLocationDistance = 500
    let placeFetcher : IPlaceFetcher = GooglePlaceFetcher()
    var mapImage : UIImage? = nil
    var hasSetupMapDataBeenCalled = false
    
    private var photographCount = 0

    //Table structure
    fileprivate let SECTION_RATING = 0
    fileprivate let SECTION_PLACES = 1
    fileprivate let SECTION_SCORES = 2
    fileprivate let SECTION_ADDRESS = 3
    fileprivate let SECTION_LOCAL_AUTHORITY = 4
    fileprivate let SECTION_FSA_WEBSITE = 5
    fileprivate let SECTION_PHOTOS = 6
    fileprivate let SECTION_COUNT = 6
    
    fileprivate let ROW_PLACES_IMAGE = 0
    fileprivate let ROW_PLACES_PHONE = 1
    fileprivate let ROW_PLACES_WEB = 2
    fileprivate let ROW_PLACES_POWERED_BY_GOOGLE = 3
    fileprivate let ROW_PLACES_COUNT = 4
    
    fileprivate let ROW_RATING_TITLE = 0
    fileprivate let ROW_RATING_LOGO = 1
    fileprivate let ROW_RATING_COUNT = 2
    
    fileprivate let ROW_SCORES_HYGIENE = 0
    fileprivate let ROW_SCORES_STRUCTURAL = 1
    fileprivate let ROW_SCORES_MANAGEMENT = 2
    fileprivate let ROW_SCORES_COUNT = 3
    
    fileprivate let ROW_ADDRESS_MAP = 0
    fileprivate let ROW_ADDRESS_LINE_1 = 1
    fileprivate let ROW_ADDRESS_LINE_2 = 2
    fileprivate let ROW_ADDRESS_LINE_3 = 3
    fileprivate let ROW_ADDRESS_LINE_4 = 4
    
    fileprivate let ROW_LA_NAME = 0
    fileprivate let ROW_LA_EMAIL = 1
    fileprivate let ROW_LA_WEBSITE = 2
    fileprivate let ROW_LA_COUNT = 3

    deinit {
        print("DetailsVC DEINIT")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navBar.title = establishment.business.name
        tableView.dataSource = self
        tableView.delegate = self
        bannerView.adSize = kGADAdSizeBanner
        bannerView.adUnitID = Ads.bannerAdId
        bannerView.rootViewController = self
        bannerView.load(Ads.createRequest())
        startLoadingData()
    }
    //
    // This function is called twice, first when child view is added to parent
    // then secondly when it is removed, in this case parent is nil
    //
    override func willMove(toParent parent: UIViewController?)
    {
        //Only do something when moving back to parent
        if parent == nil
        {
            //strong reference cycle currently exists
            //TODO need to make the observers weak links
            placeFetcher.observableStatus.removeAllObservers()
            if let images = placeFetcher.mbPlace?.images{
                for im in images{
                    im.observableStatus.removeAllObservers()
                }
            }
        }
    }

    
    // MARK:- MFMailComposeViewControllerDelegate
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?)
    {
        //dismiss on send
        controller.dismiss(animated: true, completion: nil)
    }
    
    func startLoadingData(){
        placeFetcher.observableStatus.addObserver(named: "details", observer: fetchStatusUpdate)
        placeFetcher.fetch(establishment: establishment)
    }
    func fetchStatusUpdate(owner : Any?,status : FetchStatus){
        if status == .ready {
           addPhotographs()
        }
        DispatchQueue.main.async {
            self.tableView.reloadSections([self.SECTION_PLACES], with: .none)
        }
    }
    func fetchImageStatusUpdate(owner: Any?, status : FetchStatus){
        DispatchQueue.main.async {
            if let placeImage = owner as? IPlaceImage{
                if placeImage.index == 0{
                    self.tableView.reloadRows(at: [IndexPath(row: self.ROW_PLACES_IMAGE,section: self.SECTION_PLACES)], with: .none)
                } else {
                    self.tableView.reloadRows(at: [IndexPath(row: placeImage.index-1,section: self.SECTION_PHOTOS)], with: .none)
                }
            }
        }
    }
    //Got the photo meta-data, now tell the VC and table about them
    func addPhotographs(){
        if let images = placeFetcher.mbPlace?.images {
            photographCount = images.count
            for im in images {
                im.observableStatus.removeAllObservers()
                im.observableStatus.addObserver(named: "detailsVC", observer: fetchImageStatusUpdate)
            }
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    private func setUpMap(){
        if hasSetupMapDataBeenCalled {
            return
        }
        hasSetupMapDataBeenCalled = true
        //Find more accurate co-ordinates for the business
        let address = "\(establishment.address.line1),\(establishment.address.line2),\(establishment.address.line3),\(establishment.address.line4),\(establishment.address.postcode)"
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) {
            (placemarks, error) -> Void in
            if error != nil {
                //use FSA co-ordinates
                let coords = self.establishment.address.coordinate
                if coords.isWithinUK(){
                    let coordinates = CLLocationCoordinate2D(latitude: coords.latitude, longitude: coords.longitude)
                    self.createSnapShot(coordinates: coordinates)
                }
            } else if let placemark = placemarks?.first {
                self.createSnapShot(coordinates: (placemark.location?.coordinate)!)
            }
        }
    }
    private func createSnapShot(coordinates : CLLocationCoordinate2D) {
        let region = MKCoordinateRegion(center: coordinates ,latitudinalMeters: mapRadius * 2.0, longitudinalMeters: mapRadius * 2.0)
        let mapSnapshotOptions = MKMapSnapshotter.Options()
        mapSnapshotOptions.region = region
        mapSnapshotOptions.scale = UIScreen.main.scale
        mapSnapshotOptions.size = CGSize(width: 300.0, height: 300.0)
        mapSnapshotOptions.showsBuildings = true
        mapSnapshotOptions.showsPointsOfInterest = true
        let snapShotter = MKMapSnapshotter(options: mapSnapshotOptions)
        snapShotter.start{snapshot,error in
            guard let snapshot = snapshot, error == nil else {
                return
            }
            //draw marker on image
            UIGraphicsBeginImageContextWithOptions(mapSnapshotOptions.size, true, mapSnapshotOptions.scale)
            snapshot.image.draw(at: .zero)
            
            let pinView = MKPinAnnotationView(annotation: nil, reuseIdentifier: nil)
            let pinImage = pinView.image
            var point = snapshot.point(for: coordinates)
            
            let rect = CGRect(x: 0, y: 0, width: 300, height: 300)
            
            if rect.contains(point) {
                let pinCenterOffset = pinView.centerOffset
                point.x -= pinView.bounds.size.width / 2
                point.y -= pinView.bounds.size.height / 2
                point.x += pinCenterOffset.x
                point.y += pinCenterOffset.y
                pinImage?.draw(at: point)
            }
            self.mapImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            DispatchQueue.main.async {
                self.tableView.reloadRows(at: [IndexPath(row: self.ROW_ADDRESS_MAP,section: self.SECTION_ADDRESS)], with: .none)
            }
        }
    }

    //Table Functions
    func numberOfSections(in tableView: UITableView) -> Int {
        return photographCount>1 ? SECTION_COUNT + 1 : SECTION_COUNT
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath.section, indexPath.row ){
        case (SECTION_RATING, ROW_RATING_LOGO):
            return 92
        case (SECTION_PLACES, ROW_PLACES_IMAGE):
            return tableView.bounds.width
        case (SECTION_ADDRESS,0):
            return 300
        case (SECTION_ADDRESS,1...4):
            return 26
        case (SECTION_PHOTOS, _):
            return tableView.bounds.width
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
            return establishment.address.address.count + 1
        case SECTION_LOCAL_AUTHORITY:
            return ROW_LA_COUNT
        case SECTION_FSA_WEBSITE:
            return 1
        case SECTION_PHOTOS:
            return photographCount - 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case SECTION_RATING:
            return "Rating"
        case SECTION_PLACES:
            return "Place"
        case SECTION_SCORES:
            return "Scores"
        case SECTION_ADDRESS:
            return "Address"
        case SECTION_LOCAL_AUTHORITY:
            return "Local Authority"
        case SECTION_FSA_WEBSITE:
            return "FSA Website"
        case SECTION_PHOTOS:
            return "Photos"
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
            cell.imageView?.image = UIImage(named: "iconWebpage")
        case (SECTION_PLACES, ROW_PLACES_PHONE):
            cell.textLabel?.text = getPlacePhone()
            cell.imageView?.image = UIImage(named: "iconPhone")
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
        case (SECTION_ADDRESS, 0):
            let mapCell = cell as! MapCell
            if let mapImage = mapImage{
                mapCell.showMap(mapImage: mapImage)
            } else {
                setUpMap()
            }
        case (SECTION_ADDRESS, 1...4):
            cell.textLabel?.text = establishment.address.address[indexPath.row-1]
            cell.imageView?.image = nil
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
        case (SECTION_PHOTOS, _):
            setupPictureCell(cell: cell as! PlaceImageCell, imageIndex: indexPath.row+1)
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath {
        case [SECTION_LOCAL_AUTHORITY,ROW_LA_EMAIL]:
            mpdbSendEmail(recipients: [establishment.localAuthority.email], subject: "Food Hygiene Rating", body: Formatting.format(establishment: establishment))
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
        let action = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        let controller = UIAlertController(title: title, message: msg, preferredStyle: UIAlertController.Style.alert)
        controller.addAction(action)
        present(controller, animated: true, completion: nil)
    }
    
    fileprivate func getCellId(indexPath : IndexPath) -> String {
        switch (indexPath.section, indexPath.row) {
        case (SECTION_PLACES, ROW_PLACES_IMAGE):
            return "cellPlaceImage"
        case (SECTION_PLACES, ROW_PLACES_WEB):
            return "cellSelectable"
        case (SECTION_PLACES, ROW_PLACES_PHONE):
            return "cellSelectable"
        case (SECTION_PLACES, ROW_PLACES_POWERED_BY_GOOGLE):
            return "cellPoweredByGoogle"
        case (SECTION_ADDRESS, ROW_ADDRESS_MAP):
            return "cellMap"
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
        case (SECTION_PHOTOS, _):
            return "cellPlaceImage"
        default:
            return "cellBasic"
        }
    }
    
    func setupPictureCell(cell : PlaceImageCell, imageIndex : Int){
        cell.attribution.attributedText = NSAttributedString(string:"")
        switch placeFetcher.observableStatus.value {
        case .uninitialized:
            cell.picture.image = UIImage(named: "iconCamera")
        case .fetching:
            cell.picture.image = UIImage(named: "iconCamera")
        case .ready:
            if let images = placeFetcher.mbPlace?.images {
                if images.count > 0 && imageIndex <= images.count {
                    switch images[imageIndex].observableStatus.value {
                    case .uninitialized:
                        images[imageIndex].fetchBitmap()
                        cell.picture.image = UIImage(named: "iconCamera")
                    case .fetching:
                        cell.picture.image = UIImage(named: "iconCamera")
                        break
                    case .ready:
                        cell.picture.image = images[imageIndex].image
                        cell.attribution.attributedText = images[imageIndex].attribution ?? NSAttributedString(string:"")
                    case .error:
                        cell.picture.image = UIImage(named: "iconNoCamera")
                        break
                    }
                }
                else {
                    cell.picture.image = UIImage(named: "iconNoCamera")
                }
            }
            else {
                cell.picture.image = UIImage(named: "iconNoCamera")
            }
        case .error:
            cell.picture.image = UIImage(named: "iconNoCamera")
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
