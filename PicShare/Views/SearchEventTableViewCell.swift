//
//  EventSearchTableViewCell.swift
//  PicShare
//
//  Created by Yuan on 2/23/16.
//  Copyright © 2016 USC. All rights reserved.
//

import UIKit

protocol SearchEventTableViewCellDelegate: class {
    func joinEvent(cell: SearchEventTableViewCell, event: Event)
}

class SearchEventTableViewCell: UITableViewCell {

    @IBOutlet weak var eventLabel: UILabel!
    @IBOutlet weak var sublabel: UILabel!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var checkmarkImageView: UIImageView!
    var event: Event?
    weak var delegate: SearchEventTableViewCellDelegate?
    
    @IBAction func joinButtonPressed(sender: AnyObject) {
        if let event = event {
            if event.isPublic {
                showJoinAnimation()
            }
            delegate?.joinEvent(self, event: event)
        }
    }
    
    func showJoinAnimation() {
        UIView.animateWithDuration(0.5) {
            self.joinButton.alpha = 0.0
            self.checkmarkImageView.alpha = 1.0
        }
    }

}
