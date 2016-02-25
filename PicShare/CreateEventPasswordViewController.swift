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
    var user: PFUser = PFUser.currentUser()!
    var isPublic: Bool = false
    var password: String? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        /*if !UIImagePickerController.isSourceTypeAvailable(.Camera) {
        takePhotoButton.hidden = true // check if device have camera
        }
        */
        finishedButton.backgroundColor = UIColor.redColor()
        finishedButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "AddPhoto" {
            let destViewController : AddPhotoViewController = segue.destinationViewController as! AddPhotoViewController
            
            destViewController.hashtag = hashtag
        
        }
    }
    // MARK: - User Actions
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func finishedButtonPressed(sender: AnyObject) {
        if eventPasswordTextField.text == "" {
            let error = NSError(domain: "SuperSpecialDomain", code: -99, userInfo: [
                NSLocalizedDescriptionKey: "Password can't be empty!"
                ])
            self.showErrorView(error)
            return
        }
        self.createEventObject()
    }
    
    
    
    // Mark: - Private
    
    private func createEventObject() {
        
        let event = Event(owner: user,
            hashtag: hashtag,
            isPublic: isPublic,
            password: eventPasswordTextField.text!
        )
        
        event.saveInBackgroundWithBlock({ [weak self]
            (success, error) -> Void in
            //self?.activityIndicatorViewControllerAnimating()
            //self?.dismissViewControllerAnimated(true, completion: nil)
            self?.performSegueWithIdentifier("AddPhoto", sender: nil)
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
