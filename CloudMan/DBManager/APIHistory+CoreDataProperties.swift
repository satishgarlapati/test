//
//  APIHistory+CoreDataProperties.swift
//  
//
//  Created by Satish Garlapati on 01/17/17.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension APIHistory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<APIHistory> {
        return NSFetchRequest<APIHistory>(entityName: "APIHistory");
    }

    @NSManaged public var apiURL: String?
    @NSManaged public var isSuccess: Bool
    @NSManaged public var onDate: NSDate?

}
