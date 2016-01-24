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
    
}

extension Event: PFSubclassing {
    class func parseClassName() -> String {
        return "Event"
    }
}