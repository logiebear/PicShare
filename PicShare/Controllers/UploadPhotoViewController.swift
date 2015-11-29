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

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionTextField: UITextField!
    var image: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        imageView.image = image
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: "resignKeyboard")
        gestureRecognizer.delegate = self
        view.addGestureRecognizer(gestureRecognizer)
    }

    // MARK: - User Actions
    
    @IBAction func uploadToEvent(sender: AnyObject) {
        // TODO: Upload to Event
    }
    
    @IBAction func uploadToLocation(sender: AnyObject) {
        PFGeoPoint.geoPointForCurrentLocationInBackground { [weak self](geoPoint, error) -> Void in
            if let geoPoint = geoPoint where error == nil {
                self?.uploadPhotoWithGeoPoint(geoPoint)
            } else {
                print("Error getting location")
            }
        }
    }
    
    
    // MARK: - Private
    
    private func uploadPhotoWithGeoPoint(geoPoint: PFGeoPoint) {
//        if let image = image,
//            fullImage = image.scaleAndRotateImage(960),
//            thumbImage = image.scaleAndRotateImage(480),
//            fullImageData = UIImagePNGRepresentation(fullImage),
//            thumbImageData = UIImagePNGRepresentation(thumbImage)
//        {
//            let file = PFFile(name: "image.png", data: full)
            
//            let userPhoto = PFObject(className: photoClassName)
//            userPhoto[photoFileKey] = PFFile(name: "original.png", data: fullImageData)
//            userPhoto[thumbFileKey] = PFFile(name: "thumbnail.png", data: thumbImageData)
//            userPhoto.saveEventually()
//            let            
//            
//        } else {
//            print("Photo saving error")
//        }
        
    }
    
    // MARK: - Helpers
    
    func resignKeyboard() {
        descriptionTextField.resignFirstResponder()
    }
    
}

// MARK: - UIGestureRecognizerDelegate

extension UploadPhotoViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        return !(touch.view is UIControl)
    }
    
}