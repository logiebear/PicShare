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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RootViewController.displayCorrectHomeViewController), name: accountStatusChangedNotification, object: nil)
    }
    
    /**
        Detects which screen to show based on user's login status
     */
    func displayCorrectHomeViewController() {
        let vc: UIViewController
        if let user = PFUser.currentUser() where user.authenticated {
            let tabBarViewController = storyboard?.instantiateViewControllerWithIdentifier("tabBarViewController") as! TabBarViewController
            tabBarViewController.delegate = self
            vc = tabBarViewController
        } else {
            let accountStoryboard = UIStoryboard(name: "Account", bundle: nil)
            vc = accountStoryboard.instantiateInitialViewController() as! LoginViewController
        }

        displayViewController(vc)
    }
    
    /**
         Displays new view controller in container view
         -Parameters
            -viewController: view controller to display
     */
    func displayViewController(viewController: UIViewController) {
        // Remove original view controller
        currentContentViewController?.view.removeFromSuperview()
        currentContentViewController?.removeFromParentViewController()
        currentContentViewController = nil
        
        // Add new view controller
        addChildViewController(viewController)
        viewController.view.frame = CGRect(x: 0, y: 0, width: containerView.bounds.size.width, height: containerView.bounds.size.height)
        containerView.addSubview(viewController.view)
        viewController.didMoveToParentViewController(self)
        currentContentViewController = viewController
    }
}

extension RootViewController: UITabBarControllerDelegate {
    
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        // Do not switch nav bar if photo temp view, but instead push the custom camera view
        if viewController is PhotoTempViewController {
            // If no camera is available prevent use of custom camera view
            if UIImagePickerController.isSourceTypeAvailable(.Camera) && !cameraAvailable() {
                showAlert("Trouble With Camera", message: "Please enable your camera in your device settings to take a photo.")
            } else {
                let vc = storyboard?.instantiateViewControllerWithIdentifier("photoHomeViewController") as! PhotoHomeViewController
                navigationController?.pushViewController(vc, animated: false)
            }
            return false
        }
        return true
    }
    
}