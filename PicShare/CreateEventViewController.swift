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
    var user: PFUser = PFUser.currentUser()!
    var isPublic: Bool = true
    var password: String? = nil
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SetPassword" {
            let destViewController : CreateEventPasswordViewController = segue.destinationViewController as! CreateEventPasswordViewController
        
            destViewController.hashtag = eventNameTextField.text!
        }
        if segue.identifier == "AddPhoto" {
            let destViewController : AddPhotoViewController = segue.destinationViewController as! AddPhotoViewController
            
            destViewController.hashtag = eventNameTextField.text!
        
        }
    }
    
    // Mark: - User Actions
    
    @IBAction func createPublicEvent(sender: AnyObject) {
        if eventNameTextField.text == "" {
            let error = NSError(domain: "SuperSpecialDomain", code: -99, userInfo: [
                NSLocalizedDescriptionKey: "Event name can't be empty!"])
            self.showErrorView(error)
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
            let error = NSError(domain: "SuperSpecialDomain", code: -99, userInfo: [
                NSLocalizedDescriptionKey: "Event name can't be empty!"
                ])
            self.showErrorView(error)
            return
        }
        checkValid { (success) -> () in
            if success {
                //self.showSetPasswordView()
                self.performSegueWithIdentifier("SetPassword", sender: nil)
            }
        }
    }
    
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Mark: - Private
    
    private func createEventObject() {
        let event = Event(owner: user, hashtag: eventNameTextField.text!,isPublic: isPublic,
            password: password
        )
        
       event.saveInBackgroundWithBlock({ [weak self]
            (success, error) -> Void in
            self?.performSegueWithIdentifier("AddPhoto", sender: nil)
        })
    }

    // Mark: - Helper
    func checkValid(completion: ((Bool) -> ())) {
        guard let query = Event.query() else {
            return
        }
        if let eventNameTextField = eventNameTextField.text {
            query.whereKey("hashtag", equalTo: eventNameTextField)
            query.findObjectsInBackgroundWithBlock { [weak self](objects: [PFObject]?, error: NSError?) -> Void in
                if let objects = objects where objects.count == 0{
                    completion(true)
                } else {
                    let error = NSError(domain: "SuperSpecialDomain", code: -99, userInfo: [
                        NSLocalizedDescriptionKey: "Event name has been taken!"])
                    self?.showErrorView(error)
                    completion(false)
                }
            }
        }
    }
    
    func showErrorView(error: NSError) {
        let alertView = UIAlertController(title: "Error",
            message: error.localizedDescription, preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertView.addAction(OKAction)
        self.presentViewController(alertView, animated: true, completion: nil)
    }
    
}