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
    var event: Event?
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
        
        // Added functionality to hide keyboard if tapped on screen
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UploadPhotoViewController.resignKeyboard))
        gestureRecognizer.delegate = self
        view.addGestureRecognizer(gestureRecognizer)
        
        // Adds function that is called after keyboard is hidden notification is fired
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UploadPhotoViewController.keyboardDidHide),
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
        
        if let event = event {
            // If event is set, upload photo to event
            uploadPhotoImageFilesWithGeoPointOrEvent(event: event)
        } else {
            // Otherwise upload selection popup view
            showPopupView(uploadSelectionPopupView)
        }
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
            // Create new photo object to be uploaded
            photo = Photo(image: imageFile, thumbnail: thumbFile, owner: user, descriptiveText: text)
            // Hide popup view after selection
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
            // Location services are not enabled
            showAlert("Location Services Disabled", message: "Please go to your device settings to enable location services.")
        } else if status == .NotDetermined {
            // Attempt to request location services
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
            didRequestLocation = true
        } else {
            // Attempt to fetch current location
            PFGeoPoint.geoPointForCurrentLocationInBackground { [weak self](geoPoint, error) -> Void in
                if let error = error {
                    print("Error: \(error)")
                    return
                }
                if let geoPoint = geoPoint {
                    if let uploadSelectionPopupView = self?.uploadSelectionPopupView {
                        self?.hidePopupView(uploadSelectionPopupView)
                    }
                    // Proceed to upload photo to current location
                    self?.uploadPhotoImageFilesWithGeoPointOrEvent(geoPoint: geoPoint)
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
    /**
        Function to handle uploading photos current location or event
        -Parameters
            -geoPoint: current location to be uploaded to if set
            -event: event to be uploaded to if set
     */
    private func uploadPhotoImageFilesWithGeoPointOrEvent(geoPoint geoPoint: PFGeoPoint? = nil, event: Event? = nil) {
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
            progressView.progress = 0.0
            showPopupView(progressPopupView)
            // Upload main image
            imageFile.saveInBackgroundWithBlock({ [weak self](success, error) -> Void in
                if !success {
                    self?.showAlert("Error", message: "There was an error uploading your photo. Please try again.")
                    if let progressPopupView = self?.progressPopupView {
                        self?.hidePopupView(progressPopupView)
                    }
                    print("Image upload error: \(error)")
                    return
                }
                // Upload thumbnail image
                thumbFile.saveInBackgroundWithBlock({ [weak self](success, error) -> Void in
                    if !success {
                        self?.showAlert("Error", message: "There was an error uploading your photo. Please try again.")
                        if let progressPopupView = self?.progressPopupView {
                            self?.hidePopupView(progressPopupView)
                        }
                        print("Thumb upload error: \(error)")
                        return
                    }
                    let photo = Photo(image: imageFile, thumbnail: thumbFile, owner: user, descriptiveText: text)
                    if let event = event {
                        let query = PFQuery(className: "Event")
                        guard let eventId = event.objectId else {
                            return
                        }
                        // Need to fetch event from server to upload to it
                        query.getObjectInBackgroundWithId(eventId) { [weak self](object, error) -> Void in
                            if let error = error {
                                print("Error: \(error)")
                                return
                            }
                            if let event = object as? Event {
                                photo.event = event
                                self?.proceedToUploadPhoto(photo)
                            }
                        }
                    } else {
                        photo.location = geoPoint
                        self?.proceedToUploadPhoto(photo)
                    }
                },
                progressBlock: { (progress) -> Void in
                    print("thumbnail upload progress: \(progress)%")
                    self?.progressView?.setProgress(Float(progress) / 200.0 + 0.5, animated: true)
                    self?.progressLabel?.text = "Uploading photo... \(progress / 2 + 50) %"
                })
            },
            progressBlock: { (progress) -> Void in
                print("image upload progress: \(progress)%")
                self.progressView?.setProgress(Float(progress) / 200.0, animated: true)
                self.progressLabel?.text = "Uploading photo... \(progress / 2) %"
            })
        } else {
            print("Photo saving error")
        }
    }
    
    // MARK: - Helpers
    
    /**
         Uploads the photo object to the server
         
         -Parameters
             -photo: photo to be uploaded
     */
    func proceedToUploadPhoto(photo: Photo) {
        photo.saveInBackgroundWithBlock { [weak self](success, error) -> Void in
            if let progressPopupView = self?.progressPopupView {
                self?.hidePopupView(progressPopupView)
            }
            if !success {
                self?.showAlert("Error", message: "There was an error uploading your photo. Please try again.")
                print("Thumb upload error: \(error)")
                return
            }
            self?.showAlert("Upload Success", message: "You have successfully uploaded your photo.") {
                if let viewControllers = self?.navigationController?.viewControllers {
                    for viewController in viewControllers {
                        if self?.event != nil {
                            // If an event was set, pop back to event screen controller
                            if viewController is EventPhotoScreenViewController {
                                self?.navigationController?.popToViewController(viewController, animated: true)
                                return
                            }                            
                        } else {
                            // Otherwise Look for camera VC and pop to correct one
                            if viewController is PhotoHomeViewController {
                                self?.navigationController?.popToViewController(viewController, animated: true)
                                return
                            }
                        }
                    }
                }
                // Default pop to root
                self?.navigationController?.popToRootViewControllerAnimated(true)
            }
        }
    }
    
    /**
        Hides keyboard
     */
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
        // If view is UIControl do not receive touch
        if let view = touch.view where view is UIControl {
            return false
        }
        return true
    }
    
}