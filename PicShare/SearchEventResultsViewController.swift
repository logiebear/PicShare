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
    var toPass:String!
    var eventArray: [Event]?
    let textCellIdentifier = "TextCell"
    let currentDate = NSDate()
    var isPublic: Bool = false
    var eventCate = "Private "
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.queryForSpecificEvents(toPass)
        resultTableView.delegate = self
        resultTableView.dataSource = self
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
                print("Error: \(error) \(error.userInfo)")
                return
            }
            
            self?.eventArray = objects as? [Event]
            self?.resultTableView.reloadData()
            print("Event query success. Number events: \(objects?.count)")
        }
    }
    
    private func calculateDays(start: NSDate, end: NSDate) -> Int {
        let calendar: NSCalendar = NSCalendar.currentCalendar()
        
        // Replace the hour (time) of both dates with 00:00
        let date1 = calendar.startOfDayForDate(start)
        let date2 = calendar.startOfDayForDate(end)
        
        let flags = NSCalendarUnit.Day
        let components = calendar.components(flags, fromDate: date1, toDate: date2, options: [])
        
//        components.day  // This will return the number of day(s) between dates
        return components.day
    }
    
// MARK: - Table Action
    
    @IBAction func join(button: UIButton) {

        button.setTitle("ok", forState: UIControlState.Normal)

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
//        return swiftBlogs.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(textCellIdentifier, forIndexPath: indexPath) as! SearchEventTableViewCell
        let row = indexPath.row
        if let eventArray = eventArray {
            cell.eventLabel.text = eventArray[row].hashtag as? String
            isPublic = eventArray[row].isPublic
            let intervals = self.calculateDays(eventArray[row].createdAt!, end: currentDate)
            if(isPublic) {
                eventCate = "Public "
            }
            cell.sublabel.text = eventCate + "Event | \(7 - intervals) days left"
            cell.joinButton.tag = row
            cell.joinButton.addTarget(self, action: "join:", forControlEvents: .TouchUpInside)
        }
        
        return cell
    }
    
    
// MARK: - UITableViewDelegate
    

    

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        self.queryForSpecificEvents(toPass)
    }
    
}