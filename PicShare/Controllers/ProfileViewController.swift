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
        
        let query = PFQuery(className: User.parseClassName())

        query.whereKey("username", equalTo: (PFUser.currentUser()?.username)!)
        query.getFirstObjectInBackgroundWithBlock { [weak self](object: PFObject?, error: NSError?) -> Void in

            if let error = error {
                print("Error: \(error) \(error.userInfo)")
                return
            }
            
            guard let user = object as? User else {
                return
            }
            
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
       
        let radiusAnimation = CABasicAnimation(keyPath: "cornerRadius")
        radiusAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        radiusAnimation.fromValue = self.profileImageView.layer.cornerRadius
        radiusAnimation.toValue = 150
        radiusAnimation.duration = 0.5
        self.profileImageView.layer.addAnimation(radiusAnimation, forKey: "cornerRadius")
        
        UIView.animateWithDuration(0.5,
            animations: {
                self.usernameLabel.transform = CGAffineTransformMakeScale(1.0, 1.0)
                self.cameraRollButton.alpha = 0
                self.removePhotoButton.alpha = 0
                self.takePhotoButton.alpha = 0
                self.view.layoutIfNeeded()
            }, completion: nil)
        self.profileImageView.layer.cornerRadius = 150
        modifyButtonsVisible = false
    }
    
    private func showButtons() {
        self.userInfoImageViewHeight.constant = 150
        self.profileImageViewHeight.constant = 100
        self.profileImageViewWidth.constant = 100
        self.usernameLabelTopSpacing.constant = 0
        
        let radiusAnimation = CABasicAnimation(keyPath: "cornerRadius")
        radiusAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        radiusAnimation.fromValue = self.profileImageView.layer.cornerRadius
        radiusAnimation.toValue = 50
        radiusAnimation.duration = 0.5
        self.profileImageView.layer.addAnimation(radiusAnimation, forKey: "cornerRadius")

        UIView.animateWithDuration(0.5,
            animations: {
                self.usernameLabel.transform = CGAffineTransformMakeScale(0.5, 0.5)
                self.cameraRollButton.alpha = 1
                self.removePhotoButton.alpha = 1
                self.takePhotoButton.alpha = 1
                self.view.layoutIfNeeded()
            }, completion: nil)
        self.profileImageView.layer.cornerRadius = 50
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
        if let user = self.user {
            user.profilePhoto = nil
            user.saveInBackgroundWithBlock({ [weak self](success, error) -> Void in
                if success {
                    self?.profileImageView.image = nil
                } else {
                    // TODO: SHOW ERROR MESSAGE
                }
            })
        }
    }

    @IBAction func takePhotoButtonTapped(sender: UIButton) {
        if !cameraAvailable() {
            showAlert("Trouble With Camera", message: "Please enable your camera in your device settings to take a photo.")
            return
        }
        
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

        if let newProfilePhoto = image,
            fullImage = newProfilePhoto.scaleAndRotateImage(960),
            fullImageData = UIImagePNGRepresentation(fullImage)
        {

            let userPhoto = PFFile(name: "ProfilePhoto.png", data: fullImageData)
            if let user = self.user {
                user.profilePhoto = userPhoto
                user.saveInBackgroundWithBlock({ [weak self](success, error) -> Void in
                    if success {
                        self?.profileImageView.image = newProfilePhoto
                    } else {
                        // TODO: SHOW ERROR MESSAGE
                    }
                })
            }
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}
