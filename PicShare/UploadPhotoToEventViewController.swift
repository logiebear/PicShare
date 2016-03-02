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

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var commentTextField: UITextField!
    
    var image: UIImage?
    var hashtag: String?
    var event: Event?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        imageView.contentMode = .ScaleAspectFit
        imageView.image = image
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - User Actions
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func UploadButtonPressed(sender: AnyObject) {
        
        checkValid { (success) -> () in
            if success {
                self.uploadPhotoToEvent()}
        }
       
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
            var text = ""
            if let commentText = commentTextField.text {
                text = commentText
            }
            
            //activityIndicatorView.startAnimating()
            imageFile.saveInBackgroundWithBlock({ [weak self](success, error) -> Void in
                if success {
                    thumbFile.saveInBackgroundWithBlock({ [weak self](success, error) -> Void in
                        if success {
                            self?.proceedToUploadPhoto(imageFile, thumbFile: thumbFile, user: user, text: text)
                        } else {
                            // TODO: SHOW ERROR MESSAGE
                        }
                        }, progressBlock: { (progress) -> Void in
                            print("thumbnail progress: \(progress)%")
                    })
                } else {
                    // TODO: SHOW ERROR MESSAGE
                }
                }, progressBlock: { (progress) -> Void in
                    print("image progress: \(progress)%")
            })
        } else {
            print("Photo saving error")
        }
    }
    
    
    // MARK: - Helpers
    
    func checkValid(completion: (Bool) -> ()) {
        guard let query = Event.query() else {
            return
        }
        if let hashtag = self.hashtag {
            query.whereKey("hashtag", equalTo: hashtag)
            query.findObjectsInBackgroundWithBlock { [weak self](objects: [PFObject]?, error: NSError?) -> Void in
                if let objects = objects where objects.count == 1{
                    self?.event = objects.first as? Event
                    completion(true)
                } else {
                    self?.showErrorView("Invalid event", msg: "Event does not exist")
                    completion(false)
                }
            }
        }
    }
    
    func proceedToUploadPhoto(imageFile: PFFile, thumbFile: PFFile, user: PFUser, text: String) {
        let photo = Photo(image: imageFile,
            thumbnail: thumbFile,
            owner: user,
            event: self.event, location: nil, descriptiveText: text)
        
        photo.saveInBackgroundWithBlock({ [weak self](success, error) -> Void in
            //self?.activityIndicatorView.stopAnimating()
            self?.dismissViewControllerAnimated(true, completion: nil)
            })
    }
    
    func showErrorView(title: String, msg: String) {
        let alertView = UIAlertController(title: title,
            message: msg, preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertView.addAction(OKAction)
        self.presentViewController(alertView, animated: true, completion: nil)
    }
}




