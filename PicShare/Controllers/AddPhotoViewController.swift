//
//  AddPhotoViewController.swift
//  PicShare
//
//  Created by ZhouJiashun on 2/20/16.
//  Copyright © 2016 USC. All rights reserved.
//

import UIKit

class AddPhotoViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var congratsLabel: UILabel!
    @IBOutlet weak var firstHalfTextField: UITextView!
    @IBOutlet weak var takePhotoButton: UIButton!
    @IBOutlet weak var cameraRollButton: UIButton!
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var secondHalfTextField: UITextView!
    var hashtag: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        // Check if device has camera.
        if !UIImagePickerController.isSourceTypeAvailable(.Camera) {
            takePhotoButton.hidden = true
        }
        eventNameLabel.text = hashtag
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
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}

// MARK: - UIImagePickerControllerDelegate

extension AddPhotoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        dismissViewControllerAnimated(true) { () -> Void in
            self.performSegueWithIdentifier("UploadPhoto", sender: image)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
