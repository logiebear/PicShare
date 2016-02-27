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
    @IBOutlet weak var finishedButton: UIButton!
 
    var hashtag = String()
    var user: PFUser? = PFUser.currentUser()
    var isPublic: Bool = false
    var password: String? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        finishedButton.backgroundColor = UIColor.redColor()
        finishedButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "AddPhoto" {
            let destViewController: AddPhotoViewController = segue.destinationViewController as! AddPhotoViewController
            destViewController.hashtag = hashtag
        }
    }
    // MARK: - User Actions
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func finishedButtonPressed(sender: AnyObject) {
        if eventPasswordTextField.text == "" ||  eventPasswordTextField.text == nil {
            self.showErrorView("Invalid password", msg: "Password can't be empty!")
            return
        }
        self.createEventObject()
    }
    
    // Mark: - Private
    
    private func createEventObject() {
        if let user = user, eventPasswordText = eventPasswordTextField.text {
            let event = Event(owner: user, hashtag: hashtag,
                isPublic: isPublic, password: eventPasswordText)
        
            event.saveInBackgroundWithBlock() { [weak self](success, error) -> Void in
                self?.performSegueWithIdentifier("AddPhoto", sender: nil)
            }
        }
    }
    
    // Mark: - Helper
    
    func showErrorView(title: String, msg: String) {
        let alertView = UIAlertController(title: title,
            message: msg, preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertView.addAction(OKAction)
        self.presentViewController(alertView, animated: true, completion: nil)
    }
}
