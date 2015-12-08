//
//  HomeViewController.swift
//  PicShare
//
//  Created by Logan Chang on 11/28/15.
//  Copyright © 2015 USC. All rights reserved.
//

import UIKit
import Parse

class HomeViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var takePhotoButton: UIButton!
    var photoArray: [Photo]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        queryForAllPhotos()
    }
    
    // MARK: - Private
    
    private func queryForAllPhotos() {
        guard let query = Photo.query() else {
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
    
    @IBAction func syncButtonPressed(sender: AnyObject) {
        queryForAllPhotos()
    }
}

// MARK: - UICollectionViewDataSource

extension HomeViewController: UICollectionViewDataSource {
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
        if let imageView = cell.viewWithTag(1) as? UIImageView,
            userNameLabel = cell.viewWithTag(2) as? UILabel,
            descriptionLabel = cell.viewWithTag(3) as? UILabel,
            photoArray = photoArray
        {
            let photo = photoArray[indexPath.item]
            let user = photo.owner
            do {
                try user?.fetchIfNeeded()
            } catch let error as NSError {
                print("error: \(error.localizedDescription)")
            }
            
            userNameLabel.text = user?.username ?? "Unknown"
            descriptionLabel.text = photo.descriptiveText ?? ""
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
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension HomeViewController: UICollectionViewDelegate {
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