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
    @IBOutlet weak var userInfoImageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var profileImageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var profileImageViewWidth: NSLayoutConstraint!
    @IBOutlet weak var usernameLabelTopSpacing: NSLayoutConstraint!
    @IBOutlet weak var usernameLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var removePhotoButton: UIView!
    @IBOutlet weak var takePhotoButton: UIView!
    @IBOutlet weak var cameraRollButton: UIView!
    
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
        self.userInfoImageViewHeight.constant = 391
        self.profileImageViewHeight.constant = 300
        self.profileImageViewWidth.constant = 300
        self.usernameLabelTopSpacing.constant = 20
        self.usernameLabelHeight.constant = 30
        
        UIView.animateWithDuration(0.5) {
            self.usernameLabel.font = UIFont.boldSystemFontOfSize(24)
            self.profileImageView.layer.cornerRadius = 150
            self.cameraRollButton.hidden = true
            self.removePhotoButton.hidden = true
            self.takePhotoButton.hidden = true
            self.view.layoutIfNeeded()
        }
        modifyButtonsVisible = false
    }
    
    private func showButtons() {
        self.userInfoImageViewHeight.constant = 150
        self.profileImageViewHeight.constant = 100
        self.profileImageViewWidth.constant = 100
        self.usernameLabelTopSpacing.constant = 7
        self.usernameLabelHeight.constant = 15
        
        UIView.animateWithDuration(0.5) {
            self.profileImageView.layer.cornerRadius = 50
            self.usernameLabel.font = UIFont.boldSystemFontOfSize(12)
            self.cameraRollButton.hidden = false
            self.removePhotoButton.hidden = false
            self.takePhotoButton.hidden = false
            self.view.layoutIfNeeded()
        }
        modifyButtonsVisible = true
    }

    @IBAction func logoutButtonPressed(sender: AnyObject) {
        PFUser.logOut()
        NSNotificationCenter.defaultCenter().postNotificationName(accountStatusChangedNotification, object: nil)
    }
    
   
    @IBAction func profilePhotoTapped(sender: UITapGestureRecognizer) {
        if (modifyButtonsVisible) {
            hideButtons()
        } else {
            showButtons()
        }
    }
    
    @IBAction func removePhotoButtonTapped(sender: UITapGestureRecognizer) {
        print("Remove Photo Button tapped")
    }
    
    @IBAction func takePhotoButtonTapped(sender: UITapGestureRecognizer) {
        print("Take Photo Button tapped")
    }
    
    @IBAction func cameraRollButtonTapped(sender: UITapGestureRecognizer) {
        print("Camera Roll Button Tapped")
    }
}
