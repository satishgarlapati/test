//
//  webviewController.swift
//  CloudMan
//
//  Created by Geetha Balu on 17/01/17.
//  Copyright © 2017 Satish Garlapati. All rights reserved.
//

import UIKit

class webviewController: UIViewController {

    var apiURL : String!
    
    
    @IBOutlet weak var webview: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "API Info"
        webview.loadRequest(NSURLRequest(url: NSURL(string: apiURL) as! URL) as URLRequest)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
