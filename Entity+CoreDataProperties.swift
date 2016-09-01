//
//  Entity+CoreDataProperties.swift
//  nudgeapp
//
//  Created by Diana on 8/28/16.
//  Copyright © 2016 diana. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Entity {

    @NSManaged var location: String?
    @NSManaged var image: NSData?
    @NSManaged var entry: String?
    @NSManaged var date: NSDate?
    
    func dateAsSectionName() -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        let dateAsString = dateFormatter.stringFromDate(date!)
        return dateAsString
    }
    


}
