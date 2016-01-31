//
//  MyPhotosViewController.swift
//  PicShare
//
//  Created by Logan Chang on 1/31/16.
//  Copyright © 2016 USC. All rights reserved.
//

import UIKit
import Parse

class MyPhotosViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    var photoArray: [Photo]?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        queryForAllUserPhotos()
    }
    
    // MARK: - Private
    
    private func queryForAllUserPhotos() {
        guard let query = Photo.allPhotosForCurrentUserQuery() else {
            return
        }
        
        query.findObjectsInBackgroundWithBlock { [weak self](objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                self?.photoArray = objects as? [Photo]
                self?.collectionView.reloadData()
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
}


// MARK: - UICollectionViewDataSource

extension MyPhotosViewController: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let photoArray = photoArray {
            return photoArray.count
        }
        return 0
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath)
        guard let imageView = cell.viewWithTag(1) as? UIImageView,
            photoArray = photoArray
        else {
            return cell
        }

        let photo = photoArray[indexPath.item]
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

        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension MyPhotosViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let vc = storyboard?.instantiateViewControllerWithIdentifier("photoDetailViewController") as! PhotoDetailViewController
        if let photoArray = photoArray {
            let photo = photoArray[indexPath.item]
            photo.image.getDataInBackgroundWithBlock { [weak self](imageData: NSData?, error: NSError?) -> Void in
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