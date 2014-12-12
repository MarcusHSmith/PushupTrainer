//
//  ViewController.swift
//  Pushup
//
//  Created by Marcus Smith on 11/14/14.
//  Copyright (c) 2014 Marcus Smith. All rights reserved.
//

import UIKit
import CoreData
import Foundation

class ViewController: UIViewController {
    
    @IBOutlet weak var imageTitle: UIImageView!
    @IBOutlet weak var imageGo: UIButton!
    
    // BASIC PARAMETERS
    var starting = 10
    var initial = false
    
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateUI:", name: "WorkoutTime", object: nil)
        fetchLog()
    }
    
    
    override func viewDidAppear(animated: Bool) {
        self.view.backgroundColor = UIColor(red: 35/225, green: 35/225, blue: 35/225, alpha: 1)
        
        var titleImage = UIImage(named: "pushupTitle")
        self.imageTitle.image = titleImage
        
        var goImage = UIImage(named: "GO")
        self.imageGo.setBackgroundImage(goImage, forState: .Normal)

        fetchLog()
        
        if (Workouts.count == 0 && initial == false){
            let storyBoard = UIStoryboard(name: "Main", bundle:nil)
            let initialView = storyBoard.instantiateViewControllerWithIdentifier("initialView") as InitialViewController
            self.presentViewController(initialView, animated: false, completion: nil)
        }
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
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let fetchResults = managedObjectContext!.executeFetchRequest(fetchRequest, error: nil) as? [WorkoutItem] {
            Workouts = fetchResults
            //REMOVE Duplicates
            var filter = Dictionary<NSDate,Int>()
            var len = Workouts.count
            for var index = 0; index < len  ;++index {
                var value = Workouts[index].date
                if (filter[value] != nil) {
                    Workouts.removeAtIndex(index--)
                    len--
                }else{
                    filter[value] = 1
                }
            }
        }
    }
    
    func saveNewItem(accomplished : NSNumber, prescribed : NSNumber) {
        var newLogItem = WorkoutItem.createInManagedObjectContext(self.managedObjectContext!, date: NSDate(), accomplished: accomplished, prescribed: prescribed)
        fetchLog()
        if let newItemIndex = find(Workouts, newLogItem) {
            let newLogItemPath = NSIndexPath(forRow: newItemIndex, inSection: 0)
            save()
        }
    }
    
    func save() {
        var error : NSError?
        if(managedObjectContext!.save(&error)){
            println(error?.localizedDescription)
        }
    }
    
    func scheduler() -> Int{
        fetchLog()
        
        var lastPrescribed: NSNumber = starting
        var lastAccomplished: NSNumber = starting
        var lastDate = NSDate()
        var assigned = 0
        let cal = NSCalendar.currentCalendar()
        let unit:NSCalendarUnit = .DayCalendarUnit
        var i = 0
        
        while (i < Workouts.count && cal.components(.CalendarUnitDay, fromDate: Workouts[i].date, toDate: NSDate(), options: nil).day < 2){
            if (Int(Workouts[i].accomplished) > Int(lastAccomplished)){
                lastAccomplished = Int(Workouts[i].accomplished)
                lastDate = Workouts[i].date
                lastPrescribed = Workouts[i].prescribed
            } else if (Int(Workouts[i].accomplished) == Int(lastAccomplished)){
                lastDate = Workouts[i].date
            }
            i++
        }
        
        let components = cal.components(.CalendarUnitDay, fromDate: lastDate, toDate: NSDate(), options: nil)
        if (components.day > 1){
            return Int(lastAccomplished) + 3
        } else {
            return Int(lastPrescribed)
        }
    }
    
    @IBAction func WorkoutPressed(sender: AnyObject) {
        let storyBoard = UIStoryboard(name: "Main", bundle:nil)
        let workoutView = storyBoard.instantiateViewControllerWithIdentifier("workoutView") as WorkoutViewController
        workoutView.prescribed = scheduler()
        self.presentViewController(workoutView, animated: false, completion: nil)
    }
    
    @IBAction func infoPressed(sender: AnyObject) {
        let storyBoard = UIStoryboard(name: "Main", bundle:nil)
        let infoView = storyBoard.instantiateViewControllerWithIdentifier("infoView") as InfoViewController
        self.presentViewController(infoView, animated: false, completion: nil)
    }
}

