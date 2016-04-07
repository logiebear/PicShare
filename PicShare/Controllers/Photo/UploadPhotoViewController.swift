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
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    var image: UIImage?
    var photo: Photo?
    let locationManager = CLLocationManager()
    var didRequestLocation = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        imageView.contentMode = .ScaleAspectFit
        imageView.image = image
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: "resignKeyboard")
        gestureRecognizer.delegate = self
        view.addGestureRecognizer(gestureRecognizer)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidHide",
                                                         name: UIKeyboardDidHideNotification, object: nil)
    }

    // MARK: - User Actions
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
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
            user = PFUser.currentUser()
        {
            let whiteSpaceSet = NSCharacterSet.whitespaceAndNewlineCharacterSet()
            guard let text = descriptionTextField.text
                where text.stringByTrimmingCharactersInSet(whiteSpaceSet) != ""
            else {
                showAlert("Comment Missing", message: "Please Enter a valid Comment")
                return
            }
            photo = Photo(image: imageFile, thumbnail: thumbFile, owner: user, event: nil, location: nil, descriptiveText: text)
            self.performSegueWithIdentifier("showSelectEventScreen", sender: self)
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
                    self?.uploadPhotoWithGeoPoint(geoPoint)
                }
            }
        }
    }
    
    // MARK: - Private
    
    private func uploadPhotoWithGeoPoint(geoPoint: PFGeoPoint) {
        if let image = image,
            fullImage = image.scaleAndRotateImage(960), // Magic number
            thumbImage = image.scaleAndRotateImage(480), // Magic number
            fullImageData = UIImagePNGRepresentation(fullImage),
            thumbImageData = UIImagePNGRepresentation(thumbImage),
            imageFile = PFFile(name: "image.png", data: fullImageData),
            thumbFile = PFFile(name: "thumbnail.png", data: thumbImageData),
            user = PFUser.currentUser()
        {
            let whiteSpaceSet = NSCharacterSet.whitespaceAndNewlineCharacterSet()
            guard let text = descriptionTextField.text
                where text.stringByTrimmingCharactersInSet(whiteSpaceSet) != ""
            else {
                showAlert("Comment Missing", message: "Please Enter a valid Comment")
                return
            }
            
            activityIndicatorView.startAnimating()
            imageFile.saveInBackgroundWithBlock({ [weak self](success, error) -> Void in
                if success {
                    thumbFile.saveInBackgroundWithBlock({ [weak self](success, error) -> Void in
                        if success {
                            self?.proceedToUploadPhoto(imageFile, thumbFile: thumbFile,
                                user: user, geoPoint: geoPoint, text: text)
                        } else {
                            // TODO: SHOW ERROR MESSAGE
                        }
                    }, progressBlock: { (progress) -> Void in
                        print("thumbnail progress: \(progress)%")
                    })
                } else {
                    // TODO: SHOW ERROR MESSAGE
                }
            },
            progressBlock: { (progress) -> Void in
                print("image progress: \(progress)%")
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
            self?.activityIndicatorView.stopAnimating()
            self?.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    func resignKeyboard() {
        descriptionTextField.resignFirstResponder()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        let svc = segue.destinationViewController as! SelectUploadEventViewController
        svc.photo = photo
    }
    
    // MARK: Notification
    
    func keyboardDidHide() {
        scrollView.setContentOffset(CGPointZero, animated: true)
    }
}

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
            self.scrollView.setContentOffset(CGPoint(x: 0, y: 40), animated: false)
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