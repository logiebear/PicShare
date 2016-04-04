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

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var searchEventTextField: UITextField!
    @IBOutlet weak var retrySearchTextField: UITextField!
    private var didPerformSearch = false
    
    override func viewDidLoad() {
        searchView.hidden = false
        scrollView.hidden = true
        
        let gestureRecognizer = UITapGestureRecognizer()
        gestureRecognizer.addTarget(self, action: "resignKeyboard")
        gestureRecognizer.delegate = self
        view.addGestureRecognizer(gestureRecognizer)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidHide",
                                                         name: UIKeyboardDidHideNotification, object: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "SearchResults" {
            let svc = segue.destinationViewController as! SearchEventResultsViewController
            svc.eventArray = sender as! [Event]
        }
    }
    
    // MARK: - User Actions
    
    @IBAction func searchEventButtonPressed(sender: AnyObject? = nil) {
        guard let searchText = searchEventTextField.text where searchText != "" else {
            showAlert("Invalid event name", message: "Event name can't be empty!")
            return
        }
        
        queryForSpecificEvents(searchText)
    }
    
    @IBAction func retrySearchEventButtonPressed(sender: AnyObject? = nil) {
        guard let searchText = retrySearchTextField.text where searchText != "" else {
            showAlert("Invalid event name", message: "Event name can't be empty!")
            return
        }
        
        queryForSpecificEvents(searchText)
    }
    
    @IBAction func createNewEventButtonPressed(sender: AnyObject) {
        performSegueWithIdentifier("NewEvent", sender: nil)
    }
    
    // MARK: - Helpers
    
    private func queryForSpecificEvents(searchText: String) {
        if didPerformSearch { return }
        didPerformSearch = true
        
        resignKeyboard()
        guard let query = Event.queryEventsWithSubstring(searchText) else {
            return
        }

        query.findObjectsInBackgroundWithBlock { [weak self](objects: [PFObject]?, error: NSError?) -> Void in
            self?.didPerformSearch = false
            if let error = error {
                // TODO: Find better error solution
                self?.showAlert("Error", message: error.localizedDescription)
                print("Error: \(error) \(error.userInfo)")
                return
            }
            
            print("Event query success. Number events: \(objects?.count)")
            if let events = objects as? [Event] where events.count > 0 {
                self?.performSegueWithIdentifier("SearchResults", sender: events)
            } else {
                self?.eventNameLabel.text = searchText
                self?.retrySearchTextField.text = nil
                self?.searchView.hidden = true
                self?.scrollView.hidden = false
            }
        }
    }
    
    func resignKeyboard() {
        searchEventTextField.resignFirstResponder()
        retrySearchTextField.resignFirstResponder()
    }
    
    // MARK: Notification
    
    func keyboardDidHide() {
        scrollView.setContentOffset(CGPointZero, animated: true)
    }
    
}

// MARK: - UITextFieldDelegate

extension SearchEventViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == searchEventTextField {
            searchEventTextField.resignFirstResponder()
            searchEventButtonPressed()
        } else if textField == retrySearchTextField {
            retrySearchTextField.resignFirstResponder()
            retrySearchEventButtonPressed()
        }
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField == retrySearchTextField {
            UIView.animateWithDuration(0.25) {
                self.scrollView.setContentOffset(CGPoint(x: 0, y: 150), animated: false)
            }
        }
    }
    
}

// MARK: - UIGestureRecognizerDelegate

extension SearchEventViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if let view = touch.view where view is UIControl {
            return false
        }
        return true
    }
    
}
