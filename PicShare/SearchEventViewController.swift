//
//  SearchEventViewController.swift
//  PicShare
//
//  Created by Yuan on 2/20/16.
//  Copyright © 2016 USC. All rights reserved.
//

import Foundation
import UIKit
import Parse
import ParseUI

class SearchEventViewController: UIViewController {

    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var noResultsView: UIView!
    @IBOutlet weak var eventNameTextField: UITextField!
    @IBOutlet weak var eventSearchButton: UIButton!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var createNewEventButton: UIButton!
    @IBOutlet weak var dividingLineView: UIImageView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    var eventArray: [Event]?
    
    override func viewDidLoad() {
        logo.image = UIImage(named: "logo")
        dividingLineView.image = UIImage(named: "orBarImage")
        let sharpIcon = UIImage(named: "hashtag")
        createNewEventButton.frame = CGRectMake(18, 15, 28, 25)
        createNewEventButton.setImage(sharpIcon, forState: .Normal)
        eventSearchButton.frame = CGRectMake(18, 15, 28, 25)
        eventSearchButton.setImage(sharpIcon, forState: .Normal)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "SearchResults") {
            let svc = segue.destinationViewController as! SearchEventResultsViewController;
            svc.eventArray = eventArray
        }
    }
    
    // MARK: - User Actions
    @IBAction func backButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func searchEventButtonPressed(sender: AnyObject) {
        if eventNameTextField.text == "" || eventNameTextField.text == nil {
            showAlert("Invalid event name", message: "Event name can't be empty!")
            return
        } else {
            self.queryForSpecificEvents(eventNameTextField.text!)
        }
    }
    
    // MARK: - Private
    
    private func queryForSpecificEvents(event: String) {
        guard let query = Event.queryEventsWithSubstring(event) else {
            return
        }

        query.findObjectsInBackgroundWithBlock { [weak self](objects: [PFObject]?, error: NSError?) -> Void in
            if let error = error {
                // TODO:
                print("Error: \(error) \(error.userInfo)")
                return
            }
            self?.eventArray = objects as? [Event]
            print("Event query success. Number events: \(objects?.count)")
            if objects?.count != 0 {
                self?.performSegueWithIdentifier("SearchResults", sender: nil)
                self?.promptLabel.text = "Search for event keywords"
            } else {
                self?.eventNameLabel.text = self?.eventNameTextField.text
                self?.promptLabel.text = "Try again with different keywords."
            }
            self?.eventNameTextField.text = nil
        }
    }
    
    // MARK: - Helpers
    
    private func showAlert(title: String, message: String) {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertView.addAction(okAction)
        presentViewController(alertView, animated: true, completion: nil)
    }
}