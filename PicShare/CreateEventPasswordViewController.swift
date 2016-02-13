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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - User Actions
    
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
            self!.showEventMgmtView()
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
    
    func showEventMgmtView() {
        let EventMgmtView: UIViewController
        let mainStoryboard = UIStoryboard(name:"Main", bundle: nil)
        EventMgmtView = mainStoryboard.instantiateViewControllerWithIdentifier("EventMgmtView")
        self.showViewController(EventMgmtView, sender: self)
        
    }

}
