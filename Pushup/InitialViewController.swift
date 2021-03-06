//
//  InitialViewController.swift
//  Pushup
//
//  Created by Marcus Smith on 12/6/14.
//  Copyright (c) 2014 Marcus Smith. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController {

    var value = 20
    
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var stepper: UIStepper!
    @IBAction func stepperValueChanged(sender: UIStepper) {
        valueLabel.text = Int(sender.value).description
        value = Int(sender.value)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: 35/225, green: 35/225, blue: 35/225, alpha: 1)
        
        stepper.wraps = false
        stepper.minimumValue = 0
        stepper.autorepeat = true
        stepper.value = 20
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func Done(sender: AnyObject) {
        returnToHome()
    }
    
    func returnToHome(){
        let homeView = ViewController()
        homeView.saveNewItem(value, prescribed: value)
        let storyBoard = UIStoryboard(name: "Main", bundle:nil)
        let home = storyBoard.instantiateViewControllerWithIdentifier("home") as ViewController
        if (value < 0){
            value = 0
        }
        home.maxWorkoutPushups = value
        home.initial = true
        self.presentViewController(home, animated: false, completion: nil)
    }
}
