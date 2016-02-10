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
    
    var hashtag: String = " "
    var user: PFUser = PFUser.currentUser()!
    var isPublic: Bool = true
    var password: String? = nil
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        // Handle the text field's user input through delegate callbacks.
        eventNameTextField.delegate = self
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destViewController : CreateEventPasswordViewController = segue.destinationViewController as! CreateEventPasswordViewController
        
        destViewController.hashtag = eventNameTextField.text!
        
    }
    
    // Mark: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        // Hide the keyboard
        eventNameTextField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if let text = eventNameTextField.text{
            hashtag = text
        }else{
            // TO DO: - Show error message
        }
    }
    
    // Mark: - User Actions
    
    
    
    @IBAction func createEventButtonPressed(sender: AnyObject) {
        
        self.createEventObject()
    }
    
    
    
    // Mark: - Private
    
    private func createEventObject() {
        
        let event = Event(owner: user,
            hashtag: hashtag,
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
    

}