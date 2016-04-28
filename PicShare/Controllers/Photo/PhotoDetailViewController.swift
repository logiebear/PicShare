//
//  PhotoDetailViewController.swift
//  PicShare
//
//  Created by Logan Chang on 11/19/15.
//  Copyright © 2015 USC. All rights reserved.
//

import UIKit
import ParseUI

class PhotoDetailViewController: UIViewController {

    @IBOutlet weak var pfImageView: PFImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var commentLabel: UILabel!
    var photo: Photo?
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let photo = photo else {
            return
        }
        commentLabel.text = photo.descriptiveText
        deleteButton.hidden = photo.owner?.objectId != PFUser.currentUser()?.objectId
        pfImageView.contentMode = .ScaleAspectFit
        pfImageView.file = photo.image
        
        // Loads full image in asynchonously
        activityIndicator.startAnimating()
        pfImageView.loadInBackground { [weak self](image, error) -> Void in
            self?.activityIndicator.stopAnimating()
            self?.image = image
            if error != nil {
                print("Error: \(error)")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - User Actions
    
    @IBAction func closeButtonPressed(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func downloadButtonPressed(sender: AnyObject) {
        guard let image = image else {
            showAlert("Download Error", message: "Unable to download image.")
            return
        }
        
        // Download photo image file to device photo library
        UIImageWriteToSavedPhotosAlbum(image, self, "image:didFinishSavingWithError:contextInfo:", nil)
    }
    
    @IBAction func deleteButtonPressed(sender: AnyObject) {
        showConfirmView("", msg: "Do you want to delete this photo?")
    }
    
    // MARK: - Helpers
    
    func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafePointer<Void>) {
        if let error = error {
            showAlert("Download Error", message: error.localizedDescription)
        } else {
            showAlert("Success!", message: "You have downloaded the image successfully!")
        }
    }
    
    /**
        Show confirmation dialog for photo deletion
     */
    func showConfirmView(title: String, msg: String) {
        let alertView = UIAlertController(title: title,
            message: msg, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "YES", style: UIAlertActionStyle.Default) {
            UIAlertAction in
            print("YES Pressed")
            if let photo = self.photo {
                photo.deleteInBackground()
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
        let cancelAction = UIAlertAction(title: "NO", style: UIAlertActionStyle.Cancel) {
            UIAlertAction in
            print("NO Pressed")
        }
        alertView.addAction(okAction)
        alertView.addAction(cancelAction)
        self.presentViewController(alertView, animated: true, completion: nil)
    }
    
}
