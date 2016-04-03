//
//  LoginViewController.swift
//  PicShare
//
//  Created by Logan Chang on 11/26/15.
//  Copyright © 2015 USC. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var loginUserNameInput: UITextField!
    @IBOutlet weak var loginPasswordInput: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gestureRecognizer = UITapGestureRecognizer()
        gestureRecognizer.addTarget(self, action: "resignKeyboard")
        gestureRecognizer.delegate = self
        view.addGestureRecognizer(gestureRecognizer)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidHide",
                                                         name: UIKeyboardDidHideNotification, object: nil)
    }
    
    //MARK: - User Actions
    
    @IBAction func loginSubmitButton(sender: UIButton) {
        //Check username or password empty
        var error: NSError?
        var errorMsg: String = String()
        if loginUserNameInput.text == "" && loginPasswordInput.text == "" {
            errorMsg += "Please type in username and password!"
        }
        else if loginUserNameInput.text == "" {
            errorMsg += "Please type in username!"
        }
        else if loginPasswordInput.text == "" {
            errorMsg += "Please type in password!"
        }
        if !errorMsg.isEmpty {
            error = NSError(domain: "SuperSpecialDomain", code: -99, userInfo: [
                NSLocalizedDescriptionKey: errorMsg                ])
        }
        if let error = error {
            self.showErrorView(error)
            return
        }
        
        PFUser.logInWithUsernameInBackground(loginUserNameInput.text!, password: loginPasswordInput.text!) { user, error in
            if user != nil {
                NSNotificationCenter.defaultCenter().postNotificationName(accountStatusChangedNotification, object: nil)
            } else if let error = error {
                self.showErrorView(error)
            }
        }
    }
    
    // MARK: - Helper
    
    func showErrorView(error: NSError) {
        let alertView = UIAlertController(title: "Error",
            message: error.localizedDescription, preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertView.addAction(OKAction)
        self.presentViewController(alertView, animated: true, completion: nil)
    }
    
    func resignKeyboard() {
        loginUserNameInput.resignFirstResponder()
        loginPasswordInput.resignFirstResponder()
    }
    
    // MARK: Notification
    
    func keyboardDidHide() {
        scrollView.setContentOffset(CGPointZero, animated: true)
    }
}

// MARK: - UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.loginUserNameInput {
            loginPasswordInput.becomeFirstResponder()
        } else {
            loginPasswordInput.resignFirstResponder()
            loginSubmitButton(loginButton)
        }
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        UIView.animateWithDuration(0.25) {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: 40), animated: false)
        }
    }
    
}

// MARK: - UIGestureRecognizerDelegate

extension LoginViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if let view = touch.view where view is UIControl {
            return false
        }
        return true
    }
    
}
