//
//  EventMgmtViewController.swift
//  PicShare
//
//  Created by ZhouJiashun on 2/5/16.
//  Copyright © 2016 USC. All rights reserved.
//

import UIKit
import Parse

class EventMgmtViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var eventArray: [Event] = []
    var selectedEventIndex: Int?
    var selectedEvent: Event? {
        didSet {
            if let selectedEvent = selectedEvent, index = eventArray.indexOf(selectedEvent) {
                selectedEventIndex = index
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "EventCell")
    }
    
    override func viewWillAppear(animated: Bool) {
        let eventQuery = PFQuery(className: "Event");
        if let user = PFUser.currentUser() {
            eventQuery.whereKey("owner", equalTo: user)
            eventQuery.findObjectsInBackgroundWithBlock { [weak self](objects: [PFObject]?, error: NSError?) in
                self?.eventArray = objects as? [Event] ?? []
                self?.tableView.reloadData()
            }
        }
        else {
            print("Login required")
            return
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "ShowEventPreview" {
            let svc = segue.destinationViewController as! EventPhotoScreenViewController
            if let event = selectedEvent {
                svc.event = event
            }
        }
    }
}

extension EventMgmtViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("EventCell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.text = eventArray[indexPath.row].hashtag
        return cell
    }
}

extension EventMgmtViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        selectedEvent = eventArray[indexPath.row]
        guard let selectedEvent = selectedEvent else {
            return
        }
        
        selectedEvent.owner.fetchIfNeededInBackgroundWithBlock { (object, error) -> Void in
            if error == nil {
                self.performSegueWithIdentifier("ShowEventPreview", sender: self)
            }
        }
    }
}