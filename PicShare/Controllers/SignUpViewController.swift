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
    var user: User!
    
    // MARK: - User Actions
    @IBAction func backButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func goButton(sender: UIButton) {
        //Check empty field or inconsistent passwords
        if emailTextField.text == "" || userNameTextField.text == "" || passwordTextField.text == "" || passwordConfirmTextField.text == "" {
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
        //Check whether email or username is taken
        let query = PFUser.query()
        if let emailTextField = emailTextField.text {
            if let query = query {
                query.whereKey("email", equalTo: emailTextField)
                query.findObjectsInBackgroundWithBlock {
                    (objects: [PFObject]?, error: NSError?) in
                    if error == nil {
                        if (objects!.count > 0){
                            let error = NSError(domain: "SuperSpecialDomain", code: -99, userInfo: [
                                NSLocalizedDescriptionKey: "Email address has been taken!"
                                ])
                            self.showErrorView(error)
                        }
                        else {
                            if let userNameTextField = self.userNameTextField.text {
                                let query1 = PFUser.query()
                                if let query1 = query1 {
                                    query1.whereKey("username", equalTo: userNameTextField )
                                    query1.findObjectsInBackgroundWithBlock {
                                        (objects: [PFObject]?, error: NSError?) in
                                        if error == nil {
                                            if (objects!.count > 0){
                                                let error = NSError(domain: "SuperSpecialDomain", code: -99, userInfo: [
                                                    NSLocalizedDescriptionKey: "Username has been taken!"
                                                    ])
                                                self.showErrorView(error)
                                            }
                                            else {
                                                if let passwordTextField = self.passwordTextField.text {
                                                    self.user = User(email: emailTextField, username: userNameTextField, password: passwordTextField, profilePhoto: nil)
                                                }
                                                self.performSegueWithIdentifier("ShowProfilePhotoScreen", sender: self)
                                            }
                                        }
                                        else {
                                            print("error occured")
                                        }
                                    }
                                }
                            }
                        }
                    }
                    else {
                        print("error occured")
                    }
                }
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        let svc = segue.destinationViewController as! ProfilePhotoViewController
        svc.userInfo = user
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
