//
//  PhotoDetailViewController.swift
//  PicShare
//
//  Created by Logan Chang on 11/19/15.
//  Copyright © 2015 USC. All rights reserved.
//

import UIKit

class PhotoDetailViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let image = image {
            imageView.contentMode = .ScaleAspectFit
            imageView.image = image
        }
    }
    
    @IBAction func closeButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
