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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if let eventName = eventName {
            self.queryForSpecificEvents(eventName)
        }
    }
    
// MARK: - User Actions
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
// MARK: - Event method
    
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
            self?.resultTableView.reloadData()
            if self?.eventArray?.count == 0 {
                self?.showAlert("No result", message: "Not Found! Be the owner now!")
            }
            print("Event query success. Number events: \(objects?.count)")
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
        button.setTitle("ok", forState: UIControlState.Normal)
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
        if let eventArray = eventArray {
            cell.eventLabel.text = eventArray[row].hashtag
            isPublic = eventArray[row].isPublic
            if let createdAt = eventArray[row].createdAt {
                let intervals = self.calculateDays(createdAt, end: currentDate)
                dayLeft = "⎪ \(7 - intervals) days left"
            }
            if isPublic {
                eventCategory = "Public "
            }
            cell.sublabel.text = eventCategory + "Event " + dayLeft
            cell.joinButton.tag = row
            cell.joinButton.addTarget(self, action: "join:", forControlEvents: .TouchUpInside)
        }
        return cell
    }
}