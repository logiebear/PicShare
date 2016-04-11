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
    private var selectedPrivateEvent: Event?
    private var selectedEvent: Event?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.bringSubviewToFront(popupView)
        popupView.alpha = 0.0
        queryForAllUserEvents()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "SpecificEventPreview" {
            let svc = segue.destinationViewController as! EventPhotoScreenViewController
            if let event = selectedEvent {
                svc.event = event
                svc.userEventArray = userEventArray
                svc.user = user
            }
        }
    }
    
    // MARK: - User Actions
    
    @IBAction func closePopup(sender: AnyObject) {
        hidePasswordPopup()
    }
    
    @IBAction func enterPrivateEvent(sender: AnyObject) {
        guard let event = selectedPrivateEvent else {
            return
        }
        
        if passwordTextField.text == event.password {
            addEventToUserEvents(event)
            resultTableView.reloadData()
            hidePasswordPopup()
        } else {
            showAlert("Incorrect Password", message: "Please try again.")
        }
    }
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: - Private
    
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
    
    private func showPasswordPopup() {
        passwordTextField.text = nil
        UIView.animateWithDuration(0.5) { 
            self.popupView.alpha = 1.0
        }
    }
    
    private func hidePasswordPopup() {
        UIView.animateWithDuration(0.5) {
            self.popupView.alpha = 0.0
        }
    }
    
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
        let cell = tableView.dequeueReusableCellWithIdentifier("TextCell", forIndexPath: indexPath) as! SearchEventTableViewCell
        let event = eventArray[indexPath.row]
        cell.eventLabel.text = event.hashtag
        cell.event = event
        cell.delegate = self
        if userEventArray.contains(event) || event.owner.objectId == user?.objectId {
            cell.joinButton.alpha = 0.0
            cell.checkmarkImageView.alpha = 1.0
        } else {
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
        if !selectedEvent.isPublic && !userEventArray.contains(selectedEvent) &&
        !(selectedEvent.owner.objectId == user?.objectId){
            popUpEventName.text = selectedEvent.hashtag
            selectedPrivateEvent = selectedEvent
            showPasswordPopup()
        } else {
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
    
    func joinEvent(event: Event) {
        if event.isPublic {
            addEventToUserEvents(event)
        } else {
            popUpEventName.text = event.hashtag
            selectedPrivateEvent = event
            showPasswordPopup()
        }
    }
    
}
