//
//  HistoryVC.swift
//  CloudMan
//
//  Created by Satish Garlapati on 12/8/16.
//  Copyright © 2016 Satish Garlapati. All rights reserved.
//

import UIKit
import CoreData

protocol HistoryApiSelectionDelegate {
    func goForSelectedAPI(_ apiURL: String)
}

class HistoryVC: UIViewController,UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, UIActionSheetDelegate, UIAlertViewDelegate {
    
    @IBOutlet weak var viTblHistory: UITableView!
    var managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext

    var delegate : HistoryApiSelectionDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        viTblHistory.tableFooterView = UIView()
        viTblHistory.dataSource = self
        viTblHistory.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("An error occurred")
        }
    }
    
    @IBAction func getFromCloudBtnTapped(_ sender: Any) {
        let menu = UIAlertController(title: "Please enter your Client ID", message: "Your entry is case sensitive", preferredStyle: .alert)
        menu.addTextField { (UITextField) in
            UITextField.text = menu.textFields?.first?.text
        }
        let option1 = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
            if menu.textFields?.first?.text == "Client1" ||
                menu.textFields?.first?.text == "Client2" ||
                menu.textFields?.first?.text == "Client3" {
                self.getClientDetails(clientName:(menu.textFields?.first?.text)!)
            }
        }
        let option2 = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
        }

        menu.addAction(option1)
        menu.addAction(option2)
        self.present(menu, animated: true, completion: nil)
    }
    
    func getClientDetails(clientName: String) {
        var urls = [String]()
        let filePath = Bundle.main.path(forResource: clientName, ofType: "Json")
        let JSONData: NSData? = NSData(contentsOfFile: filePath!)
        do {
            DBManager.sharedInstance.deleteAll()
            let JSONArray = try JSONSerialization.jsonObject(with: JSONData! as Data, options:JSONSerialization.ReadingOptions(rawValue: 0)) as! [String:Any]
            let urlDetails = JSONArray["urlArray"] as! [[String:Any]]
            
            for url in urlDetails{
                if let urlString = url["url"] as? String {
                        urls.append(urlString)
                }
            }
            for i in 0..<urls.count{
                DBManager.sharedInstance.insertOrUpdateAPI(apiURL: urls[i], isSuccess: true)
            }
            updateTableviewAfterInsertionOrDelete()
        }
        catch let JSONError as NSError {
            print("\(JSONError)")
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
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
                updateTableviewAfterInsertionOrDelete()
            }
        }
    }
    
    func updateTableviewAfterInsertionOrDelete()
    {
        fetchedResultsController.fetchRequest.predicate = nil;
        do {
            try fetchedResultsController.performFetch()
            viTblHistory.reloadData()
        } catch {
            print("An error occurred")
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

