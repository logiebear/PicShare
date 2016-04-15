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
    
    init(owner: PFUser, hashtag: String, isPublic: Bool, password: String?) {
        super.init()
        self.owner = owner
        self.hashtag = hashtag
        self.isPublic = isPublic
        self.password = password
    }
    
    override func isEqual(object: AnyObject?) -> Bool {
        if let object = object as? Event {
            return hashtag == object.hashtag
        } else {
            return false
        }
    }
    
    class func queryEventsWithSubstring(event: String) -> PFQuery? {
        let query = PFQuery(className: Event.parseClassName())
        query.whereKey("hashtag", matchesRegex: event, modifiers: "i")
        query.orderByDescending("createdAt")
        return query
    }
    
    override init() {
        super.init()
    }
    
}

extension Event: PFSubclassing {
    class func parseClassName() -> String {
        return "Event"
    }
}
