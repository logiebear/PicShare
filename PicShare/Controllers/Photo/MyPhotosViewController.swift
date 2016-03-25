//
//  MyPhotosViewController.swift
//  PicShare
//
//  Created by Logan Chang on 1/31/16.
//  Copyright © 2016 USC. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class MyPhotosViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    var photoArray: [Photo]?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
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
        navigationController?.popViewControllerAnimated(true)
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

extension MyPhotosViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let vc = storyboard?.instantiateViewControllerWithIdentifier("photoDetailViewController") as! PhotoDetailViewController
        if let photoArray = photoArray {
            let photo = photoArray[indexPath.item]
            vc.photo = photo
            presentViewController(vc, animated: true, completion: nil)
        }
    }
}