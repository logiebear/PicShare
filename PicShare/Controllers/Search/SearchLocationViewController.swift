//
//  SearchLocationViewController.swift
//  PicShare
//  Created by Yuan on 11/28/15.
//  Copyright © 2015 USC. All rights reserved.
//

import Foundation
import UIKit
import Parse
import ParseUI

class SearchLocationViewController: UIViewController {
  
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var checkmarkButton: UIButton!
    @IBOutlet weak var radiusLabel: UILabel!
    @IBOutlet weak var radiusSlider: UISlider!
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var nearbyView: UIView!
    @IBOutlet weak var nearbyPhotoLabel: UILabel!
    let locationManager = CLLocationManager()
    var photoArray: [Photo]?
    var didRequestLocation = false
    var formerRadius = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Update knob image
        let sliderKnobImage = UIImage(named: "sliderKnob")
        radiusSlider.setThumbImage(sliderKnobImage, forState: .Normal)
        filterView.alpha = 0.0
        closeButton.alpha = 0.0
        checkmarkButton.alpha = 0.0
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateCurrentLocation()
    }
    
    // MARK: User Actions
    
    @IBAction func filterButtonPressed(sender: AnyObject) {
        UIView.animateWithDuration(0.5) { [weak self]() -> Void in
            self?.filterView.alpha = 1.0
            self?.closeButton.alpha = 1.0
            self?.checkmarkButton.alpha = 1.0
            self?.filterButton.alpha = 0.0
        }
        formerRadius = Int(radiusSlider.value)
    }
    
    @IBAction func checkmarkButtonPressed(sender: AnyObject) {
        UIView.animateWithDuration(0.5) { [weak self]() -> Void in
            self?.filterView.alpha = 0.0
            self?.closeButton.alpha = 0.0
            self?.checkmarkButton.alpha = 0.0
            self?.filterButton.alpha = 1.0
        }
        // Detect new location and filter for new photos
        updateCurrentLocation()
    }
    
    @IBAction func closeButtonPressed(sender: AnyObject) {
        UIView.animateWithDuration(0.5) { [weak self]() -> Void in
            self?.filterView.alpha = 0.0
            self?.closeButton.alpha = 0.0
            self?.checkmarkButton.alpha = 0.0
            self?.filterButton.alpha = 1.0
        }
        // Reset to former radius if canceled
        radiusSlider.value = Float(formerRadius)
        let radius = Int(radiusSlider.value)
        radiusLabel.text = "\(radius) Miles"
    }
    
    @IBAction func radiusSliderValueChanged(sender: AnyObject) {
        let radius = Int(radiusSlider.value)
        radiusLabel.text = "\(radius) Miles"
    }

    // MARK: Location Methods
    
    /**
        Re-get Photos from the server while goePoint is updated
     
    */
    private func updateCurrentLocation() {
        let status = CLLocationManager.authorizationStatus()
        if status == .Denied || status == .Restricted {
            showAlert("Location Services Disabled", message: "Please go to your device settings to enable location services.")
        } else if status == .NotDetermined {
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
            didRequestLocation = true
        } else {
            if !networkReachable() {
                showAlert("No Internet Connection", message: "Unable to refresh photos. Please check your internet connection and try again.")
                return
            }
            PFGeoPoint.geoPointForCurrentLocationInBackground { [weak self](geoPoint: PFGeoPoint?, error: NSError?) -> Void in
                if let geoPoint = geoPoint {
                    self?.queryForNearbyPhotos(location: geoPoint)
                }
            }
        }
    }
    
    /**
        Query all photos near the current location with specific radius
     
        - Parameter:
            -location: user's current location
 
     */
    private func queryForNearbyPhotos(location location: PFGeoPoint) {
        guard let query = Photo.queryNearbyPhotosWithRadius(location, radiusInMiles: Double(radiusSlider.value)) else {
            return
        }
        
        query.findObjectsInBackgroundWithBlock { [weak self](objects: [PFObject]?, error: NSError?) -> Void in
            if let error = error {
                print("Error: \(error) \(error.userInfo)")
                self?.showAlert("Error", message: "There was an error retrieving your photos please try again.")
                return
            }

            self?.photoArray = objects as? [Photo]
            if objects?.count == 0 {
                self?.showAlert("None Result", message: "No nearby photos found. Upload one!")
            }
            self?.tableView.reloadData()
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

// MARK: - UITableViewDataSource

extension SearchLocationViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let photoArray = photoArray {
            return photoArray.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! SearchLocationTableViewCell
        guard let photoArray = photoArray else {
            return cell
        }
        let photo = photoArray[indexPath.item]
        cell.photoImageView.contentMode = .ScaleAspectFit
        cell.photoImageView.file = photo.thumbnail
        cell.photoImageView.loadInBackground()
        cell.commentLabel.text = photo.descriptiveText ?? ""
        cell.usernameLabel.text = photo.owner?.username ?? "Anonymous"
        // TODO: UPDATE PROFILE PHOTO AFTER WE ALTER PHOTO OWNER TO USER INSTEAD OF PFUSER
        // cell.profilePhotoImageView.image = ...?
        return cell
    }
    
}

// MARK: - UITableViewDelegate

extension SearchLocationViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let vc = storyboard?.instantiateViewControllerWithIdentifier("photoDetailViewController") as! PhotoDetailViewController
        if let photoArray = photoArray {
            let photo = photoArray[indexPath.item]
            vc.photo = photo
            navigationController?.pushViewController(vc, animated: true)
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