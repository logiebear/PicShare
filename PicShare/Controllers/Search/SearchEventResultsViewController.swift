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

class SearchEventResultsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var resultTableView: UITableView!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var popUpEventName: UILabel!
    @IBOutlet weak var quitEnterPasswordButton: UIButton!
    let checkIcon = UIImage(named: "greenCheckmark")
    let textCellIdentifier = "TextCell"
    let currentDate = NSDate()
    private var user: User?
    var eventName:String?
    var eventArray: [Event]?
    var isPublic = false
    var eventCategory = "Private "
    var userEventArray: [Event]?
    var row = 0
    var joinedEventFlag: [Bool]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.popUpView.hidden = true
        self.popUpView.layer.shadowOpacity = 0.8
        self.popUpView.layer.shadowOffset = CGSizeMake(0.0, 0.0)
        queryForAllUserEvents()
    }
    
    // MARK: - User Actions
    
    @IBAction func closePopup(sender: AnyObject) {
        popUpView.hidden = true
    }
    
    @IBAction func enterPrivateEvent(sender: AnyObject) {
        guard let eventArray = eventArray else {
            return
        }
        
        if password.text == eventArray[row].password {
            userEventArray?.append(eventArray[row])
            if let user = user {
                if user.events != nil {
                    user.events!.append(eventArray[row])
                    user.saveInBackground()
                } else {
                    user.events = [Event]()
                    user.events!.append(eventArray[row])
                    user.saveInBackground()
                }
                print("join event successfully")
                popUpView.hidden = true
                queryForAllUserEvents()
            }
        } else {
            print(eventArray[row].password)
            showAlert("Wrong Password", message: "Incorrect password")
        }
        password.text = nil
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
                self?.userEventArray = user.events
                print("User events query success. Number events: \(self?.userEventArray?.count)")
            } else {
                print("Error: \(error!) \(error!.userInfo)")
            }
            self?.resultTableView.reloadData()
        }
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
        row = button.tag
        guard let eventArray = eventArray else {
            return
        }
        
        if eventArray[row].isPublic == false {
            popUpEventName.text = eventArray[row].hashtag
            self.popUpView.hidden = false
        } else{
            button.setTitle("", forState: UIControlState.Normal)
            button.frame = CGRectMake(1, 1, 43, 34)
            button.setImage(checkIcon, forState: .Normal)
            if let user = self.user {
                if user.events != nil {
                    user.events!.append(eventArray[row])
                    user.saveInBackground()
                } else {
                    user.events = [Event]()
                    user.events!.append(eventArray[row])
                    user.saveInBackground()
                }
                print("join event successfully")
            }
        }
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
            if let userEventArray = userEventArray {
                if userEventArray.contains(eventArray[row]) {
                    cell.joinButton.setTitle("", forState: UIControlState.Normal)
                    cell.joinButton.frame = CGRectMake(1, 1, 43, 34)
                    cell.joinButton.setImage(checkIcon, forState: .Normal)
                } else {
                    cell.joinButton.setImage(nil, forState: .Normal)
                    cell.joinButton.setTitle("JOIN", forState: UIControlState.Normal)
                }
                if eventArray[row].owner.objectId == self.user?.objectId {
                    cell.joinButton.setTitle("", forState: UIControlState.Normal)
                    cell.joinButton.frame = CGRectMake(1, 1, 43, 34)
                    cell.joinButton.setImage(checkIcon, forState: .Normal)
                } else {
                    cell.joinButton.setImage(nil, forState: .Normal)
                    cell.joinButton.setTitle("JOIN", forState: UIControlState.Normal)
                }
            }
            isPublic = eventArray[row].isPublic
            if let createdAt = eventArray[row].createdAt {
                let intervals = self.calculateDays(createdAt, end: currentDate)
                dayLeft = "⎪ \(7 - intervals) days left"
            }
            if isPublic {
                eventCategory = "Public "
            } else {
                eventCategory = "Private "
            }
            cell.sublabel.text = eventCategory + "Event " + dayLeft
            if "JOIN" == cell.joinButton.titleLabel?.text {
                cell.joinButton.addTarget(self, action: "join:", forControlEvents: .TouchUpInside)
            }
        }
        return cell
    }
}