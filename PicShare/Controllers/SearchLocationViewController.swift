//
//  SearchLocationViewController.swift
//  PicShare
//
//  how-to
//  1. get current location
//  2. get photo array
//  3. get photos around current location
//  4. display them
//  Created by Yuan on 11/28/15.
//  Copyright © 2015 USC. All rights reserved.
//

import Foundation
import UIKit
import Parse

let photoClassName = "Photo"
let photoFileKey = "fullSizeFile"
let thumbFileKey = "thumbSizeFile"
let locationManager = CLLocationManager()
var didRequestLocation = false
var myPoint: PFGeoPoint?
var home: Bool = true
var block: Bool = false
var city: Bool = false


class SearchLocationViewController: UIViewController {
  
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var locationCollectionView: UICollectionView!
    var locationPhotoArray: [Photo]?
    var photoArray = [Photo]?()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationCollectionView.hidden = false
        //Do any additional setup after loading the view
        let status = CLLocationManager.authorizationStatus()
        if status == .Denied || status == .Restricted {
            showAlert("Location Services Disabled", message: "Please go to your device settings to enable location services.")
        } else {
            PFGeoPoint.geoPointForCurrentLocationInBackground { (geoPoint: PFGeoPoint?, error: NSError?) -> Void in
                myPoint = geoPoint
            }
        }
        queryForAllPhotos()

    }
  
    private func queryForAllPhotos() {
        let query = PFQuery(className: photoClassName)
//        let nearQuery = PFQuery(className: "PlaceObject")

        query.findObjectsInBackgroundWithBlock { [weak self](objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                self?.locationPhotoArray = objects as? [Photo]
                self?.locationCollectionView.reloadData()
                print("Photo query success. Number photos: \(objects?.count)")
            } else {
                print("Error: \(error!) \(error!.userInfo)")
            }
        }

    }

    
    // MARK: - User Actions
  
    @IBAction func backButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
  
    @IBAction func segmentSwitch(sender: UISegmentedControl) {
        print("Segment changed: \(sender.selectedSegmentIndex)")
        if segmentedControl.selectedSegmentIndex == 0 {
            toHome()
            queryForAllPhotos()
        } else if segmentedControl.selectedSegmentIndex == 1 {
            toBlock()
            queryForAllPhotos()
        } else {
            toCity()
            queryForAllPhotos()
        }
    }
    
    func showAlert(title: String, message: String) {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertView.addAction(okAction)
        presentViewController(alertView, animated: true, completion: nil)
    }
    
    func toHome() {
        home = true
        block = false
        city = false
    }
    
    func toBlock() {
        home = false
        block = true
        city = false
    }
    
    func toCity() {
        home = false
        block = false
        city = true
    }
}




// MARK: - UICollectionViewDataSource

extension SearchLocationViewController: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(locationCollectionView: UICollectionView) -> Int {
        return 1
    }
  
    func collectionView(locationCollectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let locationPhotoArray = locationPhotoArray {
            return locationPhotoArray.count
        }
        return 0
    }
    
    func collectionView(locationCollectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = locationCollectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath)
        if let  locationPhotoArray = locationPhotoArray
        {
            let photo = locationPhotoArray[indexPath.item]
            let location = photo.location
            if ((area() - distance(location!, currentLocation: myPoint!)) > 0) {
                photoArray?.append(photo)
                print("the current photo array has \(photoArray?.count)")
            }
        }

        if let imageView = cell.viewWithTag(1) as? UIImageView,
            locationPhotoArray = locationPhotoArray
        {
            let photo = locationPhotoArray[indexPath.item]
            let user = photo.owner
            let location = photo.location
            user?.fetchIfNeededInBackground()
            print("photo's location info \(location)")
            print("my current location is \(myPoint)")
            print("setted distance is \(area())")
            print(distance(location!, currentLocation: myPoint!))

            if ((area() - distance(location!, currentLocation: myPoint!)) > 0) {
                photo.thumbnail.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
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
        }
        
        return cell
    }
    
    func distance(location: PFGeoPoint, currentLocation: PFGeoPoint) -> Double {
        var distance: Double
        distance = sqrt((location.longitude - currentLocation.longitude)*(location.longitude - currentLocation.longitude)+(location.latitude - currentLocation.latitude)*(location.latitude - currentLocation.latitude))
        return distance
    }
    
    func area() -> Double {
        if(home){
            return 0.00001
        }else if (block){
            return 0.01
        }else{
            return 1000
        }
    }
}

// MARK: - UICollectionViewDelegate

extension SearchLocationViewController: UICollectionViewDelegate {
    func collectionView(locationCollectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let vc = storyboard?.instantiateViewControllerWithIdentifier("photoDetailViewController") as! PhotoDetailViewController
        if let locationPhotoArray = locationPhotoArray,
            userImageFile = locationPhotoArray[indexPath.item][photoFileKey] as? PFFile
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

// MARK: - CLLocationManagerDelegate

extension SearchLocationViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse || status == .AuthorizedAlways {
            manager.startUpdatingLocation()
            if didRequestLocation {
                // TODO: Figure out what to do
            }
        }
    }
}