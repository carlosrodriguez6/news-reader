//
//  DetailViewController.swift
//  CoreDataOne
//
//  Created by Carlos Rodriguez on 4/27/18.
//  Copyright © 2018 Carlos Rodriguez. All rights reserved.
//

import UIKit
import WebKit

class DetailViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    
    @IBOutlet weak var loadIndicator: UIActivityIndicatorView!
    @IBOutlet weak var detailWebView: WKWebView!
    
    var contentURL: String?
    
    func configureView() {
        
        if let detailWebView = detailWebView {
            if let urlString = contentURL, let url = URL(string: urlString) {
                let request = NSURLRequest(url: url) as URLRequest
                detailWebView.load(request)
                loadIndicator.startAnimating()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        detailWebView.uiDelegate = self
        detailWebView.navigationDelegate = self
        loadIndicator.activityIndicatorViewStyle = .whiteLarge
        configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

extension DetailViewController {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadIndicator.stopAnimating()
    }
}

