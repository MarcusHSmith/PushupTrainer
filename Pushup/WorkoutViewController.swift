//
//  WorkoutViewController.swift
//  Pushup
//
//  Created by Marcus Smith on 12/5/14.
//  Copyright (c) 2014 Marcus Smith. All rights reserved.
//

import UIKit
import HealthKit

class WorkoutViewController: UIViewController {

    @IBOutlet weak var prescribedPushups: UITextField!
    @IBOutlet weak var accomplishedPushups: UITextField!
    @IBOutlet weak var complete: UIButton!

    @IBOutlet weak var setOne: UITextField!
    @IBOutlet weak var setTwo: UITextField!
    @IBOutlet weak var setThree: UITextField!
    @IBOutlet weak var setFour: UITextField!
    @IBOutlet weak var setFive: UITextField!
    
    @IBOutlet weak var buttonOne: UIButton!
    @IBOutlet weak var buttonTwo: UIButton!
    @IBOutlet weak var buttonThree: UIButton!
    @IBOutlet weak var buttonFour: UIButton!
    @IBOutlet weak var buttonFive: UIButton!

    
    var healthManager:HealthManager?
    var workouts = [HKWorkout]()
    var startDate = NSDate()
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var prescribed = 0
    var accomplished = 0
    var buttonDone = 0
    
