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

///Sign up screen allowing users to sign up new accounts
class SignUpViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordConfirmTextField: UITextField!
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userNameTextField.delegate = self
        let gestureRecognizer = UITapGestureRecognizer()
        gestureRecognizer.addTarget(self, action: "resignKeyboard")
        gestureRecognizer.delegate = self
        view.addGestureRecognizer(gestureRecognizer)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidHide",
                                                         name: UIKeyboardDidHideNotification, object: nil)
    }
    
    // MARK: - User Actions
    
    /**
        Redirect user back to login screen
    
        -Parameters:
            -sender: The sender of the function
    */
    @IBAction func LoginButton(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    /**
        Sign up a new account and redirect user to setting profile photo screen
     
        -Parameters:
            -sender: The sender of the function
     */
    @IBAction func goButton(sender: UIButton) {
        var error: NSError?
        ///Check empty field or inconsistent passwords
        if emailTextField.text == "" || userNameTextField.text == "" || passwordTextField.text == "" || passwordConfirmTextField.text == "" {
            error = NSError(domain: "SuperSpecialDomain", code: -99, userInfo: [
                NSLocalizedDescriptionKey: "Please fill out all the fields!"
                ])
        } else if passwordTextField.text! != passwordConfirmTextField.text! {
            error = NSError(domain: "SuperSpecialDomain", code: -99, userInfo: [
                NSLocalizedDescriptionKey: "Two passwords are different!"
                ])
        } else if !isValidEmail(emailTextField.text!) {
            error = NSError(domain: "SuperSpecialDomain", code: -99, userInfo: [
                NSLocalizedDescriptionKey: "Invalid email address!"
                ])
        }
        if let error = error {
            self.showErrorView(error)
            return
        }
        
        ///Check whether email or username is taken
        User.registerSubclass()
        let query = PFUser.query()
        if let emailTextField = emailTextField.text {
            if let query = query {
                query.whereKey("email", equalTo: emailTextField)
                query.findObjectsInBackgroundWithBlock {
                    (objects: [PFObject]?, error: NSError?) in
                    if error == nil {
                        //Email has been taken
                        if (objects!.count > 0){
                            let error = NSError(domain: "SuperSpecialDomain", code: -99, userInfo: [
                                NSLocalizedDescriptionKey: "Email address has been taken!"])
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
                                            //Username has been taken
                                            if (objects!.count > 0){
                                                let error = NSError(domain: "SuperSpecialDomain", code: -99, userInfo: [
                                                    NSLocalizedDescriptionKey: "Username has been taken!"
                                                    ])
                                                self.showErrorView(error)
                                            }
                                            else {
                                                if let passwordTextField = self.passwordTextField.text {
                                                    self.user = User(email: emailTextField, username: userNameTextField, password: passwordTextField, profilePhoto: nil, events: nil)
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
        svc.user = user
    }
    
    // MARK: Helper
    
    /**
        Show error with a pop window.
    
        -Parameters:
            -error: The error to be shown
    */
    func showErrorView(error: NSError) {
        let alertView = UIAlertController(title: "Error",
                                          message: error.localizedDescription, preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertView.addAction(OKAction)
        self.presentViewController(alertView, animated: true, completion: nil)
    }
    
    /**
        Valid email address format
     
        -Parameters:
            -testStr: The input email address
     
        -Returns: bool result whether email address format is valid
    */
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let range = testStr.rangeOfString(emailRegEx, options:.RegularExpressionSearch)
        let result = range != nil
        return result
    }
    
    /**
        Resign keyboard
    */
    func resignKeyboard() {
        emailTextField.resignFirstResponder()
        userNameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        passwordConfirmTextField.resignFirstResponder()
    }
    
    // MARK: Notification
    /**
        Adjust scroll view
    */
    func keyboardDidHide() {
        scrollView.setContentOffset(CGPointZero, animated: true)
    }
}

// MARK: - UITextFieldDelegate

extension SignUpViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == emailTextField {
            userNameTextField.becomeFirstResponder()
        } else if textField == userNameTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            passwordConfirmTextField.becomeFirstResponder()
        } else {
            passwordConfirmTextField.resignFirstResponder()
            goButton(UIButton())
        }
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        UIView.animateWithDuration(0.25) {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: 40), animated: false)
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string:
        String) -> Bool {
        
        if textField == userNameTextField {
            // Create an `NSCharacterSet` set which includes everything *but* the digits
            let inverseSet = NSCharacterSet(charactersInString:"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ").invertedSet
            
            // At every character in this "inverseSet" contained in the string,
            // split the string up into components which exclude the characters
            // in this inverse set
            let components = string.componentsSeparatedByCharactersInSet(inverseSet)
            
            // Rejoin these components
            let filtered = components.joinWithSeparator("")
            // If the original string is equal to the filtered string, i.e. if no
            // inverse characters were present to be eliminated, the input is valid
            // and the statement returns true; else it returns false
            return string == filtered
        }
        return true
    }
    
}

// MARK: - UIGestureRecognizerDelegate

extension SignUpViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if let view = touch.view where view is UIControl {
            return false
        }
        return true
    }
    
}