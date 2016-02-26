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
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userInfoImageView: UIView!
    @IBOutlet weak var userInfoImageViewHeight: NSLayoutConstraint!
    
    private var modifyButtonsVisible = false
    
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

                    if let frame = self?.profileImageView.frame {
                        self?.profileImageView.layer.cornerRadius = frame.height/2
                        self?.profileImageView.clipsToBounds = true
                    }

                    if let username = user.username {
                        self?.usernameLabel.text = String(username)
                    }
                }
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if (modifyButtonsVisible) {
            hideButtons()
        }
    }
    
    private func hideButtons() {
//        print("Visible. Size of superview: \(self.userInfoImageView.frame.size.height)")
//        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.height
//        self.profileImageView.frame.size.height = self.profileImageView.frame.size.height*2
//        self.profileImageView.frame.size.width = self.profileImageView.frame.size.width*2
//        self.userInfoImageView.frame.size.height = self.userInfoImageView.frame.size.height*2
//        print("Hiding. Size of superview: \(self.userInfoImageView.frame.size.height)")
        self.userInfoImageViewHeight.constant = 300
        UIView.animateWithDuration(0.5) {
            self.view.layoutIfNeeded()
        }
        modifyButtonsVisible = false
    }
    
    private func showButtons() {
//        print("Hidden. Size of superview: \(self.userInfoImageView.frame.size.height)")
//        self.profileImageView.frame.size.height = self.profileImageView.frame.size.height/2
//        self.profileImageView.frame.size.width = self.profileImageView.frame.size.width/2
//        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.height/2
//        self.userInfoImageView.frame.size.height = self.userInfoImageView.frame.size.height/2
//          print("Visifying. Size of superview: \(self.userInfoImageView.frame.size.height)")
        self.userInfoImageViewHeight.constant = 150
        UIView.animateWithDuration(0.5) {
            self.view.layoutIfNeeded()
        }
        modifyButtonsVisible = true
    }

    @IBAction func logoutButtonPressed(sender: AnyObject) {
        PFUser.logOut()
        NSNotificationCenter.defaultCenter().postNotificationName(accountStatusChangedNotification, object: nil)
    }
    
   
    @IBAction func profilePhotoTapped(sender: UITapGestureRecognizer) {
        // Things I need to do
        // 1. Toggle photo size between large and less large
        if (modifyButtonsVisible) {
            hideButtons()

        } else {
            showButtons()
        }
        // 2. Toggle three buttons visible or not visible
    }
}
