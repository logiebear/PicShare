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

    // MARK: - Properties
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var popupView: UIView!
    
    var eventArray: [Event] = []
    var photo: Photo?
    var image: UIImage?
    var selectedEventIndex: Int?
    var selectedEvent: Event? {
        didSet {
            // Post setter functionality to set the selectedEventIndex after setting the event
            if let selectedEvent = selectedEvent, index = eventArray.indexOf(selectedEvent) {
                selectedEventIndex = index
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Brings popupview to front
        view.bringSubviewToFront(popupView)
        popupView.alpha = 0.0
        
        let eventQuery = PFQuery(className: "Event");
        let userEventQuery = User.allEventsForCurrentUserQuery()
        if let user = User.currentUser() {
            eventQuery.whereKey("owner", equalTo: user)
            // Fetches all events owned by user
            eventQuery.findObjectsInBackgroundWithBlock { [weak self](objects: [PFObject]?, error: NSError?) in
                let ownedEvents = objects as? [Event] ?? []
                self?.eventArray = ownedEvents
                // Fetches all events joined by user

                userEventQuery?.getFirstObjectInBackgroundWithBlock{ (object, error) -> Void in
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
        else {
            print("Login required")
            return
        }
    }
    
    // MARK: - User Actions
    @IBAction func backButtonPressed(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func uploadPhoto(sender: AnyObject) {
        guard let selectedEvent = selectedEvent else {
            showAlert("Error", message: "Please select an event!")
            return
        }
        guard let photo = photo else {
            showAlert("Error", message: "There was an error uploading your photo. Please try again.")
            print("Image upload error")
            return
        }
        
        showProgressIndicatorPopup()
        photo.event = selectedEvent
        // Upload main image
        photo.image.saveInBackgroundWithBlock({ [weak self](success, error) -> Void in
            if !success {
                self?.showAlert("Error", message: "There was an error uploading your photo. Please try again.")
                self?.hideProgressIndicatorPopup()
                print("Image upload error: \(error)")
                return
            }            
            // Upload thumbnail image
            photo.thumbnail.saveInBackgroundWithBlock({ [weak self](success, error) -> Void in
                if !success {
                    self?.showAlert("Error", message: "There was an error uploading your photo. Please try again.")
                    print("Image upload error: \(error)")
                    self?.hideProgressIndicatorPopup()
                    return
                }
                self?.proceedToUploadPhoto(photo)
            },
            progressBlock: { (progress) -> Void in
                print("thumbnail progress: \(progress)%")
                self?.progressView?.setProgress(Float(progress) / 200.0 + 0.5, animated: true)
                self?.progressLabel?.text = "Uploading photo... \(progress / 2 + 50) %"
            })
        },
        progressBlock: { (progress) -> Void in
            print("image progress: \(progress)%")
            self.progressView?.setProgress(Float(progress) / 200.0, animated: true)
            self.progressLabel?.text = "Uploading photo... \(progress / 2) %"
        })
    }
    
    // MARK: Helpers
    /**
        Uploads the photo object to the server
        
        -Parameters
            -photo: photo to be uploaded
     */
    func proceedToUploadPhoto(photo: Photo) {
        photo.saveInBackgroundWithBlock { [weak self](success, error) -> Void in
            self?.hideProgressIndicatorPopup()
            
            if !success {
                self?.showAlert("Error", message: "There was an error uploading your photo. Please try again.")
                print("Image upload error: \(error)")
                return
            }
            
            self?.showAlert("Upload Success", message: "You have successfully uploaded your photo.") {
                // Look for camera VC and pop to correct one
                if let viewControllers = self?.navigationController?.viewControllers {
                    for viewController in viewControllers {
                        if viewController is PhotoHomeViewController {
                            self?.navigationController?.popToViewController(viewController, animated: true)
                            return
                        }
                    }
                }
                self?.navigationController?.popToRootViewControllerAnimated(true)
            }
        }
    }
    
    // MARK: Private
    
    private func showProgressIndicatorPopup() {
        // Animates progress indicator to visible
        progressView.progress = 0.0
        UIView.animateWithDuration(0.5) {
            self.popupView.alpha = 1.0
        }
    }
    
    private func hideProgressIndicatorPopup() {
        // Animates progress indicator to hidden
        UIView.animateWithDuration(0.5) {
            self.popupView.alpha = 0.0
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

extension SelectUploadEventViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("EventCell", forIndexPath: indexPath) as! SearchEventTableViewCell
        let event = eventArray[indexPath.row]
        cell.eventLabel.text = event.hashtag
        cell.event = event
        
        var dayLeft = ""
        if let createdAt = event.createdAt {
            let intervals = self.calculateDays(createdAt, end: NSDate())
            dayLeft = "⎪ \(7 - intervals) days left"
        }
        let eventCategory = event.isPublic ? "Public" : "Private"
        cell.sublabel.text = eventCategory + " Event " + dayLeft
        
        if indexPath.row == selectedEventIndex {
            cell.checkmarkImageView.hidden = false
        } else {
            cell.checkmarkImageView.hidden = true
        }
        return cell
    }
    
}

// MARK: - UITableViewDelegate

extension SelectUploadEventViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        // Other row is selected - need to deselect it
        if let index = selectedEventIndex {
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) as! SearchEventTableViewCell
            cell.checkmarkImageView.hidden = true
        }
        selectedEvent = eventArray[indexPath.row]
        // Update the checkmark for the current row
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! SearchEventTableViewCell
        cell.checkmarkImageView.hidden = false
    }
    
}