//
//  EventHomeViewController.swift
//  PicShare
//
//  Created by ZhouJiashun on 2/5/16.
//  Copyright © 2016 USC. All rights reserved.
//

import UIKit
import Parse

class EventHomeViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var eventArray = [Event]()
    var syncInProgress = false
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        reloadEventList()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EventScreen" {
            let svc = segue.destinationViewController as! EventPhotoScreenViewController
            if let event = sender as? Event {
                svc.event = event
            }
        }
    }
    
    // MARK: Helpers
    /** 
        Reloads current event list
     
     */
    private func reloadEventList() {
        if syncInProgress {
            return
        }
        syncInProgress = true
        tableView.userInteractionEnabled = false
        
        let eventQuery = PFQuery(className: "Event");
        let userEventQuery = User.allEventsForCurrentUserQuery()
        guard let user = User.currentUser() else {
            print("Login required")
            syncInProgress = false
            tableView.userInteractionEnabled = true
            return
        }
        
        eventQuery.whereKey("owner", equalTo: user)
        eventQuery.orderByDescending("createdAt")
        // Fetches all events owned by user
        eventQuery.findObjectsInBackgroundWithBlock { [weak self](objects: [PFObject]?, error: NSError?) in
            let ownedEvents = objects as? [Event] ?? []
            self?.eventArray = ownedEvents
            // Fetches all events joined by user
            userEventQuery?.getFirstObjectInBackgroundWithBlock{ (object, error) -> Void in
                self?.syncInProgress = false
                if let user = object as? User {
                    let joinedEvents = user.events ?? []
                    // Combine the two event arrays
                    self?.eventArray.appendContentsOf(joinedEvents)
                }
                
                // Filter out expired events
                let sevenDays: NSTimeInterval = -7 * 60 * 60 * 24
                let sevenDaysAgoDate = NSDate().dateByAddingTimeInterval(sevenDays)
                var filteredEventArray = [Event]()
                if let eventArray = self?.eventArray {
                    for event in eventArray {
                        if let createdAt = event.createdAt where sevenDaysAgoDate.compare(createdAt) == NSComparisonResult.OrderedDescending {
                            continue
                        }
                        filteredEventArray.append(event)
                    }
                }
                self?.eventArray = filteredEventArray
                self?.tableView.reloadData()
                self?.tableView.userInteractionEnabled = true
            }
        }
    }
    
    /**
        Computes the number of days between two dates
     
        -Parameters
            -start: startDate
            -end: endDate
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

extension EventHomeViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("EventCell", forIndexPath: indexPath) as! SearchEventTableViewCell
        if indexPath.row >= eventArray.count {
            return cell
        }
        let event = eventArray[indexPath.row]
        cell.eventLabel.text = event.hashtag
        var dayLeft = ""
        if let createdAt = event.createdAt {
            let intervals = self.calculateDays(createdAt, end: NSDate())
            dayLeft = "⎪ \(7 - intervals) days left"
        }
        
        let eventCategory = event.isPublic ? "Public" : "Private"
        cell.sublabel.text = eventCategory + " Event " + dayLeft
        cell.event = event
        return cell
    }
    
}

// MARK: - UITableViewDelegate

extension EventHomeViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let event = eventArray[indexPath.row]
        
        event.owner.fetchIfNeededInBackgroundWithBlock { (object, error) -> Void in
            if error == nil {
                // Selecting the event enters the event preview
                self.performSegueWithIdentifier("EventScreen", sender: event)
            }
        }
    }
    
}