//
//  CreateEventController.swift
//  PicShare
//
//  Created by ZhouJiashun on 1/29/16.
//  Copyright © 2016 USC. All rights reserved.
//

import UIKit
import Parse

class CreateEventController: UIViewController, UITextFieldDelegate{

    // Mark: - Properties
    
    @IBOutlet weak var createEventButton: UIButton!
    @IBOutlet weak var eventNameTextField: UITextField!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var privateButton: UIButton!
    
    var hashtag: String? = nil
    var user: PFUser = PFUser.currentUser()!
    var isPublic: Bool = true
    var password: String? = nil
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destViewController : CreateEventPasswordViewController = segue.destinationViewController as! CreateEventPasswordViewController
        
        destViewController.hashtag = eventNameTextField.text!
        
    }
    
    // Mark: - User Actions
    
    @IBAction func createEventButtonPressed(sender: AnyObject) {
        if eventNameTextField.text == "" {
            let error = NSError(domain: "SuperSpecialDomain", code: -99, userInfo: [
                NSLocalizedDescriptionKey: "Event name can't be empty!"
                ])
            self.showErrorView(error)
            return
        }
        checkValid { (success) -> () in
            if success {
                self.createEventObject()
            }
        }
        
    }
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
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
                self.showSetPasswordView()
            }
        }
    }
    // Mark: - Private
    
    private func createEventObject() {
        
        let event = Event(owner: user,
            hashtag: eventNameTextField.text!,
            isPublic: isPublic,
            password: password
        )
        
       event.saveInBackgroundWithBlock({ [weak self]
            (success, error) -> Void in
            //self?.activityIndicatorViewControllerAnimating()
            self?.dismissViewControllerAnimated(true, completion: nil)
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
    
    func showSetPasswordView() {
        let SetPasswordView: UIViewController
        let mainStoryboard = UIStoryboard(name:"Main", bundle: nil)
        SetPasswordView = mainStoryboard.instantiateViewControllerWithIdentifier("SetPasswordView")
        self.showViewController(SetPasswordView, sender: self)
    }
}