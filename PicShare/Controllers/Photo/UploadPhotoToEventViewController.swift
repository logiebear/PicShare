//
//  UploadPhotoToEventViewController.swift
//  PicShare
//
//  Created by ZhouJiashun on 3/1/16.
//  Copyright © 2016 USC. All rights reserved.
//

import UIKit
import Parse

class UploadPhotoToEventViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    var image: UIImage?
    var hashtag: String?
    var event: Event?
    var progressView: UIProgressView?
    var progressLabel: UILabel?
    private var isUploadingPhoto = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        imageView.contentMode = .ScaleAspectFit
        imageView.image = image
        addControls()
        
        let gestureRecognizer = UITapGestureRecognizer()
        gestureRecognizer.addTarget(self, action: "resignKeyboard")
        gestureRecognizer.delegate = self
        view.addGestureRecognizer(gestureRecognizer)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidHide",
                                                         name: UIKeyboardDidHideNotification, object: nil)
    }
    
    // MARK: - User Actions
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }

    @IBAction func UploadButtonPressed(sender: AnyObject) {
        if isUploadingPhoto { return }
        uploadPhotoToEvent()
    }
    
    // MARK: - Private
    
    //refer to UploadPhotoViewController.swift
    private func uploadPhotoToEvent() {
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
            guard let text = commentTextField.text where text.stringByTrimmingCharactersInSet(whiteSpaceSet) != "" else {
                showAlert("Comment Missing", message: "Please Enter a valid Comment")
                return
            }
            
            isUploadingPhoto = true
            activityIndicatorView.startAnimating()
            imageFile.saveInBackgroundWithBlock({ [weak self](success, error) -> Void in
                if success {
                    thumbFile.saveInBackgroundWithBlock({ [weak self](success, error) -> Void in
                        if success {
                            self?.proceedToUploadPhoto(imageFile, thumbFile: thumbFile, user: user, text: text)
                        } else {
                            self?.isUploadingPhoto = false
                            self?.showAlert("Error", message: "Something went wrong while uploading your photo. Please try again")
                        }
                    }, progressBlock: { (progress) -> Void in
                        print("thumbnail progress: \(progress)%")
                    })
                } else {
                    self?.isUploadingPhoto = false
                    self?.showAlert("Error", message: "Something went wrong while uploading your photo. Please try again")
                }
            }, progressBlock: { (progress) -> Void in
                print("image progress: \(progress)%")
                self.progressView?.progress = Float(progress)
                self.progressLabel?.text = "\(progress) %"
            })
        } else {
            print("Photo saving error")
        }
    }
    
    // MARK: - Helpers
    
    func proceedToUploadPhoto(imageFile: PFFile, thumbFile: PFFile, user: PFUser, text: String) {
        let photo = Photo(image: imageFile,
            thumbnail: thumbFile,
            owner: user,
            event: self.event, location: nil, descriptiveText: text)
        print("photo owner is  \(photo.owner)")
        photo.saveInBackgroundWithBlock { [weak self](success, error) -> Void in
            if success {
                self?.activityIndicatorView.stopAnimating()
                self?.navigationController?.popViewControllerAnimated(true)
            } else {
                self?.showAlert("Error", message: "Something went wrong while uploading your photo. Please try again")
            }
            self?.isUploadingPhoto = false
        }
    }
    
    func showErrorView(title: String, msg: String) {
        let alertView = UIAlertController(title: title,
            message: msg, preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertView.addAction(OKAction)
        self.presentViewController(alertView, animated: true, completion: nil)
    }
    
    func resignKeyboard() {
        commentTextField.resignFirstResponder()
    }
    
    // MARK: - Notification
    
    func keyboardDidHide() {
        scrollView.setContentOffset(CGPointZero, animated: true)
    }
    
    func addControls() {
        // Create Progress View Control
        progressView = UIProgressView(progressViewStyle: UIProgressViewStyle.Default)
        progressView?.center = self.view.center
        view.addSubview(progressView!)
        
        // Add Label
        progressLabel = UILabel()
        let frame = CGRectMake(view.center.x - 25, view.center.y - 100, 100, 50)
        progressLabel?.frame = frame
        view.addSubview(progressLabel!)
    }
    
}

// MARK: - UITextFieldDelegate

extension UploadPhotoToEventViewController: UITextFieldDelegate {
    
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

extension UploadPhotoToEventViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if let view = touch.view where view is UIControl {
            return false
        }
        return true
    }
    
}