//
//  WebViewController.swift
//  Food Hygiene Ratings
//
//  Created by Mark Bailey on 12/02/2017.
//  Copyright © 2017 MPD Bailey Technology. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate {

    @IBOutlet weak var webContainer: UIView!
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingLabel: UILabel!

    var navTitle : String!
    var url : URL!

    fileprivate var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        webView = WKWebView(frame: webContainer.frame)
        webView.navigationDelegate = self
        webContainer.addSubview(webView)
        constrainView(view: webView, toView: webContainer)
        
        navigationBar.title = navTitle
        let request = URLRequest(url: url)
        webView.load(request)
    }
    //https://stackoverflow.com/questions/40856112/how-to-create-a-sized-wkwebview-in-swift-3-ios-10
    func constrainView(view:UIView, toView contentView:UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        view.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        webView.stopLoading()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        webView.stopLoading()
    }
    
    //MARK:- WKNavigationDelegate
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        loadingIndicator.startAnimating()
        loadingLabel.isHidden=false
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadingIndicator.stopAnimating()
        loadingLabel.isHidden=true
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        loadingIndicator.stopAnimating()
        loadingLabel.isHidden=true
    }

}
