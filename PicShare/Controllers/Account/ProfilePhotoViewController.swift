//
//  ProfilePhotoViewController.swift
//  PicShare
//
//  Created by Yao Wang on 1/24/16.
//  Copyright © 2016 USC. All rights reserved.
//

import UIKit
import Parse
import AVFoundation

class ProfilePhotoViewController: UIViewController {

    @IBOutlet var containerView: UIView!
    @IBOutlet weak var profilePhotoPreview: UIImageView!
    var userProfilePhoto: UIImage?
    var user: User?
    var currentContentViewController: UIViewController?
    var uploadInProgress = false
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.profilePhotoPreview.layer.cornerRadius = self.profilePhotoPreview.frame.size.height / 2
        self.profilePhotoPreview.clipsToBounds = true
    }
    
    // MARK: - User Actions
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func selectProfilePhoto(sender: UIButton) {
        let selector = UIImagePickerController()
        selector.delegate = self
        selector.sourceType = .PhotoLibrary
        selector.allowsEditing = true
        presentViewController(selector, animated: true, completion: nil)
    }
    
    @IBAction func takeProfilePhoto(sender: AnyObject) {
        if !cameraAvailable() {
            showAlert("Trouble With Camera", message: "Please enable your camera in your device settings to take a photo.")
            return
        }
        
        let selector = UIImagePickerController()
        selector.delegate = self
        selector.sourceType = .Camera
        selector.allowsEditing = true
        presentViewController(selector, animated: true, completion: nil)
    }
    
    @IBAction func removeProfilePhoto(sender: AnyObject) {
        userProfilePhoto = nil
        profilePhotoPreview.image = nil
    }
    
    @IBAction func useProfilePhoto(sender: AnyObject) {
        if !networkReachable() {
            showAlert("No Internet Connection", message: "Please check your internet connection and try again.")
            return
        }
        // Signup user to parse
        guard let user = user else {
            print("User doesn't exist!")
            return
        }
        if uploadInProgress {
            return
        }
        uploadInProgress = true

        // Add profile photo
        if let userProfilePhoto = userProfilePhoto,
            fullImage = userProfilePhoto.scaleAndRotateImage(960),
            fullImageData = UIImagePNGRepresentation(fullImage)
        {
            let userPhoto = PFFile(name: "ProfilePhoto.png", data: fullImageData)
            user.profilePhoto = userPhoto
        }
        
        user.signUpInBackgroundWithBlock { [weak self](success: Bool, error: NSError?) in
            self?.uploadInProgress = false
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
    
    // MARK: - Helper
    
    func showErrorView(error: NSError) {
        let alertView = UIAlertController(title: "Error",
            message: error.localizedDescription, preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertView.addAction(OKAction)
        presentViewController(alertView, animated: true, completion: nil)
    }
    
}

extension ProfilePhotoViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!) {
        dismissViewControllerAnimated(true, completion: nil)
        userProfilePhoto = image.cropToSquare()
        profilePhotoPreview.image = image.cropToSquare()
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}
