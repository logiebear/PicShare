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
    @IBOutlet weak var editEventButton: UIButton!
    @IBOutlet weak var headerEventNameLabel: UILabel!
    @IBOutlet weak var noPhotosEventNameLabel: UILabel!
    @IBOutlet weak var noPhotosView: UIView!
    var sourceController: UIViewController?
    var eventPhotos = [Photo]()
    var event: Event?
    var syncInProgress = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.bringSubviewToFront(noPhotosView)
        noPhotosView.hidden = true
        
        // Update labels
        headerEventNameLabel.text = ""
        noPhotosEventNameLabel.text = ""
        if let event = event {
            headerEventNameLabel.text = "#\(event.hashtag)"
            noPhotosEventNameLabel.text = "#\(event.hashtag)"
        }
        
        // TODO: Cell Sizes
        // Resize size of collection view items in grid so that we achieve 3 boxes across
//        let cellWidth = ((UIScreen.mainScreen().bounds.width) - 32 - 30 ) / 3
//        let cellLayout = eventPhotoCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
//        cellLayout.itemSize = CGSize(width: cellWidth, height: cellWidth)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        reloadCollectionViewData()
    }
    
    // MARK: - User Actions
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        // If the source controller is a creation view, return to the main event list view in the Root View Controller
        if sourceController is CreateEventViewController || sourceController is CreateEventPasswordViewController {
            if let viewControllers = navigationController?.viewControllers {
                for viewController in viewControllers {
                    if viewController is RootViewController {
                        navigationController?.popToViewController(viewController, animated: true)
                        return
                    }
                }
            }
        }
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func editEvent(sender: AnyObject) {
        editEventButton.selected = !editEventButton.selected
        eventPhotoCollectionView.reloadData()
    }
    
    @IBAction func takePhoto(sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(.Camera) && !cameraAvailable() {
            showAlert("Trouble With Camera", message: "Please enable your camera in your device settings to take a photo.")
        } else {
            // Load camera in event list view
            let vc = storyboard?.instantiateViewControllerWithIdentifier("photoHomeViewController") as! PhotoHomeViewController
            vc.event = event
            navigationController?.pushViewController(vc, animated: false)
        }
    }
    
    func reloadCollectionViewData() {
        guard let event = event else {
            // Should not happen if event is set correctly
            return
        }
        
        if syncInProgress {
            return
        }
        syncInProgress = true
        
        // Fetch all the photos of current event
        let query = PFQuery(className: "Photo")
        query.whereKey("event", equalTo: event)
        query.findObjectsInBackgroundWithBlock { [weak self](objects: [PFObject]?, error: NSError?) -> Void in
            self?.syncInProgress = false
            if let error = error {
                print("Error: \(error)")
                return
            }
            self?.eventPhotos = objects as? [Photo] ?? []
            self?.eventPhotoCollectionView.reloadData()
            self?.showNoPhotosViewIfEmpty()
        }
    }
    
    /**
        Display no photos view if no photos in the event
     */
    private func showNoPhotosViewIfEmpty() {
        if let event = event where !eventPhotos.isEmpty {
            eventPhotoCollectionView.hidden = false
            noPhotosView.hidden = true
            if let currentUser = PFUser.currentUser() {
                editEventButton.hidden = event.owner.username != currentUser.username
            }
        } else {
            eventPhotoCollectionView.hidden = true
            noPhotosView.hidden = false
            editEventButton.hidden = true
        }
    }
}

extension EventPhotoScreenViewController: UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return eventPhotos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! EventPhotoCollectionViewCell
        // Fetch event photo image
        let photo = eventPhotos[indexPath.row]
        cell.imageView.file = photo.thumbnail
        cell.imageView.loadInBackground()
        cell.deleteButton.hidden = !editEventButton.selected
        cell.photo = photo
        cell.indexPath = indexPath
        cell.delegate = self
        return cell
    }
}

extension EventPhotoScreenViewController: UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let photo = eventPhotos[indexPath.item]
        if !editEventButton.selected {
            let vc = storyboard?.instantiateViewControllerWithIdentifier("photoDetailViewController") as! PhotoDetailViewController
            vc.photo = photo
            navigationController?.pushViewController(vc, animated: true)
        } else {
            deletePhoto(photo, indexPath: indexPath)
        }
    }
    
}

extension EventPhotoScreenViewController: EventPhotoCollectionViewCellDelegate {
    
    // Delete photo
    func deletePhoto(photo: Photo, indexPath: NSIndexPath) {
        let alertView = UIAlertController(title: "Delete Photo",
                                          message: "Delete this photo?", preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction) in
            let query = PFQuery(className: "Photo")
            guard let photoId = photo.objectId else {
                return
            }
            query.getObjectInBackgroundWithId(photoId) { [weak self](object, error) -> Void in
                if let error = error {
                    print("Error: \(error)")
                    return
                }
                if let object = object {
                    object.deleteInBackground()
                    self?.eventPhotos.removeAtIndex(indexPath.item)
                    self?.reloadCollectionViewData()
                }
            }
        })
        alertView.addAction(OKAction)
        alertView.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        presentViewController(alertView, animated: true, completion: nil)
    }
    
}