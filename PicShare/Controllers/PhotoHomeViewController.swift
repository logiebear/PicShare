//
//  PhotoViewController.swift
//  PicShare
//
//  Created by Logan Chang on 11/15/15.
//  Copyright © 2015 USC. All rights reserved.
//

import UIKit
import Parse

let photoClassName = "Photo"
let photoFileKey = "file"

class PhotoHomeViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var takePhotoButton: UIButton!
    var photoArray: [PFObject]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if !UIImagePickerController.isSourceTypeAvailable(.Camera) {
            takePhotoButton.hidden = true
        }
        
        reload()
    }
    
    // MARK: - Public
    
    func reload() {
        queryForAllPhotos()
        collectionView.reloadData()
    }
    
    // MARK: - Private
    
    private func queryForAllPhotos() {
        let query = PFQuery(className: photoClassName)
        query.findObjectsInBackgroundWithBlock { [weak self](objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                self?.photoArray = objects
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
        reload()
    }
}

// MARK: - UICollectionViewDataSource

extension PhotoHomeViewController: UICollectionViewDataSource {
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
            userImageFile = photoArray[indexPath.item][photoFileKey] as? PFFile
        {
            userImageFile.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
                if error == nil {
                    if let imageData = imageData, image = UIImage(data: imageData) {
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

extension PhotoHomeViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // TODO: SHOW PHOTO DETAIL
    }
}

// MARK: - UIImagePickerControllerDelegate

extension PhotoHomeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        // TODO: SAVE IMAGE
        print("Photo selected")
        if let imageData = UIImagePNGRepresentation(image) {
            let imageFile = PFFile(name: "image.png", data: imageData)
            let userPhoto = PFObject(className: photoClassName)
            userPhoto["comment"] = "test"
            userPhoto[photoFileKey] = imageFile
            userPhoto.saveInBackground()
        } else {
            print("Photo saving error")
        }
        dismissViewControllerAnimated(true) { [weak self]() -> Void in
            self?.reload()
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}