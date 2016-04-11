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
    var photo: Photo?
    var user: User?
    var userEventArray = [Event]()
    var image: UIImage?
    var event: Event?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let photo = photo else {
            // TODO: SHOW PHOTO ERROR MESSAGE
            return
        }
        
        deleteButton.hidden = photo.owner != PFUser.currentUser()
        pfImageView.contentMode = .ScaleAspectFit
        pfImageView.file = photo.image
        activityIndicator.startAnimating()
        pfImageView.loadInBackground { [weak self](image, error) -> Void in
            self?.activityIndicator.stopAnimating()
            self?.image = image
            if error != nil {
                print("Error: \(error)")
            }
        }
    }
    
    // MARK: - User Actions
    
    @IBAction func closeButtonPressed(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func downloadButtonPressed(sender: AnyObject) {
        guard let image = image, event = event else {
            showAlert("Download Error", message: "Unable to download image.")
            return
        }

        
        
        UIImageWriteToSavedPhotosAlbum(image, self, "image:didFinishSavingWithError:contextInfo:", nil)

    }
    
    @IBAction func deleteButtonPressed(sender: AnyObject) {
        self.showConfirmView("", msg: "Do you want to delete this photo?")
    }
    
    // MARK: - Private
    
    private func addEventToUserEvents(event: Event) {
        guard let user = self.user else  {
            print("Error no user")
            return
        }
        if user.events == nil {
            user.events = [Event]()
        }
        user.events?.append(event)
        user.saveInBackground()
    }
    
    // MARK: - Helpers
    
    func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafePointer<Void>) {
        if let error = error {
            showAlert("Download Error", message: error.localizedDescription)
        } else {
            if let event = event {
                if !userEventArray.contains(event){
                    print("join event automatically")
                    addEventToUserEvents(event)
                }

            }
                        showAlert("Success!", message: "You have downloaded the image successfully!")
        }
    }
    
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
