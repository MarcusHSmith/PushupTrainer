//
//  WorkoutViewController.swift
//  Pushup
//
//  Created by Marcus Smith on 12/5/14.
//  Copyright (c) 2014 Marcus Smith. All rights reserved.
//

import UIKit

class WorkoutViewController: ViewController {

    @IBOutlet weak var prescribedPushups: UITextField!
    @IBOutlet weak var accomplishedPushups: UITextField!

    
    @IBOutlet weak var setOne: UITextField!
    @IBOutlet weak var setTwo: UITextField!
    @IBOutlet weak var setThree: UITextField!
    @IBOutlet weak var setFour: UITextField!
    @IBOutlet weak var setFive: UITextField!

    var prescribed = 0;
    var accomplished = 0;
    var buttonDone = 0;
    
    var one = 0
    var two = 0
    var three = 0
    var four = 0
    var five = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prescribedPushups.text = String(prescribed)
        accomplishedPushups.text = String(accomplished)
        
        scheduler(prescribed)
        setOne.text = String(one)
        setTwo.text = String(two)
        setThree.text = String(three)
        setFour.text = String(four)
        setFive.text = String(five)
    }
    
    func refresh(){
        accomplishedPushups.text = String(accomplished)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBOutlet weak var buttonOne: UIButton!
    @IBAction func buttonOnePressed(sender: AnyObject) {
        if (buttonDone == 0){
            buttonOne.hidden = true
            accomplished += one
            refresh()
            buttonDone += 1
        }
    }
    
    @IBOutlet weak var buttonTwo: UIButton!
    @IBAction func buttonTwoPressed(sender: AnyObject) {
        if (buttonDone == 1){
            buttonTwo.hidden = true
            accomplished += two
            refresh()
            buttonDone += 1
        }
    }
    
    @IBOutlet weak var buttonThree: UIButton!
    @IBAction func buttonThreePressed(sender: AnyObject) {
        if (buttonDone == 2){
            buttonThree.hidden = true
            accomplished += three
            refresh()
            buttonDone += 1
        }
    }
    
    @IBOutlet weak var buttonFour: UIButton!
    @IBAction func buttonFourPressed(sender: AnyObject) {
        if (buttonDone == 3){
            buttonFour.hidden = true
            accomplished += four
            refresh()
            buttonDone += 1
        }
    }
    
    @IBOutlet weak var buttonFive: UIButton!
    @IBAction func buttonFivePressed(sender: AnyObject) {
        if (buttonDone == 4){
            buttonFive.hidden = true
            accomplished += five
            refresh()
            completeWorkout()
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
        completeWorkout()
    }
    
    func completeWorkout(){
        saveNewItem(accomplished, prescribed: prescribed)
        let storyBoard = UIStoryboard(name: "Main", bundle:nil)
        let home = storyBoard.instantiateViewControllerWithIdentifier("home") as ViewController
        self.presentViewController(home, animated: false, completion: nil)
    }
    
}
