//
//  Event.swift
//  PicShare
//
//  Created by Logan Chang on 11/27/15.
//  Copyright © 2015 USC. All rights reserved.
//

import UIKit
import Parse

class Event: PFObject {
    
    @NSManaged var owner: PFUser
    @NSManaged var hashtag: String
    @NSManaged var isPublic: Bool
    @NSManaged var password: String?
    
    override class func initialize() {
        var onceToken: dispatch_once_t = 0
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
    
    /**
         Initializes a new Event parse object
         
         - Parameters:
             - owner: owner of the event
             - hashtag: name of the event
             - isPublic: bool to determine whether even is public or private
             - password: password of event if private
         
         - Returns: Event
     */
    init(owner: PFUser, hashtag: String, isPublic: Bool, password: String?) {
        super.init()
        self.owner = owner
        self.hashtag = hashtag
        self.isPublic = isPublic
        self.password = password
    }
    
    override init() {
        super.init()
    }
    
    /**
         Check if another event is equal to this object
     
         - Parameters:
             - object: any object
     */
    override func isEqual(object: AnyObject?) -> Bool {
        if let object = object as? Event {
            return hashtag == object.hashtag
        } else {
            return false
        }
    }
    
    /**
         Query for searching for event with substring
     
         - Parameters:
             - event: event search string
     */
    class func queryEventsWithSubstring(event: String) -> PFQuery? {
        let query = PFQuery(className: Event.parseClassName())
        query.whereKey("hashtag", matchesRegex: event, modifiers: "i")
        query.orderByDescending("createdAt")
        return query
    }
    
}

extension Event: PFSubclassing {
    
    class func parseClassName() -> String {
        return "Event"
    }
    
}
