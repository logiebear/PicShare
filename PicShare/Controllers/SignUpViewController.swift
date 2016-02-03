//
//  SignUpViewController.swift
//  PicShare
//
//  Created by Logan Chang on 11/27/15.
//  Copyright © 2015 USC. All rights reserved.
//

import UIKit
import Parse

let photoClassName = "Photo"
let photoFileKey = "fullSizeFile"
let thumbFileKey = "thumbSizeFile"

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordConfirmTextField: UITextField!
    var toPass: UIImage?
    var profilePhoto: Photo?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    // MARK: - User Actions
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func signUpSubmitButton(sender: UIButton) {
        //Check empty field or inconsistent passwords
        if emailTextField.text == nil || userNameTextField.text == nil || passwordTextField.text == nil || passwordConfirmTextField.text == nil {
            let error = NSError(domain: "SuperSpecialDomain", code: -99, userInfo: [
                NSLocalizedDescriptionKey: "Please fill out all the fields!"
                ])
            self.showErrorView(error)
        }
        else if passwordTextField.text! != passwordConfirmTextField.text! {
            let error = NSError(domain: "SuperSpecialDomain", code: -99, userInfo: [
                NSLocalizedDescriptionKey: "Two passwords are different!"
                ])
            self.showErrorView(error)
        }
        
        let user = User(email: emailTextField.text!, username: userNameTextField.text!, password: passwordTextField.text!, profilePhoto: nil)
        //Add profile photo
        if toPass != nil {
            if let fullImage = toPass!.scaleAndRotateImage(960),
                thumbImage = toPass!.scaleAndRotateImage(480),
                fullImageData = UIImagePNGRepresentation(fullImage),
                thumbImageData = UIImagePNGRepresentation(thumbImage)
            {
                let userPhoto = PFObject(className: photoClassName)
                userPhoto[photoFileKey] = PFFile(name: "original.png", data: fullImageData)
                userPhoto[thumbFileKey] = PFFile(name: "thumbnail.png", data: thumbImageData)
                userPhoto.saveEventually()
                profilePhoto = Photo(image: PFFile(name: "original.png", data: fullImageData)!, thumbnail: PFFile(name: "thumbnail.png", data: thumbImageData)!, owner: user, event: nil, location: nil, descriptiveText: nil)
                profilePhoto!.saveEventually()
                user.profilePhoto = profilePhoto
            } else {
                print("Profile Photo saving error")
            }
            
        }

        user.signUpInBackgroundWithBlock { [weak self](succeeded, error) in
            if succeeded {
                self?.dismissViewControllerAnimated(true, completion: { () -> Void in
                    let nc = NSNotificationCenter.defaultCenter()
                    nc.postNotificationName(accountStatusChangedNotification, object: nil)
                })
            } else if let error = error {
                // Something bad has occurred
                self?.showErrorView(error)
            }
        }
    }
    
    //MARK: - Helper
    func showErrorView(error: NSError) {
        let alertView = UIAlertController(title: "Error",
            message: error.localizedDescription, preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertView.addAction(OKAction)
        self.presentViewController(alertView, animated: true, completion: nil)
    }
}
