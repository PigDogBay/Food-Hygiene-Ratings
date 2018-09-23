//
//  MainViewController.swift
//  Food Hygiene Ratings
//
//  Created by Mark Bailey on 12/02/2017.
//  Copyright © 2017 MPD Bailey Technology. All rights reserved.
//

import UIKit
import MessageUI

class RootViewController: UITableViewController, UITextFieldDelegate, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var businessNameTextField: UITextField!
    @IBOutlet weak var placeNameTextField: UITextField!

    static var ads : Ads!
    
    let segueIdNearMe = "segueNearMe"
    let segueIdQuickSearch = "segueQuickSearch"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        businessNameTextField.delegate = self
        placeNameTextField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === businessNameTextField {
            businessNameTextField.resignFirstResponder()
            placeNameTextField.becomeFirstResponder()
        } else if textField === placeNameTextField {
            placeNameTextField.resignFirstResponder()
            performSegue(withIdentifier: segueIdQuickSearch, sender: self)
        }
        return true
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        switch identifier {
        case segueIdQuickSearch:
            let query = createQuery()
            if query.isEmpty() {
                mpdbShowAlert("No Name or Place", msg: "Enter a name and place to search for")
                return false
            }
        default:
            break
            
        }
        return true
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        switch segue.identifier ?? "" {
        case segueIdNearMe:
            MainModel.sharedInstance.findLocalEstablishments()
        case segueIdQuickSearch:
            let query = createQuery()
            MainModel.sharedInstance.findEstablishments(query: query)
        default:
            break
            
        }
     
    }

    fileprivate func createQuery() -> Query {
        var query = Query()
        if let name  = businessNameTextField.text {
            if name != "" {
                query.businessName = name.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        if let place = placeNameTextField.text {
            if place != "" {
                query.placeName = place.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        return query
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath {
        case [1,2]:
            showSettings()
        case [2,0]:
            openUrl(url: MainModel.getUserGuideUrl())
        case [2,1]:
            openUrl(url: MainModel.getPrivacyPolicyUrl())
        case [3,0]:
            MainModel.sharedInstance.ratings.viewOnAppStore()
        case [3,1]:
            sendFeedback()
        case [3,2]:
            tellFriends()
        default:
            break
        }
    }
    fileprivate func openUrl(url : String){
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(URL(string: url)!, options: [:])
        } else {
            UIApplication.shared.openURL(URL(string: url)!)
        }
    }
    func showSettings(){
        let application = UIApplication.shared
        let url = URL(string: UIApplication.openSettingsURLString)! as URL
        if application.canOpenURL(url){
            application.openURL(url)
        }
    }

    func sendFeedback(){
        if !MFMailComposeViewController.canSendMail()
        {
            self.mpdbShowErrorAlert("No Email", msg: "This device is not configured for sending emails.")
            return
        }
        let mailVC = MFMailComposeViewController()
        mailVC.mailComposeDelegate = self
        mailVC.setSubject("FHR iOS v1.03")
        mailVC.setToRecipients(["pigdogbay@yahoo.co.uk"])
        mailVC.setMessageBody("Your feedback is most welcome\n *Report Bugs\n *Suggest new features\n *Ask for help\n\n\nHi Mark,\n\n", isHTML: false)
        present(mailVC, animated: true, completion: nil)
    }
    
    func tellFriends(){
        let shareText = "Take a look at Food Hygiene Ratings UK https://itunes.apple.com/app/id1213783338"
        let activityViewController : UIActivityViewController = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        if let ppc = activityViewController.popoverPresentationController {
            ppc.sourceView = self.view
            ppc.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            ppc.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        }
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    // MARK:- MFMailComposeViewControllerDelegate
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?)
    {
        //dismiss on send
        dismiss(animated: true, completion: nil)
    }
}
