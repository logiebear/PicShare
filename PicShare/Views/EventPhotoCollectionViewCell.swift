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
    func deletePhoto(photo: Photo, indexPath: NSIndexPath)
}

class EventPhotoCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: PFImageView!
    @IBOutlet weak var deleteButton: UIButton!
    weak var delegate: EventPhotoCollectionViewCellDelegate?
    var photo: Photo?
    var indexPath: NSIndexPath?
    
    @IBAction func deleteButtonPressed(sender: AnyObject) {
        if let photo = photo, indexPath = indexPath {
            delegate?.deletePhoto(photo, indexPath: indexPath)
        }
    }
}
