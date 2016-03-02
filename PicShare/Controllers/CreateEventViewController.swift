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
    @IBOutlet weak var privateButton: UIButton!    
    var hashtag: String?
    var password: String?
    var isPublic = true

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let eventNameText = eventNameTextField.text else {
            return
        }

        if segue.identifier == "SetPassword" {
            let destViewController: CreateEventPasswordViewController = segue.destinationViewController as! CreateEventPasswordViewController
            destViewController.hashtag = eventNameText
        }
        if segue.identifier == "AddPhoto" {
            let destViewController: AddPhotoViewController = segue.destinationViewController as! AddPhotoViewController
            destViewController.hashtag = eventNameText
        }
    }
    
    // Mark: - User Actions
    
    @IBAction func createPublicEvent(sender: AnyObject) {
        if eventNameTextField.text == "" || eventNameTextField.text == nil {
            showErrorView("Invalid event name", msg: "Event name can't be empty!")
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
        if eventNameTextField.text == "" || eventNameTextField.text == nil {
            showErrorView("Invalid event name", msg: "Event name can't be empty!")
            return
        }
        
        validateHashtag { (success) -> () in
            if success {
                self.performSegueWithIdentifier("SetPassword", sender: nil)
            }
        }
    }
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Mark: - Private
    
    private func createEventObject() {
        guard let user = PFUser.currentUser(), eventNameText = eventNameTextField.text else {
            return
        }

        let event = Event(owner: user, hashtag: eventNameText,
            isPublic: isPublic, password: password)
        event.saveInBackgroundWithBlock() { [weak self](success, error) -> Void in
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