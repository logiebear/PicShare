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
    
    var hashtag: String? = nil
    var user: PFUser = PFUser.currentUser()!
    var isPublic: Bool = true
    var password: String? = nil
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destViewController : CreateEventPasswordViewController = segue.destinationViewController as! CreateEventPasswordViewController
        
        destViewController.hashtag = eventNameTextField.text!
    }
    
    // Mark: - User Actions
    
    @IBAction func createPublicEvent(sender: AnyObject) {
        if eventNameTextField.text == nil {
            let error = NSError(domain: "SuperSpecialDomain", code: -99, userInfo: [
                NSLocalizedDescriptionKey: "Event name can't be empty!"])
            self.showErrorView(error)
        }
        self.createEventObject()
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
            //self?.activityIndicatorViewControllerAnimating()
            self?.dismissViewControllerAnimated(true, completion: nil)
        })
    }

    // Mark: - Helper
    
    func showErrorView(error: NSError) {
        let alertView = UIAlertController(title: "Error",
            message: error.localizedDescription, preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertView.addAction(OKAction)
        self.presentViewController(alertView, animated: true, completion: nil)
    }
    
}