//
//  RootViewController.swift
//  PicShare
//
//  Created by Logan Chang on 11/15/15.
//  Copyright © 2015 USC. All rights reserved.
//

import UIKit
import Parse

let accountStatusChangedNotification = "AccountStatusChangedNotification"

class RootViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    var currentContentViewController: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        displayCorrectHomeViewController()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "displayCorrectHomeViewController", name: accountStatusChangedNotification, object: nil)
    }
    
    func displayCorrectHomeViewController() {
        let vc: UIViewController
        if let user = PFUser.currentUser() where user.isAuthenticated() {
            vc = storyboard?.instantiateViewControllerWithIdentifier("tabBarViewController") as! TabBarViewController
        } else {
            let accountStoryboard = UIStoryboard(name: "Account", bundle: nil)
            vc = accountStoryboard.instantiateInitialViewController() as! LoginViewController
        }

        displayViewController(vc)
    }
    
    func displayViewController(viewController: UIViewController) {
        if let currentContentViewController = currentContentViewController {
            currentContentViewController.view.removeFromSuperview()
            currentContentViewController.removeFromParentViewController()
        }
        
        self.addChildViewController(viewController)
        viewController.view.frame = CGRect(x: 0, y: 0, width: containerView.bounds.size.width, height: containerView.bounds.size.height)
        containerView.addSubview(viewController.view)
        viewController.didMoveToParentViewController(self)
        currentContentViewController = viewController
    }
}
