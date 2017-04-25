//
//  webviewController.swift
//  CloudMan
//
//  Created by Satish Garlapati on 01/17/17.
//  Copyright © 2017 Satish Garlapati. All rights reserved.
//

import UIKit

class webviewController: UIViewController {

    var apiURL : String!
    
    @IBOutlet weak var webview: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "API Info"
        webview.loadRequest(NSURLRequest(url: NSURL(string: apiURL)! as URL) as URLRequest)
        // Do any additional setup after loading the view.
    }
}
