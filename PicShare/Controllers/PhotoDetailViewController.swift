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
}
