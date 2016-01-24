//
//  PhotoViewController.swift
//  PicShare
//
//  Created by Logan Chang on 11/15/15.
//  Copyright © 2015 USC. All rights reserved.
//

import UIKit
import Parse

class PhotoHomeViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var takePhotoButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if !UIImagePickerController.isSourceTypeAvailable(.Camera) {
            takePhotoButton.hidden = true
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "UploadPhoto" {
            if let image = sender as? UIImage,
                vc = segue.destinationViewController as? UploadPhotoViewController {
                vc.image = image
            }
        }
    }
    
    // MARK: - User Actions
    
    @IBAction func cameraRollButtonPressed(sender: AnyObject) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .PhotoLibrary
        presentViewController(picker, animated: true, completion: nil)
    }
    
    @IBAction func takePhotoButtonPressed(sender: AnyObject) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .Camera
        presentViewController(picker, animated: true, completion: nil)
    }
    
    @IBAction func myPhotosButtonPressed(sender: AnyObject) {
        // TODO: IMPLEMENT MY PHOTOS
    }
}

// MARK: - UIImagePickerControllerDelegate
    
extension PhotoHomeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        print("Photo selected")
//        if let fullImage = image.scaleAndRotateImage(960),
//            thumbImage = image.scaleAndRotateImage(480),
//            fullImageData = UIImagePNGRepresentation(fullImage),
//            thumbImageData = UIImagePNGRepresentation(thumbImage)
//        {
//            let userPhoto = PFObject(className: photoClassName)
//            userPhoto[photoFileKey] = PFFile(name: "original.png", data: fullImageData)
//            userPhoto[thumbFileKey] = PFFile(name: "thumbnail.png", data: thumbImageData)
//            userPhoto.saveEventually()
//        } else {
//            print("Photo saving error")
//        }
        dismissViewControllerAnimated(true) { () -> Void in
            self.performSegueWithIdentifier("UploadPhoto", sender: image)
        }

    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}