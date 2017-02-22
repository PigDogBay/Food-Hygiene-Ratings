//
//  Alerts.swift
//  Food Hygiene Ratings
//
//  Created by Mark Bailey on 22/02/2017.
//  Copyright © 2017 MPD Bailey Technology. All rights reserved.
//

import UIKit
import MessageUI

extension UIViewController
{
    public func mpdbShowErrorAlert(_ title: String, msg : String)
    {
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        let controller = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        controller.addAction(action)
        self.present(controller, animated: true, completion: nil)
    }
    public func mpdbShowAlert(_ title: String, msg : String)
    {
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        let controller = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        controller.addAction(action)
        self.present(controller, animated: true, completion: nil)
    }
    public func mpdbCheckIsFirstTime()->Bool
    {
        let key = "HasWelcomeShown"
        let defaults = UserDefaults.standard
        let firstTimeSetting = defaults.object(forKey: key) as? Bool
        if firstTimeSetting == nil
        {
            defaults.set(true, forKey: key)
            defaults.synchronize()
            return true
        }
        return false
    }
    public func mpdbSendEmail(recipients: [String], subject: String, body: String ){
        
        if !MFMailComposeViewController.canSendMail()
        {
            self.mpdbShowErrorAlert("No Email", msg: "This device is not configured for sending emails.")
            return
        }
        let mailVC = MFMailComposeViewController()
        mailVC.mailComposeDelegate = self as? MFMailComposeViewControllerDelegate
        mailVC.setSubject(subject)
        mailVC.setToRecipients(recipients)
        mailVC.setMessageBody(body, isHTML: false)
        self.present(mailVC, animated: true, completion: nil)
    }
    
}
