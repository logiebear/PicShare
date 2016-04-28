//
//  EventPhotoCollectionViewCell.swift
//  PicShare
//
//  Created by Yao Wang on 1/30/16.
//  Copyright © 2016 USC. All rights reserved.
//

import UIKit
import ParseUI

protocol EventPhotoCollectionViewCellDelegate: class {
    /**
        Delegate function for handling photo deletion
     
        -Parameters:
            -photo: photo to be deleted
            -indexPath: indexPath of the cell
     
     */
    func deletePhoto(photo: Photo, indexPath: NSIndexPath)
}

class EventPhotoCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: PFImageView!
    @IBOutlet weak var deleteButton: UIButton!
    weak var delegate: EventPhotoCollectionViewCellDelegate?
    var photo: Photo?
    var indexPath: NSIndexPath?
    
    /**
         Delete photo button
     
         -Parameters:
             -sender: The sender of the deletion
     */
    @IBAction func deleteButtonPressed(sender: AnyObject) {
        if let photo = photo, indexPath = indexPath {
            delegate?.deletePhoto(photo, indexPath: indexPath)
        }
    }
}
