//
//  User.swift
//  PicShare
//
//  Created by Yao Wang on 1/26/16.
//  Copyright © 2016 USC. All rights reserved.
//

import UIKit
import Parse

class User: PFUser {
    
    @NSManaged var profilePhoto: PFFile?
    @NSManaged var events: [Event]?
    
    override class func initialize() {
        var onceToken: dispatch_once_t = 0
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
    
    /**
     Initializes a new custom User subclass of PFUser
     
     - Parameters:
        - email: email of user
        - username: username of user
        - password: password for user
        - profilePhoto: photo uploaded by user
        - events: events of user
     
        - Returns: User
     */
    init(email: String, username: String, password: String, profilePhoto: PFFile?, events: [Event]?) {
        super.init()
        
        self.email = email
        self.username = username
        self.password = password
        self.profilePhoto = profilePhoto
        self.events = events
    }
    
    override init() {
        super.init()
    }
    
    /**
        Query for all events of current user
     
     */
    class func allEventsForCurrentUserQuery() -> PFQuery? {
        guard let currentUser = PFUser.currentUser(),
            username = currentUser.username
        else {
            return nil
        }
        let query = PFUser.query()
        query?.whereKey("username", equalTo: username)
        query?.includeKey("events")
        return query
    }

}