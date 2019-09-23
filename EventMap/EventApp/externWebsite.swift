//
//  externWebsite.swift
//  app_1
//
//  Created by BACHIR-CHERIF Mohamed on 30/11/2017.
//  Copyright © 2017 BACHIR-CHERIF Mohamed. All rights reserved.
//

import UIKit

class externWebsite: UIViewController, UIWebViewDelegate {
   
    var webView : UIWebView?
    var requestUrl : URLRequest?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //webView?.scrollView.bounces = false
        webView?.scrollView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 44.0, 0.0)
        webView?.loadRequest(requestUrl!)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func loadView() {
        super.loadView()
        
        webView = UIWebView(frame: view.bounds)
        webView!.delegate = self
        view.addSubview(webView!)
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        switch navigationType {
        case .linkClicked:
            
            // Open links in Safari
            guard let newRequest = request as? URLRequest else { return false }
            
            webView.loadRequest(newRequest)
            return false
            
        default:
            // Handle other navigation types...
            return true
        }
    }
}
