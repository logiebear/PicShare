//
//  Photo.swift
//  PicShare
//
//  Created by Logan Chang on 11/27/15.
//  Copyright © 2015 USC. All rights reserved.
//

import UIKit
import Parse

/// Photo uploaded by user
class Photo: PFObject {

    @NSManaged var image: PFFile
    @NSManaged var thumbnail: PFFile
    @NSManaged var owner: PFUser?
    @NSManaged var event: Event?
    @NSManaged var location: PFGeoPoint?
    @NSManaged var descriptiveText: String?
    
    override class func initialize() {
        var onceToken: dispatch_once_t = 0
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
    
    /**
         Initializes a Photo parse object.
         
         - Parameters:
             - image: full sized image
             - thumbnail: scaled down size image
             - owner: owner of the photo
             - event: event that the photo is in
             - location: geopoint of the photo
             - descriptiveText: comment on the photo
         
         - Returns: Photo
     */
    init(image: PFFile, thumbnail: PFFile, owner: PFUser,
         event: Event? = nil, location: PFGeoPoint? = nil, descriptiveText: String?) {
        super.init()
        
        self.image = image
        self.thumbnail = thumbnail
        self.owner = owner
        self.event = event
        self.location = location
        self.descriptiveText = descriptiveText
    }
    
    override init() {
        super.init()
    }
    
    /**
        Query for all photos
     
     */
    override class func query() -> PFQuery? {
        let query = PFQuery(className: Photo.parseClassName())
        query.includeKey("owner")
        query.orderByDescending("createdAt")
        return query
    }
    
    /**
        Query for all photos owned by current user
     
     */
    class func allPhotosForCurrentUserQuery() -> PFQuery? {
        guard let currentUser = PFUser.currentUser() else {
            return nil
        }
        let query = PFQuery(className: Photo.parseClassName())
        query.whereKey("owner", equalTo: currentUser)
        query.includeKey("owner")
        query.orderByDescending("createdAt")
        return query
    }
    
    /**
        Query for all near a specific geopoint
        
        -Parameters:
            -currentLocation: location of user
            -radiusInMiles: radius of search around location

     */
    class func queryNearbyPhotosWithRadius(currentLocation: PFGeoPoint, radiusInMiles: Double) -> PFQuery? {
        if radiusInMiles < 1 {
            return nil
        }
        let query = PFQuery(className: Photo.parseClassName())
        query.whereKey("location", nearGeoPoint: currentLocation, withinMiles: radiusInMiles)
        query.includeKey("owner")
        query.orderByDescending("createdAt")
        return query
    }

}

extension Photo: PFSubclassing {
    
    class func parseClassName() -> String {
        return "Photo"
    }
    
}