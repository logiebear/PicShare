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

    @IBOutlet weak var profilePhotoPreview: UIImageView!
    var profilePhoto: UIImage?
    var userInfo: User?
    
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
        profilePhoto = nil
        profilePhotoPreview.image = nil
    }
    
    @IBAction func useProfilePhoto(sender: AnyObject) {
        //Signup user to parse
        if let userInfo = userInfo {
            userInfo.signUpInBackgroundWithBlock { [weak self](success: Bool, error: NSError?) in
                if success {
                    //Add profile photo
                    if let profilePhoto = self!.profilePhoto {
                        if let fullImage = profilePhoto.scaleAndRotateImage(960),
                            thumbImage = profilePhoto.scaleAndRotateImage(480),
                            fullImageData = UIImagePNGRepresentation(fullImage),
                            thumbImageData = UIImagePNGRepresentation(thumbImage)
                        {
                            let userPhoto = PFObject(className: photoClassName)
                            userPhoto[photoFileKey] = PFFile(name: "original.png", data: fullImageData)
                            userPhoto[thumbFileKey] = PFFile(name: "thumbnail.png", data: thumbImageData)
                            userPhoto.saveEventually()
                            let userProfilePhoto = Photo(image: PFFile(name: "original.png", data: fullImageData)!, thumbnail: PFFile(name: "thumbnail.png", data: thumbImageData)!, owner: userInfo, event: nil, location: nil, descriptiveText: nil)
                            //Save profile photo
                            userProfilePhoto.saveInBackgroundWithBlock {
                                (success: Bool, error: NSError?) -> Void in
                                if success {
                                    NSLog("Profile photo saving successful!");
                                    //Update user's profile photo
                                    let currentUser = User.currentUser()
                                    if let currentUser = currentUser {
                                        currentUser.profilePhoto = userProfilePhoto
                                        currentUser.saveEventually()
                                        NSLog("User signing up successful!")
                                    }
                                    else {
                                        NSLog("No login session!")
                                    }
                                }
                                else {
                                    print("Profile photo saving error")
                                }
                            }
                        }
                    }
                    self?.dismissViewControllerAnimated(true, completion: { () -> Void in
                        let nc = NSNotificationCenter.defaultCenter()
                        nc.postNotificationName(accountStatusChangedNotification, object: nil)
                    })
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
        profilePhoto = image
        profilePhotoPreview.image = image
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
