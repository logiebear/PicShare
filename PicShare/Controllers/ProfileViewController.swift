//
//  ProfileViewController.swift
//  PicShare
//
//  Created by Logan Chang on 11/15/15.
//  Copyright © 2015 USC. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var profileImageView: PFImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let query = PFQuery(className: User.parseClassName())
        query.includeKey("owner")
        query.orderByDescending("createdAt")
        query.findObjectsInBackgroundWithBlock { [weak self](objects: [PFObject]?, error: NSError?) -> Void in
            
            if let error = error {
                print("Error: \(error) \(error.userInfo)")
                return
            }
            
            guard let users = objects as? [User] else {
                return
            }
            
            for user in users {
                if user.objectId == PFUser.currentUser()?.objectId {
                    self?.profileImageView.file = user.profilePhoto
                    self?.profileImageView.loadInBackground()
                }
            }
        }
    }

    @IBAction func logoutButtonPressed(sender: AnyObject) {
        PFUser.logOut()
        NSNotificationCenter.defaultCenter().postNotificationName(accountStatusChangedNotification, object: nil)
    }
    
}
