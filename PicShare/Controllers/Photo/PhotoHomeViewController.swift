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

class PhotoTempViewController: UIViewController {
    
}


class PhotoHomeViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var cameraOverlayView: UIView!
    var cameraPickerController = UIImagePickerController()
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
            cameraPickerController.showsCameraControls = false
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
            displayViewController(cameraPickerController)
        } else {
            showCameraRoll(cameraRollButton)
        }
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "UploadPhoto" {
            if let image = sender as? UIImage,
                vc = segue.destinationViewController as? UploadPhotoViewController {
                vc.image = image.cropToSquare()
            }
        }
    }
    
    func displayViewController(viewController: UIViewController) {
        addChildViewController(viewController)
        viewController.view.frame = CGRect(x: 0, y: 0, width: containerView.bounds.size.width, height: containerView.bounds.size.height)
        containerView.addSubview(viewController.view)
        viewController.didMoveToParentViewController(self)
    }
    
    // MARK: - Custom Camera Actions
    
    @IBAction func close(sender: AnyObject) {
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
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .PhotoLibrary
        picker.allowsEditing = true
        presentViewController(picker, animated: true, completion: nil)
    }
    
    @IBAction func myPhotosButtonPressed(sender: AnyObject) {
        self.performSegueWithIdentifier("MyPhotos", sender: nil)
    }
}

// MARK: - UIImagePickerControllerDelegate
    
extension PhotoHomeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        var imageToUpload: UIImage?
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage where picker == cameraPickerController {
            imageToUpload = image.cropToSquare()
        } else if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            imageToUpload = image
            dismissViewControllerAnimated(true, completion: nil)
        } else {
            showAlert("Error", message: "Something went wrong with your photo.")
            return
        }
        
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("uploadPhotoViewController") as! UploadPhotoViewController
        vc.image = imageToUpload
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}