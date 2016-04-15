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
        guard let eventName = eventNameTextField.text else {
            return
        }

        if segue.identifier == "SetPassword" {
            let destViewController = segue.destinationViewController as! CreateEventPasswordViewController
            destViewController.hashtag = eventName
        }
        if segue.identifier == "EventScreen" {
            let destViewController = segue.destinationViewController as! EventPhotoScreenViewController
            destViewController.event = event
            destViewController.sourceController = self
        }
    }
    
    // Mark: - User Actions
    
    @IBAction func createPublicEvent(sender: AnyObject) {
        if !networkReachable() {
            showAlert("No Internet Connection", message: "Please check your internet connection and try again.")
            return
        }
        guard let eventName = eventNameTextField.text where eventName != "" else {
            showErrorView("Invalid event name", msg: "Event name can't be empty!")
            return
        }
        
        for scalar in eventName.unicodeScalars {
            let value = scalar.value
            if !((value >= 65 && value <= 90) || (value >= 97 && value <= 122) || (value >= 48 && value <= 57) || (value == 95)) {
                showErrorView("Invalid event name", msg: "Event name can only include alphanumeric characters.")
                return
            }
        }
        
        let index = eventName.startIndex
        if eventName[index] == "_" {
            showAlert("Invalid event name", message: "Event name can't start with underscore!")
            return
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
        guard let eventName = eventNameTextField.text where eventName != "" else {
            showErrorView("Invalid event name", msg: "Event name can't be empty!")
            return
        }
        
        for scalar in eventName.unicodeScalars {
            let value = scalar.value
            if !((value >= 65 && value <= 90) || (value >= 97 && value <= 122) || (value >= 48 && value <= 57) || (value == 95)) {
                showErrorView("Invalid event name", msg: "Event name can only include alphanumeric characters.")
                return
            }
        }
        
        let index = eventName.startIndex
        if eventName[index] == "_" {
            showAlert("Invalid event name", message: "Event name can't start with underscore!")
            return
        }
        
        validateHashtag { (success) -> () in
            if success {
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
        guard let user = PFUser.currentUser(), eventName = eventNameTextField.text else {
            return
        }
        self.event = Event(owner: user, hashtag: eventName,
            isPublic: isPublic, password: password)
        self.event?.saveInBackgroundWithBlock() { [weak self](success, error) -> Void in
            self?.performSegueWithIdentifier("EventScreen", sender: nil)
        }
    }

    // Mark: - Helper
    
    func validateHashtag(completion: (Bool) -> ()) {
        guard let query = Event.query(), eventName = eventNameTextField.text else {
            return
        }
        query.whereKey("hashtag", equalTo: eventName)
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