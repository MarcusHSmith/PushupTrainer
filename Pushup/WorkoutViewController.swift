//
//  WorkoutViewController.swift
//  Pushup
//
//  Created by Marcus Smith on 12/5/14.
//  Copyright (c) 2014 Marcus Smith. All rights reserved.
//

import UIKit

class WorkoutViewController: UIViewController {

    @IBOutlet weak var prescribedPushups: UITextField!

    var prescribed = 0;
    var accomplished = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println(prescribed)
        prescribedPushups.text = String(prescribed)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func CompletePressed(sender: AnyObject) {
        let storyBoard = UIStoryboard(name: "Main", bundle:nil)
        let home = storyBoard.instantiateViewControllerWithIdentifier("home") as ViewController
        self.presentViewController(home, animated: false, completion: nil)

    }

    
}
