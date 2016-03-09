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
    
    var file: PFFile?
    var photo: Photo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pfImageView.contentMode = .ScaleAspectFit
        pfImageView.file = file
        
        activityIndicator.startAnimating()
        pfImageView.loadInBackground { [unowned self](image, error) -> Void in
            self.activityIndicator.stopAnimating()
            if error != nil {
                print("Error: \(error)")
            }
        }
    }
    
    @IBAction func closeButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func deleteButtonPressed(sender: AnyObject) {
        self.showConfirmView("", msg: "Do you want to Delete this photo?")
    }
    
    // MARK: - Helpers
    
    func showConfirmView(title: String, msg: String) {
        let alertView = UIAlertController(title: title,
            message: msg, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "YES", style: UIAlertActionStyle.Default) {
            UIAlertAction in
            NSLog("YES Pressed")
            if let photo = self.photo {
                photo.deleteInBackground()
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        let cancelAction = UIAlertAction(title: "NO", style: UIAlertActionStyle.Cancel) {
            UIAlertAction in
            NSLog("NO Pressed")
        }
        alertView.addAction(okAction)
        alertView.addAction(cancelAction)
        self.presentViewController(alertView, animated: true, completion: nil)
    }
    
}
