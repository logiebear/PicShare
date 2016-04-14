//
//  UploadPhotoViewController.swift
//  PicShare
//
//  Created by Logan Chang on 11/29/15.
//  Copyright © 2015 USC. All rights reserved.
//

import UIKit
import Parse

class UploadPhotoViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var uploadSelectionPopupView: UIView!
    // Progress Popup
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var progressPopupView: UIView!
    @IBOutlet weak var progressView: UIProgressView!
    var image: UIImage?
    var photo: Photo?
    let locationManager = CLLocationManager()
    var didRequestLocation = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.bringSubviewToFront(progressPopupView)
        view.bringSubviewToFront(uploadSelectionPopupView)
        progressPopupView.alpha = 0.0
        uploadSelectionPopupView.alpha = 0.0

        // Do any additional setup after loading the view.
        imageView.contentMode = .ScaleAspectFit
        imageView.image = image
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: "resignKeyboard")
        gestureRecognizer.delegate = self
        view.addGestureRecognizer(gestureRecognizer)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidHide",
                                                         name: UIKeyboardDidHideNotification, object: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "SelectEvent" {
            let svc = segue.destinationViewController as! SelectUploadEventViewController
            svc.photo = photo
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    // MARK: - User Actions
    
    @IBAction func retakekButtonPressed(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func usePhotoButtonPressed(sender: AnyObject) {
        let whiteSpaceSet = NSCharacterSet.whitespaceAndNewlineCharacterSet()
        guard let text = descriptionTextField.text
            where text.stringByTrimmingCharactersInSet(whiteSpaceSet) != ""
        else {
            showAlert("Comment Missing", message: "Please Enter a valid Comment")
            return
        }
        showPopupView(uploadSelectionPopupView)
    }
    
    // MARK: - Upload Selection Popup
    
    @IBAction func uploadToEvent(sender: AnyObject) {
        if !networkReachable() {
            showAlert("No Internet Connection", message: "Please check your internet connection and try again.")
            return
        }
        
        if let image = image,
            fullImage = image.scaleAndRotateImage(960), // Magic number
            thumbImage = image.scaleAndRotateImage(480), // Magic number
            fullImageData = UIImagePNGRepresentation(fullImage),
            thumbImageData = UIImagePNGRepresentation(thumbImage),
            imageFile = PFFile(name: "image.png", data: fullImageData),
            thumbFile = PFFile(name: "thumbnail.png", data: thumbImageData),
            text = descriptionTextField.text,
            user = PFUser.currentUser()
        {
            photo = Photo(image: imageFile, thumbnail: thumbFile, owner: user, event: nil, location: nil, descriptiveText: text)
            hidePopupView(uploadSelectionPopupView)
            self.performSegueWithIdentifier("SelectEvent", sender: self)
        }
    }
    
    @IBAction func uploadToLocation(sender: AnyObject) {
        if !networkReachable() {
            showAlert("No Internet Connection", message: "Please check your internet connection and try again.")
            return
        }
        
        let status = CLLocationManager.authorizationStatus()
        if status == .Denied || status == .Restricted {
            showAlert("Location Services Disabled", message: "Please go to your device settings to enable location services.")
        } else if status == .NotDetermined {
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
            didRequestLocation = true
        } else {
            PFGeoPoint.geoPointForCurrentLocationInBackground { [weak self](geoPoint, error) -> Void in
                if let error = error {
                    print("Error: \(error)")
                    return
                }
                if let geoPoint = geoPoint {
                    if let uploadSelectionPopupView = self?.uploadSelectionPopupView {
                        self?.hidePopupView(uploadSelectionPopupView)
                    }
                    if let progressPopupView = self?.progressPopupView {
                        self?.progressView.progress = 0.0
                        self?.showPopupView(progressPopupView)
                    }
                    self?.uploadPhotoWithGeoPoint(geoPoint)
                }
            }
        }
    }
    
    @IBAction func closeUploadPopupButtonPressed(sender: AnyObject) {
        hidePopupView(uploadSelectionPopupView)
    }
    
    // MARK: - Private

    private func showPopupView(popupView: UIView) {
        UIView.animateWithDuration(0.5) {
            popupView.alpha = 1.0
        }
    }
    
    private func hidePopupView(popupView: UIView) {
        UIView.animateWithDuration(0.5) {
            popupView.alpha = 0.0
        }
    }
    
    private func uploadPhotoWithGeoPoint(geoPoint: PFGeoPoint) {
        if let image = image,
            fullImage = image.scaleAndRotateImage(960), // Magic number
            thumbImage = image.scaleAndRotateImage(480), // Magic number
            fullImageData = UIImagePNGRepresentation(fullImage),
            thumbImageData = UIImagePNGRepresentation(thumbImage),
            imageFile = PFFile(name: "image.png", data: fullImageData),
            thumbFile = PFFile(name: "thumbnail.png", data: thumbImageData),
            text = descriptionTextField.text,
            user = PFUser.currentUser()
        {
            // Upload main image
            imageFile.saveInBackgroundWithBlock({ [weak self](success, error) -> Void in
                if success && error == nil {
                    // Upload thumbnail image
                    thumbFile.saveInBackgroundWithBlock({ [weak self](success, error) -> Void in
                        if success && error == nil {
                            self?.proceedToUploadPhoto(imageFile, thumbFile: thumbFile,
                                user: user, geoPoint: geoPoint, text: text)
                        } else {
                            self?.showAlert("Error", message: "There was an error uploading your photo. Please try again.")
                            print("Thumb upload error: \(error)")
                        }
                    },
                    progressBlock: { (progress) -> Void in
                        print("thumbnail upload progress: \(progress)%")
                        self?.progressView?.setProgress(Float(progress) / 200.0 + 0.5, animated: true)
                        self?.progressLabel?.text = "\(progress / 2 + 50) %"
                    })
                } else {
                    self?.showAlert("Error", message: "There was an error uploading your photo. Please try again.")
                    print("Image upload error: \(error)")
                }
            },
            progressBlock: { (progress) -> Void in
                print("image upload progress: \(progress)%")
                self.progressView?.setProgress(Float(progress) / 200.0, animated: true)
                self.progressLabel?.text = "\(progress / 2) %"
            })
        } else {
            print("Photo saving error")
        }
    }
    
    // MARK: - Helpers
    
    func proceedToUploadPhoto(imageFile: PFFile, thumbFile: PFFile, user: PFUser, geoPoint: PFGeoPoint, text: String) {
        let photo = Photo(image: imageFile,
            thumbnail: thumbFile,
            owner: user,
            event: nil, location: geoPoint, descriptiveText: text)
        
        photo.saveInBackgroundWithBlock { [weak self](success, error) -> Void in
            if let progressPopupView = self?.progressPopupView {
                self?.hidePopupView(progressPopupView)
            }
            self?.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    func resignKeyboard() {
        descriptionTextField.resignFirstResponder()
    }
    
    // MARK: Notification
    
    func keyboardDidHide() {
        scrollView.setContentOffset(CGPointZero, animated: true)
    }
}

// MARK: - CLLocationManagerDelegate

extension UploadPhotoViewController: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse || status == .AuthorizedAlways {
            manager.startUpdatingLocation()
            if didRequestLocation {
                uploadToLocation(UIButton())
            }
        }
    }
    
}

// MARK: - UITextFieldDelegate

extension UploadPhotoViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        UIView.animateWithDuration(0.25) {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: 100), animated: false)
        }
    }
    
}

// MARK: - UIGestureRecognizerDelegate

extension UploadPhotoViewController: UIGestureRecognizerDelegate {

    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if let view = touch.view where view is UIControl {
            return false
        }
        return true
    }
    
}