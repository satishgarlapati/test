//
//  DBManager.swift
//  GetYourRun
//
//  Created by Satish Garlapati on 8/22/16.
//  Copyright © 2016 Satish Reddy Garlapati. All rights reserved.
//

import UIKit
import CoreData

class DBManager: NSObject {
    class var sharedInstance: DBManager {
        struct Static {
            static let instance: DBManager = DBManager()
        }
        return Static.instance
    }
   
    func insertOrUpdateAPI(apiURL: String, isSuccess:Bool) -> Void {
        
        let appDel = UIApplication.shared.delegate as! AppDelegate
        
        let pred = NSPredicate(format: "apiURL == %@",apiURL)
        if getAPIHistory(predicate: pred).count == 0
        {
            let history = NSEntityDescription.insertNewObject(forEntityName: "APIHistory", into: appDel.managedObjectContext) as! APIHistory
            history.apiURL = apiURL
            history.isSuccess = isSuccess
            history.onDate = NSDate()
            do{
                try appDel.managedObjectContext.save()
            }catch let error as NSError{
                print("error saving core data: \(error)")
            }
        }
        
    }
    func getAPIHistory(predicate:NSPredicate?) -> Array<APIHistory> {
        let context = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
        let fetchRequest: NSFetchRequest<APIHistory> = APIHistory.fetchRequest()
        let entityDescription = NSEntityDescription.entity(forEntityName: "APIHistory", in: context)
        
        fetchRequest.entity = entityDescription
        if predicate != nil{
            fetchRequest.predicate = predicate//NSPredicate(format: "raceID == %@",raceID)

        }
        
        do {
            let result = try context.fetch(fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
            return result as! Array<APIHistory>
        } catch {
            let fetchError = error as NSError
            print(fetchError)
            return Array()
        }
    }
    func deleteRecordFromAPIHistory(objectToDelete: APIHistory) -> Bool {
        let context = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
        do {
            context.delete(objectToDelete)
            try context.save()
            return true
        } catch {
            let saveError = error as NSError
            print(saveError)
            return false
        }
    }
     /*
    func getTheRaceCount() -> Int {
        let context = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
        let fetchRequest: NSFetchRequest<Race> = Race.fetchRequest()
        do {
            let count = try context.count(for: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
            return count
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
            return 0
        }
    }
    func getSelectedRaceCount() -> Int {
        let context = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
        let fetchRequest: NSFetchRequest<Race> = Race.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isSelected = %@",NSNumber(value:true))
        do {
            let count = try context.count(for: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
            return count
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
            return 0
        }
    }
   */
}
