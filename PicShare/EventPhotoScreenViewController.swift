//
//  EventPhotoScreenViewController.swift
//  PicShare
//
//  Created by Yao Wang on 1/30/16.
//  Copyright © 2016 USC. All rights reserved.
//

import UIKit
import Parse

var photo = [PFObject]()

class EventPhotoScreenViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var eventPhotoCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Resize size of collection view items in grid so that we achieve 3 boxes across
        let cellWidth = ((UIScreen.mainScreen().bounds.width) - 32 - 30 ) / 3
        let cellLayout = eventPhotoCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        cellLayout.itemSize = CGSize(width: cellWidth, height: cellWidth)
    }
    
    func loadCollectionViewData() {
        
        // Build a parse query object
        let query = PFQuery(className:"Photo")
        
        
        // Fetch data from the parse platform
        let event : Event = Event()
        query.whereKey("event", equalTo: event)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            // The find succeeded now rocess the found objects into the photo array
            if error == nil {
                
                // Clear existing photo data
                photo.removeAll(keepCapacity: true)
                
                // Add photo objects to our array
                if let objects = objects {
                    photo = Array(objects.generate())
                }
                
                // reload our data into the collection view
                self.eventPhotoCollectionView.reloadData()
                
            } else {
                // Log details of the failure
                print("Error: \(error!)")
            }
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photo.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! EventPhotoCollectionViewCell
        
        // Fetch event photo image
        let finalImage = photo[indexPath.row]["image"] as? PFFile
        finalImage!.getDataInBackgroundWithBlock {
            (imageData: NSData?, error: NSError?) -> Void in
            if error == nil {
                if let imageData = imageData {
                    cell.cellImage.image = UIImage(data:imageData)
                }
            }
        }

        return cell
    }
    
    override func viewDidAppear(animated: Bool) {
        loadCollectionViewData()
    }
    
}
