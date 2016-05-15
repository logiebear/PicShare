//
//  EventSearchResultsViewController.swift
//  PicShare
//
//  Created by Yuan on 2/20/16.
//  Copyright © 2016 USC. All rights reserved.
//

import Foundation
import UIKit
import Parse
import ParseUI

class SearchEventResultsViewController: UIViewController {
    
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var resultTableView: UITableView!
    @IBOutlet weak var popUpEventName: UILabel!
    @IBOutlet weak var quitEnterPasswordButton: UIButton!
    var eventArray = [Event]()
    private var user: User?
    private var userEventArray = [Event]()
    private var selectedEvent: Event?
    private var selectedPrivateEventCell: SearchEventTableViewCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.bringSubviewToFront(popupView)
        popupView.alpha = 0.0
        queryForAllUserEvents()
    }
    
    /**
        Prepare for segue to creating new events page
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "SpecificEventPreview" {
            let svc = segue.destinationViewController as! EventPhotoScreenViewController
            if let event = selectedEvent {
                svc.event = event
            }
        }
    }
    
    // MARK: - User Actions
    
    @IBAction func closePopup(sender: AnyObject) {
        passwordTextField.resignFirstResponder()
        hidePasswordPopup()
    }
    
    @IBAction func enterPrivateEvent(sender: AnyObject) {
        guard let event = selectedEvent else {
            return
        }
        
        if passwordTextField.text == event.password {
            addEventToUserEvents(event)
            selectedPrivateEventCell?.showJoinAnimation()
            hidePasswordPopup()
            event.owner.fetchIfNeededInBackgroundWithBlock { (object, error) -> Void in
                if error == nil {
                    self.performSegueWithIdentifier("SpecificEventPreview", sender: self)
                }
            }
        } else {
            showAlert("Incorrect Password", message: "Please try again.")
        }
    }
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: - Private
    /**
        Query for all current user's joined events
     */
    private func queryForAllUserEvents() {
        guard let query = User.allEventsForCurrentUserQuery() else {
            return
        }
        
        query.getFirstObjectInBackgroundWithBlock { [weak self](objects: PFObject?, error: NSError?) -> Void in
            if error == nil {
                guard let user = objects as? User else {
                    return
                }
                self?.user = user
                self?.userEventArray = user.events ?? []
                print("User events query success. Number events: \(self?.userEventArray.count)")
            } else {
                print("Error: \(error!) \(error!.userInfo)")
            }
            self?.resultTableView.reloadData()
        }
    }
    
    /**
        Pop up private event password panel
     */
    private func showPasswordPopup() {
        passwordTextField.text = nil
        UIView.animateWithDuration(0.5) { 
            self.popupView.alpha = 1.0
        }
    }
    
    /**
        Hide private event password panel
     */
    private func hidePasswordPopup() {
        UIView.animateWithDuration(0.5) {
            self.popupView.alpha = 0.0
        }
    }
    
    /**
        Add event into user's joined event list
     
        -Parameter:
            - event: the event user wants to join
     */
    private func addEventToUserEvents(event: Event) {
        guard let user = self.user else  {
            print("Error no user")
            return
        }
        if user.events == nil {
            user.events = [Event]()
        }
        user.events?.append(event)
        user.saveInBackground()
        userEventArray.append(event)
    }
    
    /**
        Calculate event's left days
     
        -Parameter:
            -start: event's created date
            -end: current system date
     
        -Return:
            -day: the day left before event expires.
     */
    private func calculateDays(start: NSDate, end: NSDate) -> Int {
        let calendar: NSCalendar = NSCalendar.currentCalendar()
        let date1 = calendar.startOfDayForDate(start)
        let date2 = calendar.startOfDayForDate(end)
        let flags = NSCalendarUnit.Day
        let components = calendar.components(flags, fromDate: date1, toDate: date2, options: [])
        return components.day
    }
    
}

// MARK: - UITableViewDataSource

extension SearchEventResultsViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        /**
            Set cell for each event, including event name, whether private, remaining days and join button
         */
        let cell = tableView.dequeueReusableCellWithIdentifier("TextCell", forIndexPath: indexPath) as! SearchEventTableViewCell
        let event = eventArray[indexPath.row]
        cell.eventLabel.text = event.hashtag
        cell.event = event
        cell.delegate = self
        // Show checkmark if event is owned or joined by user
        if userEventArray.contains(event) || event.owner.objectId == user?.objectId {
            cell.joinButton.alpha = 0.0
            cell.checkmarkImageView.alpha = 1.0
        } else {
            // Otherwise show join button
            cell.joinButton.alpha = 1.0
            cell.checkmarkImageView.alpha = 0.0
        }
        
        var dayLeft = ""
        if let createdAt = event.createdAt {
            let intervals = self.calculateDays(createdAt, end: NSDate())
            dayLeft = "⎪ \(7 - intervals) days left"
        }
        
        let eventCategory = event.isPublic ? "Public" : "Private"
        cell.sublabel.text = eventCategory + " Event " + dayLeft
        return cell
    }
    
}

// MARK: - UITableViewDelegate

extension SearchEventResultsViewController: UITableViewDelegate {

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        resultTableView.deselectRowAtIndexPath(indexPath, animated: true)
        selectedEvent = eventArray[indexPath.row]
        guard let selectedEvent = selectedEvent else {
            return
        }
        /**
            Pop up the password panel while clicking on the unjoined private event to join it, or viewing all photos of clicked public event
         */
        if !selectedEvent.isPublic && !userEventArray.contains(selectedEvent) && selectedEvent.owner.objectId != user?.objectId {
            popUpEventName.text = selectedEvent.hashtag
            showPasswordPopup()
        } else {
            // Otherwise fetch event and display it
            selectedEvent.owner.fetchIfNeededInBackgroundWithBlock { (object, error) -> Void in
                if error == nil {
                    self.performSegueWithIdentifier("SpecificEventPreview", sender: self)
                }
            }
        }
    }
}

// MARK: - SearchEventTableViewCellDelegate

extension SearchEventResultsViewController: SearchEventTableViewCellDelegate {
    /**
        Prepare for user's joining the public event or private event.
        
        -Parameter:
            - cell: current event cell
            - event: the event user wants to join
     */
    func joinEvent(cell: SearchEventTableViewCell, event: Event) {
        if event.isPublic {
            // If event is public add to user events
            addEventToUserEvents(event)
        } else {
            // If event is private show password popup
            popUpEventName.text = event.hashtag
            selectedEvent = event
            selectedPrivateEventCell = cell
            showPasswordPopup()
        }
    }
    
}
