//
//  AboutViewController.swift
//  CloudMan
//
//  Created by Satish Reddy Garlapati on 4/25/17.
//  Copyright © 2017 Satish Garlapati. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

    var receivedVersion = ""
    @IBOutlet weak var versionLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        versionLbl.text = "Version: \(receivedVersion)"
    }
}
