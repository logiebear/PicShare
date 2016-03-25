//
//  CreateEventPasswordViewController.swift
//  PicShare
//
//  Created by ZhouJiashun on 2/9/16.
//  Copyright © 2016 USC. All rights reserved.
//

import UIKit
import Parse

class CreateEventPasswordViewController: UIViewController{

    // Mark: - Properties
    
    @IBOutlet weak var eventPasswordTextField: UITextField!
    
    var hashtag: String?
    var user: PFUser? = PFUser.currentUser()
    var isPublic: Bool = false
    var password: String? = nil
    var event: Event?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "AddPhoto" {
            let destViewController = segue.destinationViewController as! AddPhotoViewController
            destViewController.hashtag = hashtag
            destViewController.event = event
        }
    }
    
    // MARK: - User Actions
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func finishedButtonPressed(sender: AnyObject) {
        if eventPasswordTextField.text == "" ||  eventPasswordTextField.text == nil {
            showErrorView("Invalid password", msg: "Password can't be empty!")
            return
        }
        
        guard let eventPasswordTextField = eventPasswordTextField.text else {
            return
        }
        
        for scalar in eventPasswordTextField.unicodeScalars {
            let value = scalar.value
            if !((value >= 65 && value <= 90) || (value >= 97 && value <= 122) || (value >= 48 && value <= 57)) {
                showErrorView("Invalid password", msg: "Password can only conclude alphanumerics!")
                return
            }
        }
        
        self.createEventObject()
    }
    
    // Mark: - Private
    
    private func createEventObject() {
        guard let user = user, eventPasswordText = eventPasswordTextField.text, hashtag = self.hashtag else {
            return
        }
        self.event = Event(owner: user, hashtag: hashtag,
            isPublic: isPublic, password: eventPasswordText)
        self.event?.saveInBackgroundWithBlock() { [weak self](success, error) -> Void in
            self?.performSegueWithIdentifier("AddPhoto", sender: nil)
        }
    }
    
    // Mark: - Helper
    
    func showErrorView(title: String, msg: String) {
        let alertView = UIAlertController(title: title,
            message: msg, preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertView.addAction(OKAction)
        presentViewController(alertView, animated: true, completion: nil)
    }
}
