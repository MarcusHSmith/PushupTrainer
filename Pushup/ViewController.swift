//
//  ViewController.swift
//  Pushup
//
//  Created by Marcus Smith on 11/14/14.
//  Copyright (c) 2014 Marcus Smith. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    
    lazy var managedObjectContext : NSManagedObjectContext? = {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        if let managedObjectContext = appDelegate.managedObjectContext {
            return managedObjectContext
        }
        else {
            return nil
        }
    } ()
    
    var Workouts = [WorkoutItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println(managedObjectContext!)        
        
//        NSDateComponents *twoDays = [[NSDateComponents alloc] init];
//        twoDays.day = 2;
//        
//        NSCalendar *cal = [NSCalendar currentCalendar];
//        NSDate *inTwoDays = [cal dateByAddingComponents:twoDays
//        toDate:[NSDate date]
//        options:0];
//        
//        NSLog(@"two days from now: %@", nextDate);
//        
//        WorkoutItem.createInManagedObjectContext(self.managedObjectContext!, date: NSDate(), accomplished: 20, prescribed: 20)
//        WorkoutItem.createInManagedObjectContext(self.managedObjectContext!, date: NSDate(), accomplished: 17, prescribed: 17)
//        WorkoutItem.createInManagedObjectContext(self.managedObjectContext!, date: NSDate(), accomplished: 14, prescribed: 14)
//        WorkoutItem.createInManagedObjectContext(self.managedObjectContext!, date: NSDate(), accomplished: 11, prescribed: 11)
//        WorkoutItem.createInManagedObjectContext(self.managedObjectContext!, date: NSDate(), accomplished: 8, prescribed: 8)

        //saveNewItem( 69, prescribed: 72)

        fetchLog()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func presentItemInfo() {
        let fetchRequest = NSFetchRequest(entityName: "WorkoutItem")
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [WorkoutItem] {
            let alert = UIAlertView()
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd 'at' h:mm a" // superset of OP's format
            
            alert.title = "\(dateFormatter.stringFromDate(fetchResults[0].date))"
            alert.message = "\(fetchResults[0].accomplished) pushups accomplished"
            alert.show()
        }
    }

    func fetchLog() {
        let fetchRequest = NSFetchRequest(entityName: "WorkoutItem")
    
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [WorkoutItem] {
            Workouts = fetchResults
            
            
            //REMOVE Duplicates
//            var filter = Dictionary<NSDate,Int>()
//            var len = Workouts.count
//            for var index = 0; index < len  ;++index {
//                var value = Workouts[index].date
//                if (filter[value] != nil) {
//                    Workouts.removeAtIndex(index--)
//                    len--
//                }else{
//                    filter[value] = 1
//                    println(Workouts[index].date)
//                }
//            }
            var filter = Dictionary<NSNumber,Int>()
            var len = Workouts.count
            for var index = 0; index < len  ;++index {
                var value = Workouts[index].prescribed
                if (filter[value] != nil) {
                    Workouts.removeAtIndex(index--)
                    len--
                }else{
                    filter[value] = 1
                    println(Workouts[index].accomplished)
                    
                }
            }
        
        
        }
    }
    
    func saveNewItem(accomplished: NSNumber, prescribed : NSNumber) {
        // Create the new  log item
        var newLogItem = WorkoutItem.createInManagedObjectContext(self.managedObjectContext!, date: NSDate(), accomplished: accomplished, prescribed: prescribed)

        self.fetchLog()
        
        if let newItemIndex = find(Workouts, newLogItem) {
            let newLogItemPath = NSIndexPath(forRow: newItemIndex, inSection: 0)
            save()
        }

    }
    
    func save() {
        println("SAVING");
        var error : NSError?
        if(managedObjectContext!.save(&error)){
            println(error?.localizedDescription)
        }
    }

    @IBAction func WorkoutPressed(sender: AnyObject) {
        let storyBoard = UIStoryboard(name: "Main", bundle:nil)
        let workoutView = storyBoard.instantiateViewControllerWithIdentifier("workoutView") as WorkoutViewController
        workoutView.prescribed = 11
        self.presentViewController(workoutView, animated: false, completion: nil)
        //self.navigationController?.pushViewController(workoutView, animated: true)
    }
}

