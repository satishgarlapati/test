//
//  HistoryVC.swift
//  CloudMan
//
//  Created by Geetha Balu on 08/12/16.
//  Copyright © 2016 Satish Garlapati. All rights reserved.
//

import UIKit
import CoreData

class HistoryVC: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var viTblHistory: UITableView!

    
    var managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    
    //var arrAPIHistory : [String]!
    
    var arrAPIHistory : [String] = ["API History 1", "API History 2", "API History 3"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //let strava = UIBarButtonItem(title: "Strava", style: .done, target: self, action: #selector(stravaBtnClicked))
        //self.navigationItem.rightBarButtonItem = strava
        //self.title = "Home"
        viTblHistory.tableFooterView = UIView()
        
        
        viTblHistory.dataSource = self
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return arrAPIHistory.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        tableView.deselectRow(at: indexPath, animated: true)

        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for:indexPath)
        cell.textLabel?.text = arrAPIHistory[indexPath.row]
        return cell
    }
    
    
}

