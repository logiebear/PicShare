//
//  SearchLocationViewController.swift
//  PicShare
//
//  Created by Yuan on 11/28/15.
//  Copyright © 2015 USC. All rights reserved.
//

import Foundation
import UIKit
import Parse

let photoClassName = "Photo"
let photoFileKey = "fullSizeFile"
let thumbFileKey = "thumbSizeFile"

class SearchLocationViewController: UIViewController {
  
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var locationCollectionView: UICollectionView!
    var locationPhotoArray: [PFObject]?
    //var myPoint: PFGeoPoint?
    let point = PFGeoPoint(latitude:40.0, longitude:-30.0)
  
    override func viewDidLoad() {
        super.viewDidLoad()
        locationCollectionView.hidden = false
        //Do any additional setup after loading the view
//        queryForAllPhotos()
        //get user's current location
//        PFGeoPoint.geoPointForCurrentLocationInBackground {
//            (geoPoint: PFGeoPoint?, error:NSError?) -> Void in
//            if error == nil {
//                //do something with the new geoPoint
//                self.myPoint = geoPoint
//            }
//        }
    }
  
    private func queryForAllPhotos() {
        // User's location
        //let userGeoPoint = point                                  //myPoint
    
        let query = PFQuery(className: photoClassName)
        let nearQuery = PFQuery(className: "PlaceObject")

//        query.findObjectsInBackgroundWithBlock { [weak self](objects: [PFObject]?, error: NSError?) -> Void in
//            if error == nil {
//                self?.locationPhotoArray = objects
//                self?.locationPhotoArray![0]["location"] = self!.point
//                self?.locationPhotoArray![1]["location"] = self!.point
//                //self?.locationCollectionView.reloadData()
//                print("Photo query success. Number photos: \(objects?.count)")
//            } else {
//                print("Error: \(error!) \(error!.userInfo)")
//            }
//            
//        }

        do {
            try locationPhotoArray = query.findObjects()
            print("Photo query success. Number photos: \(locationPhotoArray?.count)")
        } catch let error as NSError {
            print("Error: \(error)")
        }
    
        locationPhotoArray![0]["location"] = point
        locationPhotoArray![1]["location"] = point
    
        let userGeoPoint = locationPhotoArray![0]["location"] as! PFGeoPoint

        // Interested in locations near user.
        nearQuery.whereKey("location", nearGeoPoint:userGeoPoint) //"!" for myPoint
        // Limit what could be a lot of points.
        nearQuery.limit = 1
        // Final list of objects
        do {
            try locationPhotoArray = nearQuery.findObjects()
            print("Location Photo query success. Number photos: \(locationPhotoArray?.count)")
            print("User try to find near photos")
        } catch let error as NSError {
            print("Error: \(error)")
        }
        locationCollectionView.reloadData()
    }
    
    // MARK: - User Actions
  
    @IBAction func backButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
  
    @IBAction func segmentSwitch(sender: AnyObject) {
        if segmentedControl.selectedSegmentIndex == 0 {
            locationCollectionView.hidden = false
        } else if segmentedControl.selectedSegmentIndex == 1 {
            locationCollectionView.hidden = true
        } else {
            locationCollectionView.hidden = true
        }
    }
}

// MARK: - UICollectionViewDataSource

extension SearchLocationViewController: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(locationCollectionView: UICollectionView) -> Int {
        return 1
    }
  
    func collectionView(locationCollectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let photoArray = locationPhotoArray {
            return photoArray.count
        }
        return 0
    }
    
    func collectionView(locationCollectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = locationCollectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath)
        if let imageView = cell.viewWithTag(1) as? UIImageView,
            photoArray = locationPhotoArray,
            userImageFile = photoArray[indexPath.item][thumbFileKey] as? PFFile
        {
            userImageFile.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
                if error == nil {
                    if let imageData = imageData, image = UIImage(data: imageData) {
                        imageView.contentMode = .ScaleAspectFit
                        imageView.image = image
                    }
                } else {
                    print("Error: \(error!) \(error!.userInfo)")
                }
            }
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension SearchLocationViewController: UICollectionViewDelegate {
    func collectionView(locationCollectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let vc = storyboard?.instantiateViewControllerWithIdentifier("photoDetailViewController") as! PhotoDetailViewController
        if let photoArray = locationPhotoArray,
            userImageFile = photoArray[indexPath.item][photoFileKey] as? PFFile
        {
            userImageFile.getDataInBackgroundWithBlock { [weak self](imageData: NSData?, error: NSError?) -> Void in
                if error == nil {
                    if let imageData = imageData, image = UIImage(data: imageData) {
                        vc.image = image
                    }
                    self?.presentViewController(vc, animated: true, completion: nil)
                } else {
                    print("Error: \(error!) \(error!.userInfo)")
                }
            }
        }
    }
}

// MARK: - UIImagePickerControllerDelegate

extension SearchLocationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        print("Photo selected")
        if let fullImage = image.scaleAndRotateImage(960),
            thumbImage = image.scaleAndRotateImage(480),
            fullImageData = UIImagePNGRepresentation(fullImage),
            thumbImageData = UIImagePNGRepresentation(thumbImage)
        {
            let userPhoto = PFObject(className: photoClassName)
            userPhoto[photoFileKey] = PFFile(name: "original.png", data: fullImageData)
            userPhoto[thumbFileKey] = PFFile(name: "thumbnail.png", data: thumbImageData)
            userPhoto.saveEventually()
        } else {
            print("Photo saving error")
        }
        dismissViewControllerAnimated(true) { [weak self]() -> Void in
            self?.queryForAllPhotos()
        }
    }
  
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}