//
//  RootViewController.swift
//  PicShare
//
//  Created by Logan Chang on 11/15/15.
//  Copyright © 2015 USC. All rights reserved.
//

import UIKit
import Parse

class RootViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    var currentContentViewController: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        displayCorrectHomeViewController()
    }
    
    func displayCorrectHomeViewController() {
        let vc = storyboard?.instantiateViewControllerWithIdentifier("tabBarViewController") as! TabBarViewController
        // TODO: DISPLAY CORRECT HOME SCREEN BASED ON IF USER IS LOGGED IN
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
