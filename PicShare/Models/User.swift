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
    
    @NSManaged var profilePhoto: Photo?
    
    override class func initialize() {
        var onceToken: dispatch_once_t = 0
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
    
    init( email: String, username: String, password: String, profilePhoto: Photo?) {
        super.init()
        
        self.email = email
        self.username = username
        self.password = password
        self.profilePhoto = profilePhoto
    }
}
