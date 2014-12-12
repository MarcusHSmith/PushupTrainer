//
//  InfoViewController.swift
//  Pushup
//
//  Created by Marcus Smith on 12/12/14.
//  Copyright (c) 2014 Marcus Smith. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {


    @IBOutlet weak var imageTitle: UIImageView!
    @IBOutlet weak var infoText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override func viewDidAppear(animated: Bool) {
        self.view.backgroundColor = UIColor(red: 35/225, green: 35/225, blue: 35/225, alpha: 1)
        
        var titleImage = UIImage(named: "pushupTitle")
        self.imageTitle.image = titleImage
        
        var info = "Pushup Trainer by Marcus Smith (@_mhsmith_)\n\n- Input max pushups on initial launch\n- Pushups are split into sets and ready for a workout\n- Complete each set and click DONE to progress\n- RETREAT if you can't finish all the sets\n- After the 5th set the workout is complete\n- 2 days later the app will alert you to workout again\n- Repeat and Improve"
        infoText.text = info
        
        infoText.textColor = UIColor(red: 253/255, green: 255/255, blue: 60/255, alpha: 1)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func returnPressed(sender: AnyObject) {
        var homeView = ViewController()
        let storyBoard = UIStoryboard(name: "Main", bundle:nil)
        let home = storyBoard.instantiateViewControllerWithIdentifier("home") as ViewController
        self.presentViewController(home, animated: false, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
