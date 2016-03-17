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
    var file: PFFile?
    private var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pfImageView.contentMode = .ScaleAspectFit
        pfImageView.file = file
        
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
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func downloadButtonPressed(sender: AnyObject) {
        guard let image = image else {
            showAlert("Download Error", message: "Unable to download image.")
            return
        }
        
        UIImageWriteToSavedPhotosAlbum(image, self, "image:didFinishSavingWithError:contextInfo:", nil)
    }
    
    // MARK: - Handler
    
    func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafePointer<Void>) {
        if let error = error {
            showAlert("Download Error", message: error.localizedDescription)
        } else {
            showAlert("Success!", message: "You have downloaded the image successfully!")
        }
    }
    
}
