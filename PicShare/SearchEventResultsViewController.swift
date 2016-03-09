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

class SearchEventResultViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var resultTableView: UITableView!
    var eventName:String?
    var eventArray: [Event]?
    let textCellIdentifier = "TextCell"
    let currentDate = NSDate()
    var isPublic = false
    var eventCategory = "Private "
    var userEvent: [Event]?
    private var user: User?
    var joinedEventFlag: [Bool]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if let userEvent = userEvent {
            print("user event")
            for event in userEvent {
                print(event)
            }
        }
        queryForAllUserEvents()
        if let eventName = eventName {
            self.queryForSpecificEvents(eventName)
        }
    }
    
// MARK: - User Actions
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
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
                self?.userEvent = user.event
                print("User events query success. Number events: \(self?.userEvent?.count)")
            } else {
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
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
            if self?.eventArray?.count == 0 {
                self?.showAlert("No result", message: "Not Found! Be the owner now!")
            }
            print("Event query success. Number events: \(objects?.count)")
            self?.joinedEventFlag = self?.flagJoinedEvent(self?.eventArray, userEvent: self?.userEvent)
            self?.resultTableView.reloadData()
        }
    }
    
    private func flagJoinedEvent(eventArray: [Event]?, userEvent: [Event]?) -> [Bool] {
        var count = 0
        var joinedEventFlag = [Bool]()
        if let eventArray = eventArray {
            for _ in 1...eventArray.count {
                joinedEventFlag.append(false)
            }
            if let userEvent = userEvent {
                for event in eventArray {
                    for userEvent in userEvent {
                        if userEvent.hashtag == event.hashtag {
                            joinedEventFlag[count] = true
                        }
                    }
                    count++
                }
            }
        }
        return joinedEventFlag
    }
    
    private func calculateDays(start: NSDate, end: NSDate) -> Int {
        let calendar: NSCalendar = NSCalendar.currentCalendar()
        let date1 = calendar.startOfDayForDate(start)
        let date2 = calendar.startOfDayForDate(end)
        let flags = NSCalendarUnit.Day
        let components = calendar.components(flags, fromDate: date1, toDate: date2, options: [])
        return components.day
    }
    
// MARK: - Table Action
    
    @IBAction func join(button: UIButton) {
        if button.titleLabel?.text == "join" {
            button.setTitle("ok", forState: UIControlState.Normal)
            let row = button.tag
            if let user = self.user {
                if user.event != nil {
                    user.event!.append(eventArray![row])
                    user.saveInBackground()
                } else {
                    user.event = [Event]()
                    user.event!.append(eventArray![row])
                    user.saveInBackground()
                }
                print("join event successfully")
            }
        }
    }
    
// MARK: - Helpers
    
    private func showAlert(title: String, message: String) {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertView.addAction(okAction)
        presentViewController(alertView, animated: true, completion: nil)
    }
    
// MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        if let eventArray = eventArray {
            count = eventArray.count
        }
        return count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(textCellIdentifier, forIndexPath: indexPath) as! SearchEventTableViewCell
        let row = indexPath.row
        var dayLeft = ""
        cell.joinButton.tag = row
        if let eventArray = eventArray {
            cell.eventLabel.text = eventArray[row].hashtag
            if let joinedEventFlag = joinedEventFlag {
                if joinedEventFlag[row] == true {
                    cell.joinButton.setTitle("ok", forState: UIControlState.Normal)
                } else {
                    cell.joinButton.setTitle("join", forState: UIControlState.Normal)
                }
            }
            isPublic = eventArray[row].isPublic
            if let createdAt = eventArray[row].createdAt {
                let intervals = self.calculateDays(createdAt, end: currentDate)
                dayLeft = "⎪ \(7 - intervals) days left"
            }
            if isPublic {
                eventCategory = "Public "
            }
            cell.sublabel.text = eventCategory + "Event " + dayLeft
            if "ok" != cell.joinButton.titleLabel?.text {
                cell.joinButton.addTarget(self, action: "join:", forControlEvents: .TouchUpInside)
            }
        }
        return cell
    }
}