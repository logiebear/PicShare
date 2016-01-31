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
    @NSManaged var password: String
    
    override class func initialize() {
        var onceToken: dispatch_once_t = 0
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
    
    override func isEqual(object: AnyObject?) -> Bool {
        if let object = object as? Event {
            return hashtag == object.hashtag
        } else {
            return false
        }
    }
    
}

extension Event: PFSubclassing {
    class func parseClassName() -> String {
        return "Event"
    }
}
