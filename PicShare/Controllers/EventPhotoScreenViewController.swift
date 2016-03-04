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
    var eventPhotos: [Photo]?
    var event: Event?
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
            if let objects = objects as? [Photo] {
                self?.eventPhotos = objects
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
        let vc = storyboard?.instantiateViewControllerWithIdentifier("photoDetailViewController") as! PhotoDetailViewController
        if let eventPhotos = eventPhotos {
            let photo = eventPhotos[indexPath.item]
            vc.file = photo.image
            presentViewController(vc, animated: true, completion: nil)
        }
    }
}