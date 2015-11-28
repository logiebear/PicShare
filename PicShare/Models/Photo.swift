//
//  Photo.swift
//  PicShare
//
//  Created by Logan Chang on 11/27/15.
//  Copyright © 2015 USC. All rights reserved.
//

import UIKit
import Parse

class Photo: PFObject {

    @NSManaged var image: PFFile
    @NSManaged var owner: PFUser
    @NSManaged var event: Event?
    @NSManaged var location: PFGeoPoint?
    @NSManaged var descriptiveText: String?
    
    override class func initialize() {
        var onceToken: dispatch_once_t = 0
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
    
    init(image: PFFile, owner: PFUser, event: Event?, location: PFGeoPoint?, descriptiveText: String?) {
        super.init()
        
        self.image = image
        self.owner = owner
        self.event = event
        self.location = location
        self.descriptiveText = descriptiveText
    }
}

extension Photo: PFSubclassing {
    class func parseClassName() -> String {
        return "Photo"
    }
}