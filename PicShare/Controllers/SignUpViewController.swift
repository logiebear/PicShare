//
//  SignUpViewController.swift
//  PicShare
//
//  Created by Logan Chang on 11/27/15.
//  Copyright © 2015 USC. All rights reserved.
//

import UIKit
import Parse

class SignUpViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordConfirmTextField: UITextField!
    
    
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
        
        let user = PFUser()
        user.email = emailTextField.text
        user.username = userNameTextField.text
        user.password = passwordTextField.text
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
