//
//  CreateEventViewController.swift
//  PicShare
//
//  Created by ZhouJiashun on 1/29/16.
//  Copyright © 2016 USC. All rights reserved.
//

import UIKit
import Parse

class CreateEventViewController: UIViewController, UITextFieldDelegate{

    // Mark: - Properties
    
    @IBOutlet weak var eventNameTextField: UITextField!
    
    var hashtag: String?
    var password: String?
    var isPublic = true
    var event: Event?

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let eventNameTextField = eventNameTextField.text else {
            return
        }

        if segue.identifier == "SetPassword" {
            let destViewController: CreateEventPasswordViewController = segue.destinationViewController as! CreateEventPasswordViewController
            destViewController.hashtag = eventNameTextField
        }
        if segue.identifier == "AddPhoto" {
            let destViewController: AddPhotoViewController = segue.destinationViewController as! AddPhotoViewController
            destViewController.hashtag = eventNameTextField
            destViewController.event = event
        }
    }
    
    // Mark: - User Actions
    
    @IBAction func createPublicEvent(sender: AnyObject) {
        if eventNameTextField.text == "" || eventNameTextField.text == nil {
            showErrorView("Invalid event name", msg: "Event name can't be empty!")
            return
        }
        
        guard let eventNameTextField = eventNameTextField.text else {
            return
        }
        
        for scalar in eventNameTextField.unicodeScalars {
            let value = scalar.value
            if !((value >= 65 && value <= 90) || (value >= 97 && value <= 122) || (value >= 48 && value <= 57)) {
                showErrorView("Invalid event name", msg: "Event name can only include alphanumeric characters.")
                return
            }
        }
        
        validateHashtag { [weak self](success) -> () in
            if success {
                self?.createEventObject()
            } else {
                self?.showErrorView("Invalid event name", msg: "Event name has been taken!")
            }
        }
    }
    
    @IBAction func privateButtonPressed(sender: AnyObject) {
        if eventNameTextField.text == "" || eventNameTextField.text == nil {
            showErrorView("Invalid event name", msg: "Event name can't be empty!")
            return
        }

        guard let eventNameText = eventNameTextField.text else {
            return
        }
        
        for scalar in eventNameText.unicodeScalars {
            let value = scalar.value
            if !((value >= 65 && value <= 90) || (value >= 97 && value <= 122) || (value >= 48 && value <= 57)) {
                showErrorView("Invalid event name", msg: "Event name can only include alphanumeric characters.")
                return
            }
        }
        
        
        validateHashtag { (success) -> () in
            if success {
                NSLog("here1")
                self.performSegueWithIdentifier("SetPassword", sender: nil)
                
            } else {
                self.showErrorView("Invalid event name", msg: "Event name has been taken!")
            }
        }
    }
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    // Mark: - Private
    
    private func createEventObject() {
        guard let user = PFUser.currentUser(), eventNameText = eventNameTextField.text else {
            return
        }
        self.event = Event(owner: user, hashtag: eventNameText,
            isPublic: isPublic, password: password)
        self.event?.saveInBackgroundWithBlock() { [weak self](success, error) -> Void in
            self?.performSegueWithIdentifier("AddPhoto", sender: nil)
        }
    }

    // Mark: - Helper
    
    func validateHashtag(completion: (Bool) -> ()) {
        guard let query = Event.query(), eventNameTextField = eventNameTextField.text else {
            return
        }
        query.whereKey("hashtag", equalTo: eventNameTextField)
        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            if let objects = objects where objects.isEmpty {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func showErrorView(title: String, msg: String) {
        let alertView = UIAlertController(title: title,
            message: msg, preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertView.addAction(OKAction)
        self.presentViewController(alertView, animated: true, completion: nil)
    }
}