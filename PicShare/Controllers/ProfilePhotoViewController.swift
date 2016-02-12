//
//  ProfilePhotoViewController.swift
//  PicShare
//
//  Created by Yao Wang on 1/24/16.
//  Copyright © 2016 USC. All rights reserved.
//

import UIKit
import Parse

class ProfilePhotoViewController: UIViewController {

    @IBOutlet var containerView: UIView!
    @IBOutlet weak var profilePhotoPreview: UIImageView!
    var userProfilePhoto: UIImage?
    var userInfo: User?
    var currentContentViewController: UIViewController?
    
    //MARK: - User Actions
    @IBAction func backButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func selectProfilePhoto(sender: UIButton) {
        let selector = UIImagePickerController()
        selector.delegate = self
        selector.sourceType = .PhotoLibrary
        presentViewController(selector, animated: true, completion: nil)
    }
    
    @IBAction func takeProfilePhoto(sender: AnyObject) {
        let selector = UIImagePickerController()
        selector.delegate = self
        selector.sourceType = .Camera
        presentViewController(selector, animated: true, completion: nil)
    }
    
    @IBAction func removeProfilePhoto(sender: AnyObject) {
        userProfilePhoto = nil
        profilePhotoPreview.image = nil
    }
    
    @IBAction func useProfilePhoto(sender: AnyObject) {
        //Signup user to parse
        if let userInfo = userInfo {
            //Add profile photo
            if let userProfilePhoto = userProfilePhoto {
                if let fullImage = userProfilePhoto.scaleAndRotateImage(960),
                    fullImageData = UIImagePNGRepresentation(fullImage)
                {
                    let userPhoto = PFFile(name: "ProfilePhoto.png", data: fullImageData)
                    userInfo.profilePhoto = userPhoto
                }
            }
            userInfo.signUpInBackgroundWithBlock { [weak self](success: Bool, error: NSError?) in
                if success {
                    NSLog("Account creation successful!")
                    //Show home view
                    let homeView: UIViewController
                    let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    homeView = mainStoryboard.instantiateViewControllerWithIdentifier("RootView")
                    self!.showViewController(homeView, sender: sender)
                } else if let error = error {
                    // Something bad has occurred
                    self?.showErrorView(error)
                }
            }
        }
        else {
            print("User doesn't exist!")
        }
    }
    
    //MARK: - Helper
    func showErrorView(error: NSError) {
        let alertView = UIAlertController(title: "Error",
            message: error.localizedDescription, preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertView.addAction(OKAction)
        self.presentViewController(alertView, animated: true, completion: nil)
    }
}

extension ProfilePhotoViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!) {
        self.dismissViewControllerAnimated(true, completion: nil)
        userProfilePhoto = image
        profilePhotoPreview.image = image
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
