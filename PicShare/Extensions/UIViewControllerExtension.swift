//
//  UIViewControllerExtension.swift
//  PicShare
//
//  Created by Logan Chang on 3/6/16.
//  Copyright © 2016 USC. All rights reserved.
//

import Foundation

extension UIViewController {

    /**
        Shows custom basic alert view with completion block
        -Parameters
            -title: title
            -message: message
            -completion: completion block to be called after alert is dismissed
     */
    func showAlert(title: String, message: String, completion: (() -> ())? = nil) {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction) in
            completion?()
        })
        alertView.addAction(okAction)
        presentViewController(alertView, animated: true, completion: completion)
    }
    
}