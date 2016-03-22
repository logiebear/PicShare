//
//  EventPhotoScreenViewController.swift
//  PicShare
//
//  Created by Yao Wang on 1/30/16.
//  Copyright © 2016 USC. All rights reserved.
//

import UIKit
import Parse

class EventPhotoScreenViewController: UIViewController {
    
    @IBOutlet weak var eventPhotoCollectionView: UICollectionView!
    @IBOutlet weak var editEventBtn: UIButton!
    var photoIDArray = [String]()
    var eventPhotos: [Photo]?
    var event: Event?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        editEventBtn.setTitle("Edit", forState: .Normal)
        editEventBtn.setTitle("Done", forState: .Selected)
        //Check whether current user owns this event
        if let currentUser = PFUser.currentUser(), event = event {
            editEventBtn.hidden = event.owner.username != currentUser.username
        }
        // Resize size of collection view items in grid so that we achieve 3 boxes across
        let cellWidth = ((UIScreen.mainScreen().bounds.width) - 32 - 30 ) / 3
        let cellLayout = eventPhotoCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        cellLayout.itemSize = CGSize(width: cellWidth, height: cellWidth)
        loadCollectionViewData()
    }
    
    // MARK: - User Actions
    @IBAction func backButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func editEvent(sender: AnyObject) {
        editEventBtn.selected = !editEventBtn.selected
    }
    
    func loadCollectionViewData() {
        let query = PFQuery(className:"Photo")
        guard let event = event else {
            return
        }
        query.whereKey("event", equalTo: event)
        query.findObjectsInBackgroundWithBlock { [weak self](objects: [PFObject]?, error: NSError?) -> Void in
            if let error = error {
                print("Error: \(error)")
                return
            }
            self?.eventPhotos?.removeAll(keepCapacity: true)
            self?.photoIDArray.removeAll(keepCapacity: true)
            if let objects = objects {
                self?.eventPhotos = objects as? [Photo]
                for object in objects {
                    if let objectID = object.objectId {
                        self?.photoIDArray.append(objectID)
                    }
                }
            }
            self?.eventPhotoCollectionView.reloadData()
        }
    }
}

extension EventPhotoScreenViewController: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let eventPhotos = self.eventPhotos {
            return eventPhotos.count
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! EventPhotoCollectionViewCell
        // Fetch event photo image
        if let eventPhotos = self.eventPhotos {
            let finalImage = eventPhotos[indexPath.row]["image"] as? PFFile
            if let finalImage = finalImage {
                finalImage.getDataInBackgroundWithBlock {
                    (imageData: NSData?, error: NSError?) -> Void in
                    if let error = error {
                        print("Error: \(error)")
                        return
                    }
                    if let imageData = imageData {
                        cell.cellImage.image = UIImage(data:imageData)
                    }
                }
            }
        }
        return cell
    }
}

extension EventPhotoScreenViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if !editEventBtn.selected {
            let vc = storyboard?.instantiateViewControllerWithIdentifier("photoDetailViewController") as! PhotoDetailViewController
            if let eventPhotos = eventPhotos {
                let photo = eventPhotos[indexPath.item]
                vc.photo = photo
                presentViewController(vc, animated: true, completion: nil)
            }
        }
        else {
            let alertView = UIAlertController(title: "Delete Photo",
                message: "Are you sure to delete this photo?", preferredStyle: .Alert)
            let OKAction = UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction) in
                let query = PFQuery(className: "Photo")
                query.getObjectInBackgroundWithId(self.photoIDArray[indexPath.item]) { (object, error) -> Void in
                    if let error = error {
                        print("Error: \(error)")
                        return
                    }
                    if let object = object {
                        object.deleteInBackground()
                        self.eventPhotos?.removeAtIndex(indexPath.item)
                        self.eventPhotoCollectionView.reloadData()
                    }
                }
            })
            alertView.addAction(OKAction)
            alertView.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
            self.presentViewController(alertView, animated: true, completion: nil)
        }
    }
}