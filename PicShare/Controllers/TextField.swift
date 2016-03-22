//
//  TextField.swift
//  PicShare
//
//  Created by Yao Wang on 3/15/16.
//  Copyright © 2016 USC. All rights reserved.
//

import UIKit

class TextField: UITextField {
    let padding = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15);
    
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return self.newBounds(bounds)
    }
    
    override func placeholderRectForBounds(bounds: CGRect) -> CGRect {
        return self.newBounds(bounds)
    }
    
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return self.newBounds(bounds)
    }
    
    private func newBounds(bounds: CGRect) -> CGRect {
        var newBounds = bounds
        newBounds.origin.x += padding.left
        newBounds.origin.y += padding.top
        newBounds.size.height -= padding.top + padding.bottom
        newBounds.size.width -= padding.left + padding.right
        return newBounds
    }
}
