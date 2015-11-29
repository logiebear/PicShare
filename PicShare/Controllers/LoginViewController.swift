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

    @IBOutlet weak var loginUserNameInput: UITextField!
    @IBOutlet weak var loginPasswordInput: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    //MARK: - User Actions
    @IBAction func loginSubmitButton(sender: UIButton) {
        //Check username or password empty
        var error: NSError?
        var errorMsg: String = String()
        if loginUserNameInput.text == nil && loginPasswordInput.text == nil {
            errorMsg += "Please type in username and password!"
        }
        else if loginUserNameInput.text == nil {
            errorMsg += "Please type in username!"
        }
        else if loginPasswordInput.text == nil {
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
                self.performSegueWithIdentifier("LoginSuccessful", sender: nil)
            } else if let error = error {
                self.showErrorView(error)
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
