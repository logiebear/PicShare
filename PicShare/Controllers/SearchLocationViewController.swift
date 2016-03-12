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
import ParseUI

class SearchLocationViewController: UIViewController {
  
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var radiusLabel: UILabel!
    @IBOutlet weak var radiusSlider: UISlider!
    @IBOutlet weak var filterHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var nearbyView: UIView!
    
    let locationManager = CLLocationManager()
    var photoArray: [Photo]?
    var didRequestLocation = false
    var formerRadius = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view

        let sliderKnobImage = UIImage(named: "sliderKnob")
        radiusSlider.setThumbImage(sliderKnobImage, forState: .Normal)
        let filterIconImage = UIImage(named: "filterIcon")
        filterButton.setImage(filterIconImage, forState: .Normal)
        filterButton.setTitle(" Filter", forState: .Normal)
        let checkmarkImage = UIImage(named: "checkmark")
        filterButton.setImage(checkmarkImage, forState: .Selected)
        filterButton.setTitle("", forState: .Selected)
        filterView.alpha = 0.0
        closeButton.alpha = 0.0
        
        updateCurrentLocation()
    }
    
    // MARK: - User Actions
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func filterButtonPressed(sender: AnyObject) {
        filterButton.selected = !filterButton.selected
        UIView.animateWithDuration(0.5) { [weak self]() -> Void in
            if let filterButton = self?.filterButton {
                let alpha: CGFloat = filterButton.selected ? 1.0 : 0.0
                self?.filterView.alpha = alpha
                self?.closeButton.alpha = alpha
                self?.nearbyView.alpha = (1 - alpha)
            }
        }
        
        if !filterButton.selected {
            updateCurrentLocation()
        }
        else{
            formerRadius = Int(radiusSlider.value)
        }
    }
    
    @IBAction func closeButtonPressed(sender: AnyObject) {
        filterButton.selected = !filterButton.selected
        UIView.animateWithDuration(0.5) { [weak self]() -> Void in
            if let filterButton = self?.filterButton {
                let alpha: CGFloat = filterButton.selected ? 1.0 : 0.0
                self?.filterView.alpha = alpha
                self?.closeButton.alpha = alpha
                self?.nearbyView.alpha = (1 - alpha)
            }
        }
        radiusSlider.value = Float(formerRadius)
        let radius = Int(radiusSlider.value)
        radiusLabel.text = "\(radius) Miles"
    }
    
    @IBAction func radiusSliderValueChanged(sender: AnyObject) {
        let radius = Int(radiusSlider.value)
        radiusLabel.text = "\(radius) Miles"
    }

    // MARK: - Location Methods
    
    private func updateCurrentLocation() {
        let status = CLLocationManager.authorizationStatus()
        if status == .Denied || status == .Restricted {
            showAlert("Location Services Disabled", message: "Please go to your device settings to enable location services.")
        } else if status == .NotDetermined {
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
            didRequestLocation = true
        } else {
            PFGeoPoint.geoPointForCurrentLocationInBackground { [weak self](geoPoint: PFGeoPoint?, error: NSError?) -> Void in
                if let geoPoint = geoPoint {
                    self?.queryForNearbyPhotos(location: geoPoint)
                }
            }
        }
    }
    
    private func queryForNearbyPhotos(location location: PFGeoPoint) {
        guard let query = Photo.queryNearbyPhotosWithRadius(location, radiusInMiles: 1.0) else {
            return
        }
        
        query.findObjectsInBackgroundWithBlock { [weak self](objects: [PFObject]?, error: NSError?) -> Void in
            if let error = error {
                print("Error: \(error) \(error.userInfo)")
                return
            }

            self?.photoArray = objects as? [Photo]
            self?.collectionView.reloadData()
            print("Photo query success. Number photos: \(objects?.count)")
        }
    }
    
    // NOTE: KEEP AROUND FOR REFERENCE
    private func distance(location: PFGeoPoint, currentLocation: PFGeoPoint) -> Double {
        var distance: Double
        distance = sqrt((location.longitude - currentLocation.longitude)*(location.longitude - currentLocation.longitude)+(location.latitude - currentLocation.latitude)*(location.latitude - currentLocation.latitude))
        return distance
    }

}

// MARK: - UICollectionViewDataSource

extension SearchLocationViewController: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(locationCollectionView: UICollectionView) -> Int {
        return 1
    }
  
    func collectionView(locationCollectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let photoArray = photoArray {
            return photoArray.count
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath)
        guard let pfImageView = cell.viewWithTag(1) as? PFImageView,
            photoArray = photoArray
        else {
            return cell
        }
        
        let photo = photoArray[indexPath.item]
        pfImageView.contentMode = .ScaleAspectFit
        pfImageView.file = photo.thumbnail
        pfImageView.loadInBackground()
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension SearchLocationViewController: UICollectionViewDelegate {
    func collectionView(locationCollectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let vc = storyboard?.instantiateViewControllerWithIdentifier("photoDetailViewController") as! PhotoDetailViewController
        if let photoArray = photoArray {
            let photo = photoArray[indexPath.item]
            vc.file = photo.image
            presentViewController(vc, animated: true, completion: nil)
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension SearchLocationViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse || status == .AuthorizedAlways {
            manager.startUpdatingLocation()
            if didRequestLocation {
                updateCurrentLocation()
            }
        }
    }
}