//
//  WorkoutItem.swift
//  Pushup
//
//  Created by Marcus Smith on 11/14/14.
//  Copyright (c) 2014 Marcus Smith. All rights reserved.
//

import Foundation
import CoreData

class WorkoutItem: NSManagedObject {

    @NSManaged var date: NSDate
    @NSManaged var accomplished: NSNumber
    @NSManaged var prescribed: NSNumber

    class func createInManagedObjectContext(moc: NSManagedObjectContext, date: NSDate, accomplished: NSNumber, prescribed: NSNumber) -> WorkoutItem {
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("WorkoutItem", inManagedObjectContext: moc) as WorkoutItem
        newItem.date = date
        newItem.accomplished = accomplished
        newItem.prescribed = prescribed
        return newItem
    }
}
