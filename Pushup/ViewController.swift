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
    
    // BASIC PARAMETERS
    var starting = 10
    var workoutInterval = 48
    var workoutIncrement = 3
    var initial = false
    var nextWorkoutPushups = 0
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
    
    var Workouts = [WorkoutItem]()

    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateUI:", name: "WorkoutTime", object: nil)
        fetchLog()
        
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
        if (recentTimer == 0){
            recentDays.text = "TODAY"
        } else {
            recentDays.text = "\(recentTimer)"
        }
        
        var timer = workoutInterval - cal.components(.CalendarUnitHour, fromDate: recentWorkout.date, toDate: NSDate(), options: nil).hour
        if (timer <= 0){
            countDown.text = "NOW"
        } else {
            countDown.text = "\(timer)"
        }
        
        scheduler(maxWorkout, recent: recentWorkout)
        pushupsPrescribed.text = "\(nextWorkoutPushups + workoutIncrement)"
        println("\(nextWorkoutPushups)")
        println("\(hoursSinceLastWorkout)")
        
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
    
    func scheduler(max: WorkoutItem, recent: WorkoutItem){
        fetchLog()
        
        nextWorkoutPushups = Int(max.accomplished)
        
        if (hoursSinceLastWorkout > workoutInterval){
            nextWorkoutPushups += workoutIncrement
        }
    }
    
    @IBAction func WorkoutPressed(sender: AnyObject) {
        let storyBoard = UIStoryboard(name: "Main", bundle:nil)
        let workoutView = storyBoard.instantiateViewControllerWithIdentifier("workoutView") as WorkoutViewController
        workoutView.prescribed = nextWorkoutPushups
        self.presentViewController(workoutView, animated: false, completion: nil)
    }
    
    @IBAction func infoPressed(sender: AnyObject) {
        let storyBoard = UIStoryboard(name: "Main", bundle:nil)
        let infoView = storyBoard.instantiateViewControllerWithIdentifier("infoView") as InfoViewController
        self.presentViewController(infoView, animated: false, completion: nil)
    }
}

