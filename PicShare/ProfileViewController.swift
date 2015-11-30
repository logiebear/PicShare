//
//  ProfileViewController.swift
//  PicShare
//
//  Created by Logan Chang on 11/15/15.
//  Copyright © 2015 USC. All rights reserved.
//

import UIKit
import Parse

class ProfileViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func logoutButtonPressed(sender: AnyObject) {
        PFUser.logOut()
        NSNotificationCenter.defaultCenter().postNotificationName(accountStatusChangedNotification, object: nil)
    }
    
}