    var one = 0
    var two = 0
    var three = 0
    var four = 0
    var five = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: 35/225, green: 35/225, blue: 35/225, alpha: 1)
        complete.setTitle("Retreat", forState: UIControlState.Normal)
        
        self.prescribedPushups.text = String(prescribed)
        self.accomplishedPushups.text = String(accomplished)
        
        scheduler(prescribed)
        
        // shift right by one set if flux is zero
        if (five == 0) {
            five = four
            four = three
            three = two
            two = one
            one = 0
        }
        
        setOne.text = String(one)
        setTwo.text = String(two)
        setThree.text = String(three)
        setFour.text = String(four)
        setFive.text = String(five)
        
        buttonTwo.hidden = true
        buttonThree.hidden = true
        buttonFour.hidden = true
        buttonFive.hidden = true
        
        if (one == 0){
            buttonOnePressed(self)
        }
        if (two == 0){
            buttonTwoPressed(self)
        }
        if (three == 0){
            buttonThreePressed(self)
        }
        if (four == 0){
            buttonFourPressed(self)
        }
        if (five == 0){
            buttonFivePressed(self)
        }
    }
    
    func refresh(){
        self.accomplishedPushups.text = String(accomplished)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func buttonOnePressed(sender: AnyObject) {
        if (buttonDone == 0){
            buttonOne.hidden = true
            accomplished += one
            refresh()
            buttonDone += 1
            buttonTwo.hidden = false
        }
    }
    
    @IBAction func buttonTwoPressed(sender: AnyObject) {
        if (buttonDone == 1){
            buttonTwo.hidden = true
            accomplished += two
            refresh()
            buttonDone += 1
            buttonThree.hidden = false
        }
    }
    
    @IBAction func buttonThreePressed(sender: AnyObject) {
        if (buttonDone == 2){
            buttonThree.hidden = true
            accomplished += three
            refresh()
            buttonDone += 1
            buttonFour.hidden = false
        }
    }
    
    @IBAction func buttonFourPressed(sender: AnyObject) {
        if (buttonDone == 3){
            buttonFour.hidden = true
            accomplished += four
            refresh()
            buttonDone += 1
            buttonFive.hidden = false
        }
    }
    
    @IBAction func buttonFivePressed(sender: AnyObject) {
        if (buttonDone == 4){
            buttonFive.hidden = true
            accomplished += five
            refresh()
            concludeWorkout()
        }
    }

    func scheduler(pushups: Int){
        var fives = pushups / 5
        var base = fives / 5
        var build1 = base
        var build2 = base
        var build3 = base
        var flux = base
        if (fives - base * 5 == 1){
            build3 += 1
        }
        if (fives - base * 5 >= 2){
            build2 += 1
            build3 += 1
        }
        if (fives - base * 5 >= 3){
            flux += 1
        }
        if (fives - base * 5 == 4){
            build1 += 1
        }
        build1 = 5 * build1
        build2 = 5 * build2
        build3 = 5 * build3
        flux = 5 * flux
        base = 5 * base
        flux += pushups % 5
        one = base
        two = build1
        three = build2
        four = build3
        five = flux
    }
    
    @IBAction func CompletePressed(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateUI:", name: "WorkoutTime", object: nil)
        concludeWorkout()
    }
    
    func concludeWorkout(){
        // kiloCalories can't be set to nil ???
        self.healthManager?.savePushupWorkout(startDate, endDate: NSDate(), pushups: Double(accomplished), kiloCalories: 100, completion: { (success, error ) -> Void in
            if( success ) {
                println("Workout saved!")
            } else if ( error != nil ) {
                println("\(error)")
            }
        })
        var homeView = ViewController()
        homeView.fetchLog()
        if (homeView.maxWorkoutPushups < accomplished){
            scheduleNotification()
            defaults.setObject(timeToNextWorkout(), forKey: "nextWorkoutDate")
        } else {
            defaults.setObject(timeToRepeatWorkout(), forKey: "nextWorkoutDate")
        }
        homeView.saveNewItem(accomplished, prescribed: prescribed)
        
        var time = NSDate()
        if var next: AnyObject = defaults.objectForKey("nextWorkoutDate"){
            time = next as NSDate
        }
        
        var offGMT = NSTimeZone.localTimeZone().secondsFromGMT
        // Next workout date
        var nextWorkout = time.dateByAddingTimeInterval(Double(offGMT))
        let dateString = dateformatterDate(nextWorkout)
        println("date: \(dateString)")
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let dayOfWeekString = dateFormatter.stringFromDate(nextWorkout)
        println("date: \(dayOfWeekString)")
        var alert = UIAlertController(title: "Workout Completed!", message: "Next workout is on \(dayOfWeekString)", preferredStyle: UIAlertControllerStyle.Alert)
        var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
            UIAlertAction in
            self.returnHome()
        }
        alert.addAction(okAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    func returnHome(){
        let storyBoard = UIStoryboard(name: "Main", bundle:nil)
        let home = storyBoard.instantiateViewControllerWithIdentifier("home") as ViewController
        self.presentViewController(home, animated: false, completion: nil)
    }
    

    
    
    func readHealthKitData() {
        healthManager?.readPushupWorkOuts({ (results, error) -> Void in
            if( error != nil )
            {
                println("Error reading workouts: \(error.localizedDescription)")
                return;
            }
            else
            {
                println("Workouts read successfully!  \(results)")
            }
        })
    }
    
    func scheduleNotification() {
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        let notification = UILocalNotification()
        notification.alertBody = "Hey! Time to Workout"
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.fireDate = timeToNextWorkout()
        notification.repeatInterval = NSCalendarUnit.CalendarUnitDay
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    func timeToNextWorkout() -> NSDate {
        var date = NSDate()
        var offGMT = NSTimeZone.localTimeZone().secondsFromGMT
        date = date.dateByAddingTimeInterval(Double(offGMT))
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.CalendarUnitHour | .CalendarUnitMinute, fromDate: NSDate())
        let hour = components.hour
        let minutes = components.minute
        let subHour = hour - 9 // Notification for 9 AM
        date = NSCalendar.currentCalendar().dateByAddingUnit(.CalendarUnitDay, value: 2, toDate: date, options: nil)!
        date = date.dateByAddingTimeInterval(60 * ( Double(-minutes)))
        date = date.dateByAddingTimeInterval(60 * 60 * Double(-subHour))
        //reset back to GMT
        date = date.dateByAddingTimeInterval(Double(-offGMT))
        return date
    }
    
    func timeToRepeatWorkout() -> NSDate {
        var date = NSDate()
        var offGMT = NSTimeZone.localTimeZone().secondsFromGMT
        date = date.dateByAddingTimeInterval(Double(offGMT))
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.CalendarUnitHour | .CalendarUnitMinute, fromDate: NSDate())
        let hour = components.hour
        let minutes = components.minute
        let subHour = hour - 9 // Notification for 9 AM
        date = NSCalendar.currentCalendar().dateByAddingUnit(.CalendarUnitDay, value: 1, toDate: date, options: nil)!
        date = date.dateByAddingTimeInterval(60 * ( Double(-minutes)))
        date = date.dateByAddingTimeInterval(60 * 60 * Double(-subHour))
        //reset back to GMT
        date = date.dateByAddingTimeInterval(Double(-offGMT))
        return date
    }
    
    func addHours(date: NSDate, additionalHours: Int) -> NSDate {
        var components = NSDateComponents()
        components.hour = additionalHours
        let futureDate = NSCalendar.currentCalendar()
            .dateByAddingComponents(components, toDate: date, options: NSCalendarOptions(0))
        return futureDate!
    }
    
    func dateformatterDate(date: NSDate) -> NSString {
        var dateFormatter: NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
        
        return dateFormatter.stringFromDate(date)
        
    }
}
