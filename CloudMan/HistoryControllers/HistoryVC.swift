//
//  HistoryVC.swift
//  CloudMan
//
//  Created by Geetha Balu on 08/12/16.
//  Copyright © 2016 Satish Garlapati. All rights reserved.
//

import UIKit
import CoreData

protocol HistoryApiSelectionDelegate {
    func goForSelectedAPI(_ apiURL: String)
}

class HistoryVC: UIViewController,UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var viTblHistory: UITableView!
    var managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext

    var delegate : HistoryApiSelectionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //let strava = UIBarButtonItem(title: "Strava", style: .done, target: self, action: #selector(stravaBtnClicked))
        //self.navigationItem.rightBarButtonItem = strava
        //self.title = "Home"
        viTblHistory.tableFooterView = UIView()
        viTblHistory.dataSource = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("An error occurred")
        }
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController<APIHistory> = {
        let fetchRequest: NSFetchRequest<APIHistory> = APIHistory.fetchRequest()
        let fetchSort = NSSortDescriptor(key: "onDate", ascending: false)
        fetchRequest.sortDescriptors = [fetchSort]
        let fRC : NSFetchedResultsController  = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        fRC.delegate = self
        return fRC
    }()
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if let sections = fetchedResultsController.sections {
            let currentSection = sections[section]
            return currentSection.numberOfObjects
        }
        return 0
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        tableView.deselectRow(at: indexPath, animated: true)

        if let delegate = delegate {
            let apiHistory = fetchedResultsController.object(at:indexPath)
            delegate.goForSelectedAPI(apiHistory.apiURL!)
            _ = navigationController?.popViewController(animated: true)
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for:indexPath)
        let apiHistory = fetchedResultsController.object(at:indexPath)
        
        cell.textLabel?.text = apiHistory.apiURL
        cell.detailTextLabel?.text = apiHistory.isSuccess ? "Success" : "Failed"
        return cell
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            
            let apiHistory = fetchedResultsController.object(at:indexPath)
            let isDeleted = DBManager.sharedInstance.deleteRecordFromAPIHistory(objectToDelete: apiHistory)
            if isDeleted{
                fetchedResultsController.fetchRequest.predicate = nil;
                do {
                    try fetchedResultsController.performFetch()
                    viTblHistory.reloadData()
                } catch {
                    print("An error occurred")
                }
            }
            
           
        }
    }
}
/*
 let alertController = UIAlertController(title: "CloudMan", message: "You can view the API in webview, Do you want to open in webview ?", preferredStyle: .alert)
 
 let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .default) { action -> Void in
 //Just dismiss the action sheet
 }
 alertController.addAction(cancelAction)
 
 let openAction: UIAlertAction = UIAlertAction(title: "Open", style: .destructive) { action -> Void in
 self.performSegue(withIdentifier: "webviewController", sender:self)
 }
 alertController.addAction(openAction)
 self.present(alertController, animated: true, completion: nil)
 */
//if !self.canOpenURL(url: self.textField.text!){}

