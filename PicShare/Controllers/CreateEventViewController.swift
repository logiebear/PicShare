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
    
    var hashtag: String? = nil
    var user: PFUser? = PFUser.currentUser()
    var isPublic: Bool = true
    var password: String? = nil
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let eventNameText = eventNameTextField.text{
            if segue.identifier == "SetPassword" {
                let destViewController: CreateEventPasswordViewController = segue.destinationViewController as! CreateEventPasswordViewController
                destViewController.hashtag = eventNameText
            }
            if segue.identifier == "AddPhoto" {
                let destViewController: AddPhotoViewController = segue.destinationViewController as! AddPhotoViewController
                destViewController.hashtag = eventNameText
            }
        }
    }
    
    // Mark: - User Actions
    
    @IBAction func createPublicEvent(sender: AnyObject) {
        if eventNameTextField.text == "" || eventNameTextField.text == nil {
            self.showErrorView("Invalid event name", msg: "Event name can't be empty!")
            return
        }
        checkValid { (success) -> () in
            if success {
                self.createEventObject()
            }
        }
    }
    
    @IBAction func privateButtonPressed(sender: AnyObject) {
        if eventNameTextField.text == "" {
            self.showErrorView("Invalid event name", msg: "Event name can't be empty!")
            return
        }
        checkValid { (success) -> () in
            if success {
                self.performSegueWithIdentifier("SetPassword", sender: nil)
            }
        }
    }
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Mark: - Private
    
    private func createEventObject() {
        if let user = user, eventNameText = eventNameTextField.text{
            let event = Event(
                owner: user,
                hashtag: eventNameText,
                isPublic: isPublic,
                password: password
            )
            event.saveInBackgroundWithBlock({ [weak self](success, error) -> Void in
                self?.performSegueWithIdentifier("AddPhoto", sender: nil)
            })
        }
    }

    // Mark: - Helper
    func checkValid(completion: (Bool) -> ()) {
        guard let query = Event.query() else {
            return
        }
        if let eventNameTextField = eventNameTextField.text {
            query.whereKey("hashtag", equalTo: eventNameTextField)
            query.findObjectsInBackgroundWithBlock { [weak self](objects: [PFObject]?, error: NSError?) -> Void in
                if let objects = objects where objects.count == 0{
                    completion(true)
                } else {
                    self?.showErrorView("Invalid event name", msg: "Event name has been taken!")
                    completion(false)
                }
            }
        }
    }
    
    func showErrorView(title: String, msg: String) {
        let alert = UIAlertView(title: title,
            message: msg,
            delegate: nil, cancelButtonTitle: "Try Again")
        alert.show()
    }
}