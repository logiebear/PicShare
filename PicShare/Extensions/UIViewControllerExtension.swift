//
//  UIViewControllerExtension.swift
//  PicShare
//
//  Created by Logan Chang on 3/6/16.
//  Copyright © 2016 USC. All rights reserved.
//

import Foundation

extension UIViewController {

    func showAlert(title: String, message: String, completion: (() -> ())? = nil) {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertView.addAction(okAction)
        presentViewController(alertView, animated: true, completion: completion)
    }
    
}