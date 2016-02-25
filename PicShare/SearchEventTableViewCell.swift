//
//  EventSearchTableViewCell.swift
//  PicShare
//
//  Created by Yuan on 2/23/16.
//  Copyright © 2016 USC. All rights reserved.
//

import UIKit

class SearchEventTableViewCell: UITableViewCell {

    @IBOutlet weak var eventLabel: UILabel!
    @IBOutlet weak var sublabel: UILabel!
    @IBOutlet weak var joinButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
