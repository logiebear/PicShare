//
//  PhotoViewController.swift
//  PicShare
//
//  Created by Logan Chang on 11/15/15.
//  Copyright © 2015 USC. All rights reserved.
//

import UIKit
import Parse
import AVFoundation

// Temp View Controller used to help the tab bar nav bar to load the custom camera view
class PhotoTempViewController: UIViewController {
    
}

class PhotoHomeViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var cameraOverlayView: UIView!
    var cameraPickerController = UIImagePickerController()
    var event: Event?
    let deviceHasCamera = UIImagePickerController.isSourceTypeAvailable(.Camera)
    
    // Used for simulator only
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var cameraRollButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Hide header view for custom camera overlay
        headerView.hidden = deviceHasCamera
        
        cameraPickerController.delegate = self
        if deviceHasCamera {
            cameraPickerController.sourceType = .Camera
            // Hide camera controls to enable custom view
            cameraPickerController.showsCameraControls = false
            // Load custom camera view from nib
            NSBundle.mainBundle().loadNibNamed("CameraOverlayView", owner: self, options: nil)
            if let overlayView = cameraPickerController.cameraOverlayView {
                cameraOverlayView.frame = overlayView.frame
            } else {
                cameraOverlayView.frame = view.frame
            }
            let translate = CGAffineTransformMakeTranslation(0.0, 60.0) // Shifted down by height of header bar
            cameraPickerController.cameraViewTransform = translate
            cameraPickerController.cameraOverlayView = cameraOverlayView
            cameraPickerController.cameraFlashMode = .On

            if !cameraAvailable() {
                showAlert("Trouble With Camera", message: "Please enable your camera in your device settings to take a photo.")
                return
            }
            // Displays camera picker in container view
            displayViewController(cameraPickerController)
        } else {
            showCameraRoll(cameraRollButton)
        }
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    /**
        Adds viewController to containerView
     */
    func displayViewController(viewController: UIViewController) {
        addChildViewController(viewController)
        viewController.view.frame = CGRect(x: 0, y: 0, width: containerView.bounds.size.width, height: containerView.bounds.size.height)
        containerView.addSubview(viewController.view)
        viewController.didMoveToParentViewController(self)
    }
    
    // MARK: - Custom Camera Actions
    
    @IBAction func close(sender: AnyObject) {
        // If close pressed, simply pop the view controller
        navigationController?.popViewControllerAnimated(false)
    }
    
    @IBAction func toggleFlash(sender: AnyObject) {
        if let button = sender as? UIButton {
            if cameraPickerController.cameraFlashMode == .On {
                cameraPickerController.cameraFlashMode = .Off
                button.alpha = 0.5
            } else {
                cameraPickerController.cameraFlashMode = .On
                button.alpha = 1.0
            }
        }
    }
    
    @IBAction func rotateCamera(sender: AnyObject) {
        cameraPickerController.cameraDevice = cameraPickerController.cameraDevice == .Rear ? .Front : .Rear
    }
    
    @IBAction func takePhoto(sender: AnyObject) {
        cameraPickerController.takePicture()
    }
    
    @IBAction func showCameraRoll(sender: AnyObject) {
        // Loads device photo library
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .PhotoLibrary // Device Library
        picker.allowsEditing = true // Allows editing makes the photo into a square
        // Loads another picker over the custom camera view
        presentViewController(picker, animated: true, completion: nil)
    }
    
}

// MARK: - UIImagePickerControllerDelegate
    
extension PhotoHomeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        var imageToUpload: UIImage?
        // If the picker is the custom camera view, we want the original image
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage where picker == cameraPickerController {
            // Crop the image to a square
            imageToUpload = image.cropToSquare()
        // Otherwise the image is coming from the camera roll, so we want the edited image as the camera roll will crop to square for us
        } else if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            imageToUpload = image
            // Dismiss the camera roll
            dismissViewControllerAnimated(true, completion: nil)
        } else {
            showAlert("Error", message: "Something went wrong with your photo.")
            return
        }
        
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("uploadPhotoViewController") as! UploadPhotoViewController
        vc.event = event
        vc.image = imageToUpload
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        // Dismiss picker view if cancel button pressed
        dismissViewControllerAnimated(true, completion: nil)
    }
}