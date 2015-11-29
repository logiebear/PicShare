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
    var photoArray: [PFObject]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if !UIImagePickerController.isSourceTypeAvailable(.Camera) {
            takePhotoButton.hidden = true
        }
        
        queryForAllPhotos()
    }
    
    // MARK: - Private
    
    private func queryForAllPhotos() {
        let query = PFQuery(className: photoClassName)
        query.findObjectsInBackgroundWithBlock { [weak self](objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                self?.photoArray = objects
                self?.collectionView.reloadData()
                print("Photo query success. Number photos: \(objects?.count)")
            } else {
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    // MARK: - User Actions
    
    @IBAction func cameraRollButtonPressed(sender: AnyObject) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .PhotoLibrary
        presentViewController(picker, animated: true, completion: nil)
    }
    
    @IBAction func takePhotoButtonPressed(sender: AnyObject) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .Camera
        presentViewController(picker, animated: true, completion: nil)
    }
    
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
            photoArray = photoArray,
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

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let vc = storyboard?.instantiateViewControllerWithIdentifier("photoDetailViewController") as! PhotoDetailViewController
        if let photoArray = photoArray,
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


extension HomeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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