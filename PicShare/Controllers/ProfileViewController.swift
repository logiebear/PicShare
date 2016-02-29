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
    @IBOutlet weak var removePhotoButton: UIButton!
    @IBOutlet weak var takePhotoButton: UIButton!
    @IBOutlet weak var cameraRollButton: UIButton!
    
    private var modifyButtonsVisible = false
    private var user: User?
    
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
                    self?.user = user
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
            self.cameraRollButton.alpha = 0.0
            self.removePhotoButton.alpha = 0.0
            self.takePhotoButton.alpha = 0.0
            self.view.layoutIfNeeded()
        }
        self.cameraRollButton.hidden = true
        self.removePhotoButton.hidden = true
        self.takePhotoButton.hidden = true
        modifyButtonsVisible = false
    }
    
    private func showButtons() {
        self.userInfoImageViewHeight.constant = 150
        self.profileImageViewHeight.constant = 100
        self.profileImageViewWidth.constant = 100
        self.usernameLabelTopSpacing.constant = 7
        self.usernameLabelHeight.constant = 15
        self.cameraRollButton.hidden = false
        self.removePhotoButton.hidden = false
        self.takePhotoButton.hidden = false
        
        UIView.animateWithDuration(0.5) {
            self.profileImageView.layer.cornerRadius = 50
            self.usernameLabel.font = UIFont.boldSystemFontOfSize(12)
            self.cameraRollButton.alpha = 1.0
            self.removePhotoButton.alpha = 1.0
            self.takePhotoButton.alpha = 1.0
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
    
    @IBAction func removePhotoButtonTapped(sender: UIButton) {
        print("Remove Photo Button tapped")
    }


    @IBAction func takePhotoButtonTapped(sender: UIButton) {
        let selector = UIImagePickerController()
        selector.delegate = self
        selector.sourceType = .Camera
        presentViewController(selector, animated: true, completion: nil)
    }
    
    @IBAction func cameraRollButtonTapped(sender: UIButton) {
        let selector = UIImagePickerController()
        selector.delegate = self
        selector.sourceType = .PhotoLibrary
        presentViewController(selector, animated: true, completion: nil)
    }
}

extension ProfileViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!) {
        dismissViewControllerAnimated(true, completion: nil)
        //userProfilePhoto = image
        //profilePhotoPreview.image = image
        
        if let _ = image {
            print ("I think I've gotten an image")
        }
        
        self.profileImageView.image = image
        
        if let newProfilePhoto = image,
            fullImage = newProfilePhoto.scaleAndRotateImage(960),
            fullImageData = UIImagePNGRepresentation(fullImage)
            {
                let userPhoto = PFFile(name: "ProfilePhoto.png", data: fullImageData)
                if let user = self.user {
                    user.profilePhoto = userPhoto
                }
            }
        
        
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}
