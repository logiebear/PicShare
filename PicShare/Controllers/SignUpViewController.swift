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

    @IBOutlet weak var signUpEmailInput: UITextField!
    @IBOutlet weak var signUpUserNameInput: UITextField!
    @IBOutlet weak var signUpPasswordInput: UITextField!
    @IBOutlet weak var signUpConfirmPasswordInput: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - User Actions
    @IBAction func signUpSubmitButton(sender: UIButton) {
        //Check empty field or inconsistent passwords
        if signUpEmailInput.text == nil || signUpUserNameInput.text == nil || signUpPasswordInput.text == nil || signUpConfirmPasswordInput.text == nil {
            let error = NSError(domain: "SuperSpecialDomain", code: -99, userInfo: [
                NSLocalizedDescriptionKey: "Please fill out all the fields!"
                ])
            self.showErrorView(error)
        }
        else if signUpPasswordInput.text! != signUpConfirmPasswordInput.text! {
            let error = NSError(domain: "SuperSpecialDomain", code: -99, userInfo: [
                NSLocalizedDescriptionKey: "Two passwords are different!"
                ])
            self.showErrorView(error)
        }
        
        let user = PFUser()
        user.email = signUpEmailInput.text
        user.username = signUpUserNameInput.text
        user.password = signUpPasswordInput.text
        user.signUpInBackgroundWithBlock { succeeded, error in
            if (succeeded) {
                //The registration was successful
                self.performSegueWithIdentifier("RegistrationSuccessful", sender: nil)
            } else if let error = error {
                //Something bad has occurred
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
