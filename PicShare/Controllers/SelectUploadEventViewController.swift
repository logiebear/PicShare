//
//  SelectUploadEventViewController.swift
//  PicShare
//
//  Created by Yao Wang on 2/20/16.
//  Copyright © 2016 USC. All rights reserved.
//

import UIKit
import Parse

class SelectUploadEventViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var eventArray: [Event] = []
    var photo: Photo?
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
        let eventQuery = PFQuery(className: "Event");
        eventQuery.findObjectsInBackgroundWithBlock { [weak self](objects: [PFObject]?, error: NSError?) in
            self?.eventArray = objects as? [Event] ?? []
            self?.tableView.reloadData()
        }
    }
    
    //MARK: - User Actions
    @IBAction func backButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func uploadPhoto(sender: AnyObject) {
        guard let selectedEvent = selectedEvent else {
            let alertView = UIAlertController(title: "Error",
                message: "Please select an event!", preferredStyle: .Alert)
            let OKAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertView.addAction(OKAction)
            presentViewController(alertView, animated: true, completion: nil)
            return
        }
        guard let photo = photo else {
            return
        }
        photo.event = selectedEvent
        photo.saveInBackgroundWithBlock { [weak self](success: Bool, error: NSError?) in
            if let error = error {
                let alertView = UIAlertController(title: "Error",
                    message: error.localizedDescription, preferredStyle: .Alert)
                let OKAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alertView.addAction(OKAction)
                self?.presentViewController(alertView, animated: true, completion: nil)
                return
            }
            let alertView = UIAlertController(title: "Message",
                message: "Upload Success", preferredStyle: .Alert)
            let OKAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertView.addAction(OKAction)
            self?.presentViewController(alertView, animated: true, completion: nil)
        }
    }
}

extension SelectUploadEventViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("EventCell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.text = eventArray[indexPath.row].hashtag
        if indexPath.row == selectedEventIndex {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        return cell
    }
}

extension SelectUploadEventViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        //Other row is selected - need to deselect it
        if let index = selectedEventIndex {
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0))
            cell?.accessoryType = .None
        }
        selectedEvent = eventArray[indexPath.row]
        //update the checkmark for the current row and upload photo
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.accessoryType = .Checkmark
    }
}