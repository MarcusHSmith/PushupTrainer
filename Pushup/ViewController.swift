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
    @IBOutlet weak var maxDays: UITextField!
    @IBOutlet weak var maxAccomplished: UITextField!
    @IBOutlet weak var recentDays: UITextField!
    @IBOutlet weak var recentAccomplished: UITextField!
    @IBOutlet weak var countDown: UITextField!
    @IBOutlet weak var pushupsPrescribed: UITextField!
    
    var Workouts = [WorkoutItem]()
    let healthManager:HealthManager = HealthManager()
    
    // BASIC PARAMETERS
    var workoutInterval = 48
    var workoutIncrement = 3
    var initial = false
    var maxWorkoutPushups = 0
    var hoursSinceLastWorkout = 0
    
    lazy var managedObjectContext : NSManagedObjectContext? = {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        if let managedObjectContext = appDelegate.managedObjectContext {
            return managedObjectContext
        }
        else {
            return nil
        }
    } ()

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchLog()
    }
    
    
    override func viewDidAppear(animated: Bool) {
        // Home Screen UI
        self.view.backgroundColor = UIColor(red: 35/225, green: 35/225, blue: 35/225, alpha: 1)
        var titleImage = UIImage(named: "pushupTitle")
        self.imageTitle.image = titleImage
        var goImage = UIImage(named: "WorkoutNow")
        self.imageGo.setBackgroundImage(goImage, forState: .Normal)
        
        fetchLog()
        if (Workouts.count == 0 && initial == false){
            // Initial Application Launch
            let storyBoard = UIStoryboard(name: "Main", bundle:nil)
            let initialView = storyBoard.instantiateViewControllerWithIdentifier("initialView") as InitialViewController
            self.presentViewController(initialView, animated: false, completion: nil)
        } else {
            // Homescreen USER Statistics
            var recentWorkout: WorkoutItem = Workouts[0]
            var maxWorkout: WorkoutItem = recentWorkout
            var userMax: NSNumber = 0
            for day in Workouts {
                if (Int(day.accomplished) > Int(userMax)) {
                    userMax = day.accomplished
                    maxWorkout = day
                }
            }
            let cal = NSCalendar.currentCalendar()
            maxAccomplished.text = "\(maxWorkout.accomplished)"
            recentAccomplished.text = "\(recentWorkout.accomplished)"
            maxDays.text = "\(cal.components(.CalendarUnitDay, fromDate: maxWorkout.date, toDate: NSDate(), options: nil).day)"
            hoursSinceLastWorkout = cal.components(.CalendarUnitHour, fromDate: recentWorkout.date, toDate: NSDate(), options: nil).hour
            var recentTimer = cal.components(.CalendarUnitDay, fromDate: recentWorkout.date, toDate: NSDate(), options: nil).day
            if (recentTimer == 0) {
                recentDays.text = "TODAY"
            } else {
                recentDays.text = "\(recentTimer)"
            }
            var maxTimer = cal.components(.CalendarUnitDay, fromDate: maxWorkout.date, toDate: NSDate(), options: nil).day
            if (maxTimer == 0) {
                maxDays.text = "TODAY"
            } else {
                maxDays.text = "\(maxTimer)"
            }
            var timer = workoutInterval - cal.components(.CalendarUnitHour, fromDate: maxWorkout.date, toDate: NSDate(), options: nil).hour
            if (timer <= 0) {
                countDown.text = "NOW"
            } else {
                countDown.text = "\(timer)"
            }
            pushupsPrescribed.text = "\(maxWorkoutPushups + workoutIncrement)"
            authorizeHealthKit()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
                maxWorkoutPushups = max(Int(Workouts[index].accomplished) , maxWorkoutPushups)
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
        // printing nil for some reason
        if(managedObjectContext!.save(&error)){
            println(error?.localizedDescription)
        }
    }
    
    func scheduler() -> Int {
        fetchLog()
        if (hoursSinceLastWorkout > workoutInterval){
            return maxWorkoutPushups + workoutIncrement
        } else {
            return maxWorkoutPushups
        }
    }
    
    @IBAction func WorkoutPressed(sender: AnyObject) {
        let storyBoard = UIStoryboard(name: "Main", bundle:nil)
        let workoutView = storyBoard.instantiateViewControllerWithIdentifier("workoutView") as WorkoutViewController
        workoutView.prescribed = scheduler()
        workoutView.healthManager = healthManager
        self.presentViewController(workoutView, animated: false, completion: nil)
    }
    
    @IBAction func infoPressed(sender: AnyObject) {
        let storyBoard = UIStoryboard(name: "Main", bundle:nil)
        let infoView = storyBoard.instantiateViewControllerWithIdentifier("infoView") as InfoViewController
        self.presentViewController(infoView, animated: false, completion: nil)
    }
    
    func authorizeHealthKit() {
        healthManager.authorizeHealthKit { (authorized,  error) -> Void in
            if authorized {
                println("HealthKit authorization received.")
            }
            else
            {
                println("HealthKit authorization denied!")
                if error != nil {
                    println("\(error)")
                }
            }
        }
    }
}