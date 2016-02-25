//
//  SearchEventViewController.swift
//  PicShare
//
//  Created by Yuan on 2/20/16.
//  Copyright © 2016 USC. All rights reserved.
//

import Foundation
import UIKit
import Parse
import ParseUI

class SearchEventViewController: UIViewController {

    @IBOutlet weak var eventName: UITextField!
    @IBOutlet weak var eventSearch: UIButton!
    
    var event: String = "Hey, i'm transported."

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "segueTransfer") {
            let svc = segue.destinationViewController as! SearchEventResultViewController;
            svc.toPass = eventName.text
        }
    }
    
    // MARK: - User Actions
    @IBAction func backButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func searchEventButtonPressed(sender: AnyObject) {
        if let event = eventName.text {
            self.event = event
        }
        eventName.text = nil
        
    }
}